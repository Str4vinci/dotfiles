# Sources

## Built into `lit search`

| Source | Good for | Notes |
|---|---|---|
| OpenAlex | Broad coverage, citation counts, review filter, citation graph | Used by `refs` and `cites`. An API key is optional. |
| Crossref | Authoritative DOI metadata, journal coverage | Weak relevance ranking. Titles may contain HTML tags. |
| arXiv | Physics, cond-mat, eess, math, cs preprints, with LaTeX source | Results are often a later published paper too; check the DOI. |
| Semantic Scholar | Relevance ranking, open PDF links | Rate-limits without a key (HTTP 429). An `s2_api_key` raises the limit. A failure here does not stop the other sources. |

Choose sources with `--sources openalex,arxiv`. Use `--limit` per source.

## Full-text locations (`lit oa`)

Unpaywall, OpenAlex, Semantic Scholar, Europe PMC (biomedical, JATS XML), arXiv,
and CORE when `core_api_key` is set. OSTI (US DOE reports) is queried for
`10.2172/` DOIs or when `$LIT_OSTI=1`; it does not respond from some networks.

Unpaywall often lists only a repository landing page for accepted manuscripts
(for example EPFL Infoscience, KITopen, DiVA, Aalto ACRIS, Zenodo). Open the
landing page with WebFetch and find the PDF link.

## By field

- **Physics (general, condensed matter, optics):** arXiv first, then OpenAlex.
  APS, AIP, and IOP papers usually have an arXiv version.
- **Energy systems, PV, batteries, buildings:** OpenAlex and Crossref. Much
  of this work is in Elsevier journals (Applied Energy, Energy, Solar Energy,
  Journal of Power Sources), which are mostly paywalled; look for accepted
  manuscripts in university repositories. Also check working papers (RePEc,
  SSRN) and agency reports (IEA, IEA PVPS, IRENA, NREL, JRC, Fraunhofer ISE).
- **Electrochemistry and photoelectrochemistry:** OpenAlex, ChemRxiv (via
  WebSearch), ECS journals (some open access).
- **Electrical engineering:** IEEE Xplore is mostly paywalled. Search the title
  on arXiv (eess) and on author pages. Conference papers often have an author
  copy.
- **High-energy physics:** INSPIRE-HEP (`https://inspirehep.net/api/literature?q=...`)
  through WebFetch.
- **Astrophysics, solar physics, atmospheric science:** NASA ADS needs a
  token, so use WebSearch together with arXiv.

## Grey literature

Reports, standards, theses, datasheets, manuals, and regulations are not in
the indexes. Find them with WebSearch, record the issuing body, document
number, version, and date. `lit add` needs a DOI or arXiv id, so for these
write `library/<KEY>/meta.json` by hand (copy the fields of an existing entry;
set `doi: null`, `type: "report"`, and a `url`), with a key such as
`IEA2024PVPS`. Standards (ISO, IEC, IEEE, EN) are almost never
free: queue them.

## Quality signals to report

- Retractions and corrections: `lit resolve` shows them.
- Preprint vs. published: check whether an arXiv paper has a DOI and a later
  journal version, and which version you read.
- Venue: be careful with unknown publishers and journals with very short
  review times. Say why you are wary rather than silently dropping the paper.
- Citation counts depend on age and field. Use them to find anchors, not to
  judge whether a result is correct.

## Settings

`lit.py` reads `~/Documents/literature/config.json` (outside every
repository), or `LIT_<NAME>` environment variables:

```json
{ "mailto": "contact email for API polite pools; Unpaywall requires it",
  "openalex_api_key": "", "s2_api_key": "", "core_api_key": "" }
```

Never copy these values into the skill, a note, or any repository.
