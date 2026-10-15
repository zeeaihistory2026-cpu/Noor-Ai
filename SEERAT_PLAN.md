# NOOR — Seerat un Nabi (سیرت النبی) plan

Status: **research complete, no text downloaded, nothing shipped.** Built from
public web research on 2026-10-13. The legal reasoning below is practical
guidance for product planning, **not legal advice** — a local copyright lawyer
should confirm before launch.

## 1. What it is

*Seerat-un-Nabi* (سیرت النبی) is the classic multi-volume Urdu biography of the
Prophet (PBUH). Started by Allama **Shibli Nomani (d. 1914)** — he finished the
first two volumes — and completed by his student **Syed Sulaiman Nadvi
(d. 1953)**, who wrote the remaining volumes. Published 1918–1955.

## 2. Public-domain reasoning (guidance, not legal advice)

- **Volumes 1–2 (Shibli Nomani, d. 1914; published 1918 and 1920): public domain
  everywhere.** Shibli died over a century ago, and both volumes were published
  before 1929 — under the US 95-year publication term, their copyright expired
  no later than 2016. In Pakistan (life+50) they expired decades ago.
- **Volumes 3–7 (Syed Sulaiman Nadvi, d. 1953): public domain in Pakistan, grey
  in the US.** Pakistan's Copyright Ordinance 1962 grants life + 50 years, so
  protection lapsed in 2003. In the US, works *published* in 1929 or later can
  still be under the 95-year publication term (expiring 2025–2050 depending on
  the volume's exact publication year). Because NOOR is built for and launched
  from Pakistan first, volumes 3–7 are defensible to ship; if the app is ever
  marketed from the US, get a lawyer to confirm volumes 3–7 or lead with vols
  1–2 only.
- Practical stance: **ship volumes 1–2 unconditionally; volumes 3–7 with the
  Pakistan-life+50 reasoning documented** (as in this file) and an internal
  note to re-check if US launch happens.

## 3. Where the full text actually exists (found 2026-10-13)

- **Internet Archive** item
  `SeeratUnNabisallallahuAlaihiWasallamByShaykhShibliNomanir.a`
  (https://archive.org/details/SeeratUnNabisallallahuAlaihiWasallamByShaykhShibliNomanir.a):
  multiple volumes with **direct downloadable derivatives** — PDF, EPUB,
  DjVu text (`*_djvu.txt`), and hOCR (tesseract 5.3, `lang-urd`) — i.e. the
  full machine-readable text is freely fetchable, not borrow-locked.
- **Open Library** work OL12197239W catalogues the 1975 Maktaba-i-Tamir-i-
  Insaniat Urdu edition and links to the Archive scans.
- The Urdu-OCR quality is scan-grade (~90%+ word confidence bands in the
  hOCR statistics); expect to fix ligatures/Urdu typographic errors in a
  clean-up pass before bundling.
- Third-party Pakistan blog sites (thelibrarypk.com, urdunovelsmag.com)
  also host volume PDFs, but prefer the Archive as the source of truth.

## 4. What NOT to ship

- **Ar-Raheeq Al-Makhtum ("The Sealed Nectar"), Safiur Rahman Mubarakpuri
  (d. 2006): NOT public domain.** It is actively sold by Darussalam (Riyadh)
  — the English full-color edition carries ISBN 9786035001106, and the Urdu
  edition is sold by Darussalam Pakistan. Do **not** copy its text. Do not
  ship scanned PDFs of it.
- Same rule for any modern translation/commentary of the Seerat — only the
  Nomani/Nadvi Urdu original qualifies under the reasoning above.

## 5. Recommended build plan (when the PM schedules it)

1. **Library section "Seerat un Nabi":** volume list (7 vols) → chapter list
   per volume → chapter reader. Design language: Noor tokens, gold volume
   medallions, the same Reader chrome as the Qur'an reader.
2. **Text pipeline:** download the Archive `_djvu.txt`/EPUB derivatives once
   (build-time), run an Urdu OCR clean-up pass, split by volume/chapter,
   store as one JSON per volume (`assets/text/seerat_volN.json`) with
   chapter titles — never embed whole books as one blob.
3. **Attribution:** on the section landing page and every chapter header:
   "Seerat-un-Nabi — by Allama Shibli Nomani & Syed Sulaiman Nadvi (Urdu
   original, public domain)". Keep this file's legal note in the repo.
4. **Delivery:** bundled for offline (few MB per volume as text) or
   volume-on-demand download with progress; full-text search over chapter
   titles (cheap) — per-word search later.
5. **What NOT to do:** never ship copyrighted translations; never fabricate
   "scholarly explanation" text over it (label AI explanations as samples,
   per NOOR's honesty rule); brief excerpts in share cards only.

## 6. Open gates before implementation

- Final legal confirm (Pakistan counsel) for volumes 3–7.
- Build-time OCR clean-up pass (Urdu ligature fixes) — estimate 1–2 days.
- PM decision: vols 1–2 first vs all 7 at once (recommend 1–2 for launch).
