#!/usr/bin/env python3
"""Literature library helper for the literature-lookup skill. Stdlib only.

Library root: $LIT_ROOT, default ~/Documents/literature.
Settings come from environment variables, else from $LIT_ROOT/config.json
(kept outside any repository):
  mailto            contact email for API polite pools; Unpaywall needs it
  openalex_api_key, s2_api_key, core_api_key   optional API keys

Run `lit.py -h` or `lit.py <command> -h` for usage.
"""

import argparse
import difflib
import gzip
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(os.environ.get("LIT_ROOT", "~/Documents/literature")).expanduser()

def _config():
    p = ROOT / "config.json"
    try:
        return json.loads(p.read_text()) if p.exists() else {}
    except json.JSONDecodeError:
        print(f"warning: ignoring bad JSON in {p}", file=sys.stderr)
        return {}


CONFIG = _config()


def setting(name):
    env = os.environ.get("LIT_" + name.upper())
    if not env and name.endswith("_api_key"):
        env = os.environ.get(name.upper())
    return env or CONFIG.get(name)


MAILTO = setting("mailto")
UA = f"literature-lookup/1.0 (mailto:{MAILTO})" if MAILTO else "literature-lookup/1.0"
MAX_DOWNLOAD = 150 * 1024 * 1024
DOI_RE = re.compile(r"\b(10\.\d{4,9}/[^\s\"<>]+)", re.I)
ARXIV_RE = re.compile(r"^(?:arxiv:)?(\d{4}\.\d{4,5}(?:v\d+)?|[a-z\-]+(?:\.[A-Z]{2})?/\d{7}(?:v\d+)?)$", re.I)


# ---------------------------------------------------------------- utilities

def die(msg, code=1):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def warn(msg):
    print(f"warning: {msg}", file=sys.stderr)


def http(url, accept="application/json", tries=4, raw=False, headers=None, timeout=60):
    """GET url. Returns parsed JSON, text, or (bytes, content_type) when raw."""
    hdrs = {"User-Agent": UA, "Accept": accept}
    hdrs.update(headers or {})
    delay = 2.0
    for attempt in range(tries):
        req = urllib.request.Request(url, headers=hdrs)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                ctype = r.headers.get("Content-Type", "")
                data = r.read(MAX_DOWNLOAD + 1)
                if len(data) > MAX_DOWNLOAD:
                    raise RuntimeError("response larger than download limit")
                if raw:
                    return data, ctype
                text = data.decode("utf-8", "replace")
                return json.loads(text) if "json" in accept and text.strip() else text
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503, 504) and attempt < tries - 1:
                retry = e.headers.get("Retry-After")
                time.sleep(float(retry) if retry and retry.isdigit() else delay)
                delay *= 2
                continue
            raise
        except (urllib.error.URLError, TimeoutError):
            if attempt < tries - 1:
                time.sleep(delay)
                delay *= 2
                continue
            raise


def clean_doi(s):
    s = s.strip()
    s = re.sub(r"^(https?://(dx\.)?doi\.org/|doi:)", "", s, flags=re.I)
    return s.rstrip(".,;)]}").lower()


def norm_title(s):
    s = unicodedata.normalize("NFKD", s or "").encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()


def ascii_upper(s):
    s = unicodedata.normalize("NFKD", s or "").encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Za-z]", "", s).upper()


def oa_params(extra):
    p = dict(extra)
    if setting("openalex_api_key"):
        p["api_key"] = setting("openalex_api_key")
    elif MAILTO:
        p["mailto"] = MAILTO
    return urllib.parse.urlencode(p)


def s2_headers():
    k = setting("s2_api_key")
    return {"x-api-key": k} if k else {}


# ---------------------------------------------------------------- library

def lib_dir():
    return ROOT / "library"


def all_meta():
    out = []
    if lib_dir().is_dir():
        for p in sorted(lib_dir().glob("*/meta.json")):
            try:
                out.append(json.loads(p.read_text()))
            except json.JSONDecodeError:
                warn(f"bad JSON in {p}")
    return out


def load_meta(key):
    p = lib_dir() / key / "meta.json"
    if not p.exists():
        die(f"no library entry {key}")
    return json.loads(p.read_text())


def save_meta(m):
    d = lib_dir() / m["key"]
    d.mkdir(parents=True, exist_ok=True)
    (d / "meta.json").write_text(json.dumps(m, indent=2, ensure_ascii=False) + "\n")
    write_index()


def find_entry(ident):
    """Find an entry by key, DOI, or arXiv id."""
    ident = ident.strip()
    if (lib_dir() / ident / "meta.json").exists():
        return load_meta(ident)
    doi = clean_doi(ident)
    ax = ARXIV_RE.match(ident)
    for m in all_meta():
        if m.get("doi") and m["doi"] == doi:
            return m
        if ax and m.get("arxiv") and m["arxiv"].split("v")[0] == ax.group(1).split("v")[0]:
            return m
    return None


def make_key(family, year):
    base = (ascii_upper(family) or "ANON") + str(year or "ND")
    taken = {p.name for p in lib_dir().glob("*")} if lib_dir().is_dir() else set()
    if base not in taken:
        return base
    for c in "BCDEFGHIJKLMNOPQRSTUVWXYZ":
        if base + c not in taken:
            return base + c
    die("ran out of key suffixes")


def write_index():
    rows = all_meta()
    lines = [
        "# Library index",
        "",
        "Generated by lit.py. Do not edit by hand.",
        "",
        "| Key | Year | Read | Version | Queued | Title | DOI / arXiv | Topics |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for m in rows:
        ident = m.get("doi") or (f"arXiv:{m['arxiv']}" if m.get("arxiv") else "")
        title = (m.get("title") or "").replace("|", "/")[:110]
        lines.append(
            f"| {m['key']} | {m.get('year') or ''} | {m.get('read', 'none')} | {m.get('version') or ''} "
            f"| {'yes' if m.get('queued') else ''} | {title} | {ident} | {', '.join(m.get('topics', []))} |"
        )
    (ROOT / "index.md").write_text("\n".join(lines) + "\n")


# ---------------------------------------------------------------- sources

def openalex_work(ident):
    if ident.startswith("W"):
        path = ident
    else:
        path = "doi:" + clean_doi(ident)
    try:
        return http(f"https://api.openalex.org/works/{path}?" + oa_params({}))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def openalex_abstract(w):
    inv = (w or {}).get("abstract_inverted_index")
    if not inv:
        return None
    pos = {}
    for word, idxs in inv.items():
        for i in idxs:
            pos[i] = word
    return " ".join(pos[i] for i in sorted(pos))


def crossref_work(doi):
    try:
        r = http(f"https://api.crossref.org/works/{urllib.parse.quote(clean_doi(doi))}")
        return r.get("message")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def arxiv_query(params):
    url = "https://export.arxiv.org/api/query?" + urllib.parse.urlencode(params)
    xml = http(url, accept="application/atom+xml")
    ns = {"a": "http://www.w3.org/2005/Atom", "x": "http://arxiv.org/schemas/atom"}
    out = []
    for e in ET.fromstring(xml).findall("a:entry", ns):
        aid = (e.findtext("a:id", "", ns) or "").rsplit("/abs/", 1)[-1]
        if not aid:
            continue
        out.append({
            "arxiv": aid,
            "title": " ".join((e.findtext("a:title", "", ns) or "").split()),
            "year": (e.findtext("a:published", "", ns) or "")[:4],
            "authors": [a.findtext("a:name", "", ns) for a in e.findall("a:author", ns)],
            "doi": clean_doi(e.findtext("x:doi", "", ns)) if e.findtext("x:doi", "", ns) else None,
            "venue": e.findtext("x:journal_ref", "", ns) or "arXiv",
            "abstract": " ".join((e.findtext("a:summary", "", ns) or "").split()),
        })
    return out


def oa_row(w):
    loc = (w.get("primary_location") or {}).get("source") or {}
    ids = w.get("ids") or {}
    arx = None
    for l in w.get("locations") or []:
        u = (l.get("landing_page_url") or "")
        m = re.search(r"arxiv\.org/abs/([^\s?#]+)", u)
        if m:
            arx = m.group(1)
            break
    return {
        "doi": clean_doi(w["doi"]) if w.get("doi") else None,
        "title": w.get("title") or w.get("display_name") or "",
        "year": w.get("publication_year"),
        "venue": loc.get("display_name") or "",
        "cited": w.get("cited_by_count"),
        "oa": (w.get("open_access") or {}).get("is_oa"),
        "type": w.get("type"),
        "arxiv": arx,
        "openalex": (ids.get("openalex") or w.get("id") or "").rsplit("/", 1)[-1],
        "retracted": w.get("is_retracted"),
        "src": "openalex",
    }


OA_SELECT = "id,doi,title,display_name,publication_year,primary_location,cited_by_count,open_access,type,ids,locations,is_retracted"


def search_openalex(q, a):
    filt = []
    if a.year_from or a.year_to:
        filt.append(f"publication_year:{a.year_from or ''}-{a.year_to or ''}")
    if a.reviews:
        filt.append("type:review")
    params = {"search": q, "per-page": a.limit, "select": OA_SELECT}
    if filt:
        params["filter"] = ",".join(filt)
    if a.sort == "cited":
        params["sort"] = "cited_by_count:desc"
    elif a.sort == "date":
        params["sort"] = "publication_date:desc"
    r = http("https://api.openalex.org/works?" + oa_params(params))
    return [oa_row(w) for w in r.get("results", [])]


def search_s2(q, a):
    params = {"query": q, "limit": a.limit,
              "fields": "title,year,venue,externalIds,citationCount,openAccessPdf,publicationTypes"}
    if a.year_from or a.year_to:
        params["year"] = f"{a.year_from or ''}-{a.year_to or ''}"
    if a.reviews:
        params["publicationTypes"] = "Review"
    r = http("https://api.semanticscholar.org/graph/v1/paper/search?" + urllib.parse.urlencode(params),
             headers=s2_headers())
    out = []
    for p in r.get("data") or []:
        ex = p.get("externalIds") or {}
        out.append({
            "doi": clean_doi(ex["DOI"]) if ex.get("DOI") else None,
            "title": p.get("title") or "", "year": p.get("year"), "venue": p.get("venue") or "",
            "cited": p.get("citationCount"), "oa": bool(p.get("openAccessPdf")),
            "arxiv": ex.get("ArXiv"), "type": ",".join(p.get("publicationTypes") or []), "src": "s2",
        })
    return out


def search_arxiv(q, a):
    words = [w for w in re.findall(r'"[^"]+"|\S+', q)]
    sq = " AND ".join(f"all:{w}" for w in words)
    if a.year_from or a.year_to:
        lo = f"{a.year_from or 1991}01010000"
        hi = f"{a.year_to or 2100}12312359"
        sq = f"({sq}) AND submittedDate:[{lo} TO {hi}]"
    sort = "submittedDate" if a.sort == "date" else "relevance"
    rows = arxiv_query({"search_query": sq, "max_results": a.limit, "sortBy": sort})
    for r in rows:
        r.update({"cited": None, "oa": True, "type": "preprint", "src": "arxiv"})
        r.pop("abstract", None)
    return rows


def search_crossref(q, a):
    params = {"query.bibliographic": q, "rows": a.limit,
              "select": "DOI,title,issued,container-title,is-referenced-by-count,type"}
    filt = []
    if a.year_from:
        filt.append(f"from-pub-date:{a.year_from}")
    if a.year_to:
        filt.append(f"until-pub-date:{a.year_to}")
    if filt:
        params["filter"] = ",".join(filt)
    if a.sort == "cited":
        params["sort"] = "is-referenced-by-count"
    elif a.sort == "date":
        params["sort"] = "published"
    r = http("https://api.crossref.org/works?" + urllib.parse.urlencode(params))
    out = []
    for it in r.get("message", {}).get("items", []):
        dp = (it.get("issued") or {}).get("date-parts") or [[None]]
        out.append({
            "doi": clean_doi(it["DOI"]), "title": (it.get("title") or [""])[0],
            "year": dp[0][0], "venue": (it.get("container-title") or [""])[0],
            "cited": it.get("is-referenced-by-count"), "oa": None, "arxiv": None,
            "type": it.get("type"), "src": "crossref",
        })
    return out


SEARCHERS = {"openalex": search_openalex, "s2": search_s2, "arxiv": search_arxiv, "crossref": search_crossref}


def merge(rows):
    out, seen = [], {}
    for r in rows:
        k = r.get("doi") or (r.get("arxiv") or "").split("v")[0] or norm_title(r.get("title"))
        tk = norm_title(r.get("title"))
        hit = seen.get(k) or seen.get(tk)
        if hit:
            for f in ("doi", "arxiv", "venue", "year", "openalex"):
                if not hit.get(f) and r.get(f):
                    hit[f] = r[f]
            if r.get("cited") is not None:
                hit["cited"] = max(hit.get("cited") or 0, r["cited"])
            hit["oa"] = hit.get("oa") or r.get("oa")
            hit["src"] += "+" + r["src"]
            continue
        r = dict(r)
        out.append(r)
        seen[k] = r
        if tk:
            seen[tk] = r
    return out


def print_rows(rows, as_json=False):
    if as_json:
        print(json.dumps(rows, indent=1, ensure_ascii=False))
        return
    have = {m.get("doi"): m["key"] for m in all_meta() if m.get("doi")}
    for r in rows:
        ident = r.get("doi") or (f"arXiv:{r['arxiv']}" if r.get("arxiv") else "-")
        flags = []
        if r.get("oa"):
            flags.append("OA")
        if r.get("arxiv") and r.get("doi"):
            flags.append(f"arXiv:{r['arxiv']}")
        if r.get("type") and "review" in str(r["type"]).lower():
            flags.append("REVIEW")
        if r.get("retracted"):
            flags.append("RETRACTED")
        if r.get("doi") in have:
            flags.append(f"IN-LIBRARY:{have[r['doi']]}")
        cited = r.get("cited")
        title = re.sub(r"<[^>]+>", "", r.get("title") or "")[:120]
        venue = (r.get("venue") or "")[:40]
        print(f"{r.get('year') or '----'} | c={cited if cited is not None else '?':>5} | {ident} | {title} [{venue}] {' '.join(flags)}")


# ---------------------------------------------------------------- commands

def cmd_init(a):
    for d in ("library", "topics", "inbox"):
        (ROOT / d).mkdir(parents=True, exist_ok=True)
    write_index()
    print(ROOT)


def cmd_search(a):
    q = " ".join(a.query)
    rows = []
    for name in a.sources.split(","):
        fn = SEARCHERS.get(name.strip())
        if not fn:
            die(f"unknown source {name}; choose from {', '.join(SEARCHERS)}")
        try:
            got = fn(q, a)
            print(f"# {name}: {len(got)} results", file=sys.stderr)
            rows.extend(got)
        except Exception as e:  # one failing source must not stop the others
            warn(f"{name} failed: {e}")
    print_rows(merge(rows), a.json)


def resolve_record(ident):
    """Return a normalised metadata dict for a DOI or arXiv id."""
    ident = ident.strip()
    ax = ARXIV_RE.match(ident) or re.search(r"arxiv\.org/(?:abs|pdf)/([^\s?#]+?)(?:\.pdf)?$", ident)
    rec = {"doi": None, "arxiv": None, "title": None, "year": None, "authors": [], "venue": None,
           "type": None, "abstract": None, "openalex": None, "retracted": None, "notices": []}
    if ax:
        rows = arxiv_query({"id_list": ax.group(1), "max_results": 1})
        if not rows:
            die(f"arXiv id {ax.group(1)} not found")
        r = rows[0]
        rec.update({k: r[k] for k in ("arxiv", "title", "year", "authors", "venue", "abstract")})
        rec["doi"] = r.get("doi")
        rec["type"] = "preprint"
        rec["year"] = int(r["year"]) if r.get("year") else None
    else:
        rec["doi"] = clean_doi(ident)
    if rec["doi"]:
        cr = crossref_work(rec["doi"])
        if cr is None and not rec["arxiv"]:
            die(f"DOI {rec['doi']} not found on Crossref. Do not cite it until it resolves.")
        if cr:
            dp = ((cr.get("issued") or cr.get("published") or {}).get("date-parts") or [[None]])[0]
            rec["title"] = (cr.get("title") or [rec["title"]])[0]
            rec["year"] = dp[0] or rec["year"]
            rec["venue"] = (cr.get("container-title") or [None])[0] or cr.get("publisher") or rec["venue"]
            rec["type"] = cr.get("type")
            auth = []
            for x in cr.get("author") or []:
                auth.append(", ".join(p for p in (x.get("family"), x.get("given")) if p) or x.get("name", ""))
            rec["authors"] = auth or rec["authors"]
            rec["family"] = ((cr.get("author") or [{}])[0].get("family")
                             or (cr.get("author") or [{}])[0].get("name"))
            for rel in ("update-to", "updated-by"):
                for u in cr.get(rel) or []:
                    rec["notices"].append(f"{rel}: {u.get('type')} {u.get('DOI', '')} {u.get('label', '')}".strip())
        w = openalex_work(rec["doi"])
        if w:
            rec["openalex"] = w["id"].rsplit("/", 1)[-1]
            rec["retracted"] = w.get("is_retracted")
            rec["abstract"] = rec["abstract"] or openalex_abstract(w)
            rec["cited"] = w.get("cited_by_count")
            if not rec["arxiv"]:
                rec["arxiv"] = oa_row(w).get("arxiv")
    if not rec.get("family") and rec["authors"]:
        first = rec["authors"][0]
        rec["family"] = first.split(",")[0] if "," in first else first.split()[-1]
    return rec


def cmd_resolve(a):
    rec = resolve_record(a.ident)
    if not a.abstract:
        rec.pop("abstract", None)
    if rec.get("retracted"):
        warn("OpenAlex marks this work as RETRACTED")
    for n in rec.get("notices", []):
        warn(f"Crossref notice: {n}")
    print(json.dumps(rec, indent=1, ensure_ascii=False))


def cmd_add(a):
    hit = find_entry(a.ident)
    if hit:
        if a.topic and a.topic not in hit.setdefault("topics", []):
            hit["topics"].append(a.topic)
            save_meta(hit)
        print(f"{hit['key']} (already in library, read={hit.get('read', 'none')})")
        return
    rec = resolve_record(a.ident)
    key = a.key or make_key(rec.get("family"), rec.get("year"))
    m = {
        "key": key, "doi": rec["doi"], "arxiv": rec["arxiv"], "title": rec["title"], "year": rec["year"],
        "authors": rec["authors"], "venue": rec["venue"], "type": rec["type"], "openalex": rec["openalex"],
        "retracted": rec["retracted"], "notices": rec["notices"], "read": "metadata-only",
        "version": None, "queued": False, "topics": [a.topic] if a.topic else [],
        "added": time.strftime("%Y-%m-%d"),
    }
    if rec.get("abstract"):
        m["read"] = "abstract-only"
        d = lib_dir() / key
        d.mkdir(parents=True, exist_ok=True)
        (d / "abstract.txt").write_text(rec["abstract"] + "\n")
    save_meta(m)
    flag = " RETRACTED" if rec["retracted"] else ""
    print(f"{key}{flag}")


def cmd_mark(a):
    m = load_meta(a.key)
    if a.read:
        m["read"] = a.read
    if a.version:
        m["version"] = a.version
    if a.queued is not None:
        m["queued"] = a.queued
    if a.topic and a.topic not in m.setdefault("topics", []):
        m["topics"].append(a.topic)
    if a.note:
        m["status_note"] = a.note
    save_meta(m)
    print(f"{m['key']}: read={m['read']} version={m.get('version')} queued={m.get('queued')}")


def cmd_find(a):
    q = " ".join(a.query)
    hit = find_entry(q)
    if hit:
        print(json.dumps(hit, indent=1, ensure_ascii=False))
        return
    nq = norm_title(q)
    scored = []
    for m in all_meta():
        nt = norm_title(m.get("title"))
        words = nq.split()
        s = sum(w in nt.split() for w in words) / max(len(words), 1)
        s = max(s, difflib.SequenceMatcher(None, nq, nt).ratio())
        scored.append((s, m))
    scored.sort(key=lambda x: -x[0])
    found = [m for s, m in scored[:10] if s >= 0.6]
    if not found:
        print("not in library")
    for m in found:
        print(f"{m['key']} | {m.get('year')} | read={m.get('read')} | {m.get('title')}")


def oa_locations(doi, arxiv=None):
    """List candidate full-text locations, best first."""
    locs = []

    def add(url, kind, version=None, host=None):
        if url and url not in {l["url"] for l in locs}:
            locs.append({"url": url, "kind": kind, "version": version, "host": host})

    if arxiv:
        add(f"https://arxiv.org/e-print/{arxiv}", "arxiv-source", "preprint", "arXiv")
        add(f"https://arxiv.org/pdf/{arxiv}", "pdf", "preprint", "arXiv")
    if doi:
        try:
            if not MAILTO:
                raise RuntimeError("skipped: set mailto in config.json (Unpaywall requires an email)")
            u = http(f"https://api.unpaywall.org/v2/{urllib.parse.quote(doi)}?email={MAILTO}")
            for l in u.get("oa_locations") or []:
                host = l.get("repository_institution") or l.get("host_type")
                add(l.get("url_for_pdf"), "pdf", l.get("version"), host)
                add(l.get("url_for_landing_page"), "landing", l.get("version"), host)
        except Exception as e:
            warn(f"unpaywall failed: {e}")
        try:
            w = openalex_work(doi)
            for l in (w or {}).get("locations") or []:
                src = (l.get("source") or {}).get("display_name")
                add(l.get("pdf_url"), "pdf", l.get("version"), src)
                if l.get("is_oa"):
                    add(l.get("landing_page_url"), "landing", l.get("version"), src)
        except Exception as e:
            warn(f"openalex failed: {e}")
        try:
            p = http(f"https://api.semanticscholar.org/graph/v1/paper/DOI:{urllib.parse.quote(doi)}"
                     "?fields=openAccessPdf,externalIds", headers=s2_headers(), tries=2, timeout=20)
            pdf = (p.get("openAccessPdf") or {}).get("url")
            add(pdf, "pdf", None, "semantic-scholar")
            ax = (p.get("externalIds") or {}).get("ArXiv")
            if ax and not arxiv:
                add(f"https://arxiv.org/e-print/{ax}", "arxiv-source", "preprint", "arXiv")
                add(f"https://arxiv.org/pdf/{ax}", "pdf", "preprint", "arXiv")
        except Exception as e:
            warn(f"semantic scholar failed: {e}")
        try:
            r = http("https://www.ebi.ac.uk/europepmc/webservices/rest/search?" + urllib.parse.urlencode(
                {"query": f'DOI:"{doi}"', "format": "json", "resultType": "lite"}), tries=2, timeout=20)
            for it in (r.get("resultList") or {}).get("result") or []:
                if it.get("pmcid") and it.get("isOpenAccess") == "Y":
                    add(f"https://www.ebi.ac.uk/europepmc/webservices/rest/{it['pmcid']}/fullTextXML",
                        "xml", "publishedVersion", "Europe PMC")
        except Exception as e:
            warn(f"europe pmc failed: {e}")
        if doi.startswith("10.2172/") or os.environ.get("LIT_OSTI"):
          try:
            r = http("https://www.osti.gov/api/v1/records?" + urllib.parse.urlencode({"doi": doi}), tries=1, timeout=10)
            for it in r if isinstance(r, list) else []:
                for l in it.get("links") or []:
                    if l.get("rel") == "fulltext":
                        add(l.get("href"), "pdf", None, "OSTI")
          except Exception as e:
            warn(f"osti failed: {e}")
        if setting("core_api_key"):
            try:
                r = http("https://api.core.ac.uk/v3/search/works?" + urllib.parse.urlencode(
                    {"q": f'doi:"{doi}"', "limit": 5}),
                    headers={"Authorization": f"Bearer {setting('core_api_key')}"})
                for it in r.get("results") or []:
                    add(it.get("downloadUrl"), "pdf", None, "CORE")
            except Exception as e:
                warn(f"core failed: {e}")
    return locs


def cmd_oa(a):
    m = find_entry(a.ident)
    doi = (m or {}).get("doi") or (None if ARXIV_RE.match(a.ident) else clean_doi(a.ident))
    arxiv = (m or {}).get("arxiv") or (ARXIV_RE.match(a.ident).group(1) if ARXIV_RE.match(a.ident) else None)
    locs = oa_locations(doi, arxiv)
    if not locs:
        print("no open full-text location found")
    for l in locs:
        print(f"{l['kind']:<12} {l.get('version') or '-':<18} {str(l.get('host') or '-')[:30]:<30} {l['url']}")


def safe_extract(data, dest):
    """Unpack an arXiv e-print (tar.gz, gzip'd single file, or PDF) into dest."""
    dest.mkdir(parents=True, exist_ok=True)
    try:
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:*") as tf:
            tf.extractall(dest, filter="data")
            return "tar"
    except tarfile.TarError:
        pass
    try:
        data = gzip.decompress(data)
    except OSError:
        pass
    if data[:4] == b"%PDF":
        (dest / "eprint.pdf").write_bytes(data)
        return "pdf-only"
    (dest / "main.tex").write_bytes(data)
    return "single-tex"


def cmd_fetch(a):
    m = load_meta(a.key)
    url = a.url
    d = lib_dir() / m["key"]
    if a.source or "arxiv.org/e-print/" in url:
        data, ctype = http(url, accept="*/*", raw=True)
        kind = safe_extract(data, d / "source")
        texs = sorted(str(p.relative_to(d)) for p in (d / "source").rglob("*.tex"))
        print(f"source: {kind}; tex files: {', '.join(texs[:10]) or 'none'}")
        return
    data, ctype = http(url, accept="application/pdf,text/xml,*/*;q=0.5", raw=True)
    files = d / "files"
    files.mkdir(parents=True, exist_ok=True)
    if data[:4] == b"%PDF":
        name = a.name or "paper.pdf"
        (files / name).write_bytes(data)
        print(f"saved {files / name} ({len(data) // 1024} KiB)")
        if name == "paper.pdf":
            to_text(m["key"])
    elif "xml" in ctype and b"<article" in data[:5000]:
        (files / "paper.xml").write_bytes(data)
        print(f"saved {files / 'paper.xml'} (JATS XML)")
    else:
        die(f"not a PDF (Content-Type {ctype or '?'}): probably a landing page, login wall, or bot check. "
            "Try another location or WebFetch the landing page.", 2)


def to_text(key):
    d = lib_dir() / key / "files"
    pdf = d / "paper.pdf"
    if not pdf.exists():
        die(f"{pdf} missing")
    out = d / "paper.txt"
    subprocess.run(["pdftotext", "-layout", str(pdf), str(out)], check=True)
    pages = subprocess.run(["pdfinfo", str(pdf)], capture_output=True, text=True).stdout
    n = re.search(r"Pages:\s+(\d+)", pages)
    print(f"text: {out} ({out.stat().st_size // 1024} KiB, {n.group(1) if n else '?'} pages, "
          "pages separated by form feeds)")


def cmd_text(a):
    to_text(a.key)


def cmd_pages(a):
    d = lib_dir() / a.key / "files"
    pdf = d / (a.file or "paper.pdf")
    if not pdf.exists():
        die(f"{pdf} missing")
    out = lib_dir() / a.key / "pages"
    out.mkdir(exist_ok=True)
    before = {p: p.stat().st_mtime for p in out.glob("*.png")}
    for spec in a.pages.split(","):
        lo, _, hi = spec.strip().partition("-")
        subprocess.run(["pdftoppm", "-png", "-r", str(a.dpi), "-f", lo, "-l", hi or lo, str(pdf),
                        str(out / "page")], check=True)
    made = sorted(str(p) for p in out.glob("*.png") if before.get(p) != p.stat().st_mtime)
    print("\n".join(made))


def cmd_refs(a, direction):
    m = find_entry(a.ident)
    doi = (m or {}).get("doi") or clean_doi(a.ident)
    w = openalex_work((m or {}).get("openalex") or doi)
    if not w:
        die("work not found on OpenAlex")
    if direction == "refs":
        ids = [u.rsplit("/", 1)[-1] for u in w.get("referenced_works") or []]
        print(f"# {len(ids)} references", file=sys.stderr)
        rows = []
        for i in range(0, len(ids), 50):
            chunk = "|".join(ids[i:i + 50])
            r = http("https://api.openalex.org/works?" + oa_params(
                {"filter": f"openalex_id:{chunk}", "per-page": 50, "select": OA_SELECT}))
            rows.extend(oa_row(x) for x in r.get("results", []))
        rows.sort(key=lambda r: -(r.get("cited") or 0))
        print_rows(rows[: a.limit], a.json)
    else:
        filt = [f"cites:{w['id'].rsplit('/', 1)[-1]}"]
        if a.year_from:
            filt.append(f"publication_year:>{int(a.year_from) - 1}")
        sort = "publication_date:desc" if a.sort == "date" else "cited_by_count:desc"
        r = http("https://api.openalex.org/works?" + oa_params(
            {"filter": ",".join(filt), "sort": sort, "per-page": a.limit, "select": OA_SELECT}))
        print(f"# cited by {r.get('meta', {}).get('count')} works", file=sys.stderr)
        print_rows([oa_row(x) for x in r.get("results", [])], a.json)


def bib_from_meta(m):
    authors = " and ".join(m.get("authors") or [])
    fields = {"title": m.get("title"), "author": authors, "year": m.get("year")}
    if m.get("arxiv"):
        fields.update({"eprint": m["arxiv"], "archivePrefix": "arXiv", "howpublished": f"arXiv:{m['arxiv']}"})
    if m.get("doi"):
        fields["doi"] = m["doi"]
    body = ",\n".join(f"  {k} = {{{v}}}" for k, v in fields.items() if v)
    bib = f"@misc{{{m['key']},\n{body}\n}}\n"
    ris = ["TY  - GEN" if not m.get("arxiv") else "TY  - UNPB", f"ID  - {m['key']}"]
    ris += [f"AU  - {x}" for x in m.get("authors") or []]
    ris += [f"TI  - {m.get('title')}", f"PY  - {m.get('year')}"]
    if m.get("doi"):
        ris.append(f"DO  - {m['doi']}")
    if m.get("arxiv"):
        ris.append(f"UR  - https://arxiv.org/abs/{m['arxiv']}")
    ris.append("ER  - ")
    return bib, "\n".join(ris) + "\n"


def cite_for(m):
    d = lib_dir() / m["key"]
    bp, rp = d / "cite.bib", d / "cite.ris"
    if bp.exists() and rp.exists():
        return bp.read_text(), rp.read_text()
    bib = ris = None
    if m.get("doi"):
        u = "https://doi.org/" + urllib.parse.quote(m["doi"], safe="/")
        try:
            bib = http(u, accept="application/x-bibtex")
            bib = re.sub(r"^(@\w+\{)[^,]*,", lambda x: x.group(1) + m["key"] + ",", bib.strip(), count=1) + "\n"
            ris = http(u, accept="application/x-research-info-systems").strip()
            ris = re.sub(r"^ID  - .*$", "", ris, flags=re.M)
            ris = ris.replace("ER  -", f"ID  - {m['key']}\nER  -", 1) + "\n"
            ris = re.sub(r"\n{2,}", "\n", ris)
        except Exception as e:
            warn(f"{m['key']}: DOI content negotiation failed ({e}); using stored metadata")
            bib = ris = None
    if not bib:
        bib, ris = bib_from_meta(m)
    d.mkdir(parents=True, exist_ok=True)
    bp.write_text(bib)
    rp.write_text(ris)
    return bib, ris


def cmd_export(a):
    if a.keys:
        metas = [load_meta(k) for k in a.keys]
    elif a.topic:
        metas = [m for m in all_meta() if a.topic in m.get("topics", [])]
    else:
        die("give --topic or keys")
    if not metas:
        die("nothing to export")
    out = Path(a.out).expanduser() if a.out else (ROOT / "topics" / a.topic if a.topic else Path.cwd())
    out.mkdir(parents=True, exist_ok=True)
    bibs, riss = [], []
    for m in metas:
        b, r = cite_for(m)
        bibs.append(b)
        riss.append(r)
    (out / "refs.bib").write_text("\n".join(bibs))
    (out / "refs.ris").write_text("\n".join(riss))
    print(f"{len(metas)} entries -> {out / 'refs.bib'}, {out / 'refs.ris'}")


def cmd_queue(a):
    rows = [m for m in all_meta() if m.get("queued") and (not a.topic or a.topic in m.get("topics", []))]
    if not rows:
        print("fetch queue is empty")
    for m in rows:
        link = f"https://doi.org/{m['doi']}" if m.get("doi") else ""
        why = f" — {m['status_note']}" if m.get("status_note") else ""
        print(f"- {m['key']}: {m.get('title')} ({m.get('year')}). {link}{why}")


def cmd_inbox(a):
    inbox = ROOT / "inbox"
    pdfs = sorted(p for p in inbox.iterdir() if p.suffix.lower() == ".pdf") if inbox.is_dir() else []
    if not pdfs:
        print("inbox is empty")
        return
    metas = all_meta()
    for pdf in pdfs:
        txt = subprocess.run(["pdftotext", "-l", "2", str(pdf), "-"], capture_output=True, text=True).stdout
        key = None
        for d in DOI_RE.findall(txt):
            hit = find_entry(clean_doi(d))
            if hit:
                key = hit["key"]
                break
        if not key:
            body = norm_title(txt[:6000])
            for m in metas:
                t = norm_title(m.get("title"))
                if len(t) > 20 and t in body:
                    key = m["key"]
                    break
        if not key:
            dois = [clean_doi(d) for d in DOI_RE.findall(txt)]
            print(f"UNMATCHED {pdf.name}" + (f" (DOIs seen: {', '.join(dois[:3])}; add one with `lit.py add`)"
                                              if dois else " (no DOI found; add the paper, then rerun)"))
            continue
        dest = lib_dir() / key / "files"
        dest.mkdir(parents=True, exist_ok=True)
        target = dest / "paper.pdf"
        if target.exists():
            target = dest / f"user-{pdf.name}"
        shutil.move(str(pdf), target)
        m = load_meta(key)
        m["queued"] = False
        m["user_supplied"] = True
        save_meta(m)
        print(f"{pdf.name} -> {key} ({target.name})")
        if target.name == "paper.pdf":
            to_text(key)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("init", help="create the library folders")

    s = sub.add_parser("search", help="search several databases and merge results")
    s.add_argument("query", nargs="+")
    s.add_argument("--sources", default="openalex,s2,arxiv,crossref")
    s.add_argument("--from", dest="year_from", type=int)
    s.add_argument("--to", dest="year_to", type=int)
    s.add_argument("--sort", choices=["relevance", "cited", "date"], default="relevance")
    s.add_argument("--reviews", action="store_true", help="review articles only (OpenAlex, S2)")
    s.add_argument("--limit", type=int, default=15, help="results per source")
    s.add_argument("--json", action="store_true")

    s = sub.add_parser("resolve", help="check a DOI or arXiv id; print metadata and retraction notices")
    s.add_argument("ident")
    s.add_argument("--abstract", action="store_true")

    s = sub.add_parser("add", help="add a paper to the library (DOI or arXiv id); prints its KEY")
    s.add_argument("ident")
    s.add_argument("--topic")
    s.add_argument("--key", help="override the generated key")

    s = sub.add_parser("mark", help="record read level, version, queue state, topic")
    s.add_argument("key")
    s.add_argument("--read", choices=["full-text", "abstract-only", "metadata-only"])
    s.add_argument("--version", choices=["published", "accepted", "preprint", "other"])
    s.add_argument("--queued", dest="queued", action="store_true", default=None)
    s.add_argument("--unqueued", dest="queued", action="store_false")
    s.add_argument("--topic")
    s.add_argument("--note", help="short reason, shown in the fetch queue")

    s = sub.add_parser("find", help="look up the library by key, DOI, arXiv id, or title words")
    s.add_argument("query", nargs="+")

    s = sub.add_parser("oa", help="list open full-text locations for a key, DOI, or arXiv id")
    s.add_argument("ident")

    s = sub.add_parser("fetch", help="download a PDF (or arXiv source with --source) into library/KEY")
    s.add_argument("key")
    s.add_argument("url")
    s.add_argument("--source", action="store_true", help="URL is an arXiv e-print (LaTeX source)")
    s.add_argument("--name", help="file name, default paper.pdf")

    s = sub.add_parser("text", help="(re)extract library/KEY/files/paper.txt")
    s.add_argument("key")

    s = sub.add_parser("pages", help="render PDF pages to PNG, e.g. 3,5-6")
    s.add_argument("key")
    s.add_argument("pages")
    s.add_argument("--dpi", type=int, default=150)
    s.add_argument("--file", help="PDF in files/, default paper.pdf")

    for name, hlp in (("refs", "backward: works this paper cites"), ("cites", "forward: works citing this paper")):
        s = sub.add_parser(name, help=hlp)
        s.add_argument("ident")
        s.add_argument("--limit", type=int, default=25)
        s.add_argument("--from", dest="year_from", type=int)
        s.add_argument("--sort", choices=["cited", "date"], default="cited")
        s.add_argument("--json", action="store_true")

    s = sub.add_parser("export", help="write refs.bib and refs.ris for a topic or keys")
    s.add_argument("keys", nargs="*")
    s.add_argument("--topic")
    s.add_argument("--out")

    s = sub.add_parser("queue", help="list papers the user must fetch")
    s.add_argument("--topic")

    sub.add_parser("inbox", help="file PDFs from inbox/ into the library")

    a = ap.parse_args()
    if a.cmd != "init" and not ROOT.exists():
        cmd_init(a)
    {
        "init": cmd_init, "search": cmd_search, "resolve": cmd_resolve, "add": cmd_add, "mark": cmd_mark,
        "find": cmd_find, "oa": cmd_oa, "fetch": cmd_fetch, "text": cmd_text, "pages": cmd_pages,
        "refs": lambda a: cmd_refs(a, "refs"), "cites": lambda a: cmd_refs(a, "cites"),
        "export": cmd_export, "queue": cmd_queue, "inbox": cmd_inbox,
    }[a.cmd](a)


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as e:
        die(f"HTTP {e.code} for {e.url}")
    except urllib.error.URLError as e:
        die(f"network error: {e.reason}")
