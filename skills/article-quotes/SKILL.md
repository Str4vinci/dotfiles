---
name: article-quotes
description: Extracts quotes for LinkedIn graphic cards and generates ready-to-publish LinkedIn posts for FELPT articles. Use when given article text or URL.
---

# Article Quotes & LinkedIn Post Generator

Extracts punchy quotes for cards and drafts LinkedIn posts for Future Energy Leaders Portugal (FELPT) articles.

## Flow

1. **Metadata**: Identify author/member name, publication/journal, and date (`YYMM`).
2. **Directory & Files**: Create folder `<yymm>_<person>_<journal>` (lowercase, snake_case).
   - If URL provided, create `link.md` with the link.
   - Save the generated LinkedIn post draft in `post.md`.
3. **Quote Combos (in Chat)**:
   - Output 3 to 5 combo options of 2-3 short, punchy quotes each.
   - **Formatting**: Plain text only. Do NOT use bold, quotation marks, or markdown quote blocks (`>`).
4. **LinkedIn Post (in Chat & `post.md`)**:
   - **Hook**: Context / key insight + emojis (e.g. 🔋📈, 📈⚠️).
   - **Intro**: "No seu mais recente artigo para Journal, o/a nosso(a) membro Author detalha/analisa..." (plain text names, no markdown links).
   - **Bullets**: 2-3 concise key takeaways with bold titles.
   - **CTA**: "Podem ler o artigo completo através do link no primeiro comentário.👇"
   - **Footer**: `World Energy Council | Associação Portuguesa da Energia | Mulheres na Energia` (plain text).
   - **Hashtags**: `#FELPT #APE #TransicaoEnergetica #EnergiaRenovavel` + article-specific tags as plain text hashtags (e.g. `#Tag`, not markdown links).

## Style & Constraints
- **Language**: European Portuguese (pt-PT) strictly across all outputs.
- **Unslop**: Write clean, concise, direct Portuguese without AI fluff or generic buzzwords.
- **Strict Rule**: NEVER use em-dashes (— or –). Use colons, commas, periods, or standard hyphens instead.
- **Plain Quotes**: Quotes must be clean raw text without quotation marks or bold formatting.
- **No Markdown Links in Post**: Do not insert URLs or `[Name](url)` links in the post text; keep names and tags as plain text for easy manual `@tagging`.
