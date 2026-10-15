# NOOR AI Companion — Senior UX/UI + Frontend Engineering Review

**Reviewer role:** Senior UX/UI Designer & Senior Frontend Engineer (industry-level design review)
**Date:** 2026-10-08 · **Scope:** all 42 design pages — app captures (`previews/*.png`, 390×844) vs design PNGs, plus full code read of `lib/` (theme, shared widgets, 43 screen files, data services)
**Nature of this document:** review only — nothing was fixed in this pass.

## How to read this

- **Critical** = ship-blocker: wrong/misleading content, broken core purpose, or a failure a user will hit immediately.
- **Major** = will be felt by most users or breaks a design-system rule repeatedly.
- **Minor** = noticeable to a trained eye, erodes polish/trust.
- **Nitpick** = micro-detail; matters only because this product aims at pixel-perfect.
- Every finding names its evidence (what is visible in the capture or present in code) and a recommended fix.

**Fair caveats before the criticism:** the captures render in Roboto, not the app's Manrope, and the capture font has no Arabic/Urdu glyphs — so Arabic/Urdu appears as boxes in the *pictures*. That is a capture artifact, **but** the code finding underneath it (no bundled Arabic/Urdu font anywhere) is real and is treated as such below. Captures also show only the first viewport of scrolling screens. No physical-device run exists yet, so nothing device-only is judged as proven.

---

# 1. Executive verdict

**The honest senior verdict: this is a strong visual build with a weak system underneath it.** Screen-by-screen it looks close to your design — often very close — and a real user would call it beautiful. An industry reviewer, however, finds that the screens behave like 42 individually-crafted pictures rather than one product: the same fact (date, prayer time, location, avatar) changes from screen to screen, typography is set by eye on each screen instead of from one scale, and several "finished" screens still contain placeholder sentences, dead buttons, or numbers that contradict each other.

### Scorecard (10 = shippable at industry standard)

| Lens | Score | One-line reason |
|---|---|---|
| Visual fidelity to your design | 8/10 | Most screens genuinely close; artwork now sits correctly in its boxes |
| Visual design craft (spacing/hierarchy) | 7/10 | Calm, premium feel; flattened by everything-bold typography |
| UX coherence (one product, one truth) | 5/10 | Dates/times/location/avatar disagree across screens; dead controls |
| Typography system | 4/10 | 36 ad-hoc sizes, theme text styles almost never used, no Arabic/Urdu fonts |
| Accessibility readiness | 4/10 | Contrast failures at small sizes, tiny targets, no semantics, font-scaling breakage |
| Frontend engineering discipline | 6/10 | Good tokens exist but are bypassed; duplicated card code; honest labels are a real strength |

### Finding counts (this review)

- **Critical: 7 themes** (several recur across many screens)
- **Major: ~30**
- **Minor: ~45**
- **Nitpick: ~20**

### The 7 Critical themes

1. **Arabic/Urdu typography has no foundation in code.** There is no `fontFamily` declaration anywhere in `lib/` and no bundled Arabic/Urdu font. Every Arabic/Urdu `Text` depends on whatever the phone falls back to, with Latin line metrics. For an app whose core is Qur'anic text, this is the single biggest risk: clipped diacritics and broken line-breaking will differ per device.
2. **The Reader's offline fallback shows the wrong ayah.** The header says *Al-Kahf, Ayah 18*, but the built-in fallback Arabic + English text is the famous "Do the people think they will be left alone…" excerpt — which is from a different Surah (29:2). Live data replaces it when online; offline, the app presents mismatched sacred text under the wrong heading. In this product category, that is a trust-destroying class of bug.
3. **Truth changes between screens.** Home implies Karachi sample data; Salah Tracker shows "Sunday, 21 Jan 2024" paired with "12 Sha'ban 1448 AH" (those two dates do not correspond); Worship shows "Makkah, Saudi Arabia · 21 Jun 2024"; Reminder Center prayer times (Fajr 5:07 AM, Asr 4:11 PM) disagree with Salah Tracker (5:32 AM, 3:58 PM); Qibla's location card is labelled Makkah with Makkah's coordinates while its caption says Karachi. Each screen is internally pretty; together they are incoherent.
4. **Qibla screen is semantically wrong in ways a senior reviewer cannot pass.** The location card presents *Makkah's* coordinates as if they were the user's location; the dial shows "W" both in the top pill and again on the left, with "E" hidden under the needle; and a stale developer caption — "(device location arrives in Phase 9)" — is visible to users two phases later.
5. **The Hifz heatmap contradicts itself.** Tiles encode strength by colour alone with **no legend** (the legend was removed for design fidelity — a fidelity-over-usability error), and Page 5 is coloured dark green ("strong") while the insight card directly below says "Page 5 caused errors in 3 recent tests."
6. **Placeholder/developer copy is visible in production UI.** Reader Tafsir card: *"A one-line preview appears here in the full app, drawn from a licensed tafsir source."* Share Export tells users sharing "is wired in a later phase." Splash shows **Enter NOOR** and **Loading…** simultaneously — "tap me" and "wait" at once.
7. **31 dead controls.** `onPressed: () {}` / `onTap: () {}` appear 31 times across 23 files (overflow menus, bookmark/settings icons, Log Out, reader skip buttons, Mushaf actions…). Every dead tap teaches the user the app is a facade. This is the fastest trust-killer in the build.

### What is genuinely good (credit where due)

- The emerald/gold/cream identity is disciplined; gold is reserved for references and sacred labels rather than sprayed.
- Live prayer/Qur'an services, real audio plumbing, working reminders wiring, and — rare and commendable — **honest in-app labelling** ("Sample answers (offline)", scholar-consult note, reel preview-only wording). This honesty is a product asset; keep it.
- The image-fit pass worked: artwork now sits in its boxes; Home, Salah, AI Home, Journey and Settings are close to industry-polished.
- Shared components (`NoorCard`, `NoorPrimaryButton`, `NoorOptionTile`, rosette badges) show the right instinct — they are just not used consistently enough yet.

---

# 2. Cross-cutting findings (system level)

## 2.1 One product, one truth — data coherence

| Fact | What the captures show | Severity |
|---|---|---|
| Today's date | Salah/Dua/Hadith: "12 Sha'ban 1448 AH · Sunday, 21 Jan 2024" (internally impossible pairing); Worship: "21 Jun 2024 · 14 Dhu al-Hijjah 1445 AH"; Home: Hijri only | Critical |
| Prayer times | Salah: Fajr 5:32, Asr 3:58 PM · Reminders: Fajr 5:07, Asr 4:11 PM · Worship: Fajr 04:12 AM, Zuhr 01:05 PM — three different "todays" | Critical |
| Location | Home/Qibla captions imply Karachi; Worship header says "Makkah, Saudi Arabia"; Qibla card shows Makkah's coordinates | Critical |
| Next prayer | Home: ASR 03:46 PM · Salah: Asr highlighted 3:58 PM · Worship: Zuhr 01:23:45 countdown (countdown unlabelled) | Major |
| User identity | Home: mosque-photo avatar · Profile: "AK" monogram · Settings: gold mosque icon — three avatars for one user | Major |
| Continue Reading | Quran Home: Al-Baqarah card carrying an **Al-Kahf calligraphy roundel**; Page 11/02 disagree on which surah is "current" (Al-Baqarah vs Al-Kahf Ayah 18, 76%) | Major |
| Tasbih progress | "Allahu Akbar 21 / 34" against a 33-target system; planner bars all ~65% regardless of minutes; heatmap Page 5 colour vs text | Major |

**Fix (one sentence):** a single app-wide state source for date/times/location/profile/progress, with sample data quarantined behind one clearly-labelled demo mode. This is P0 architecture, not polish.

## 2.2 Contrast (WCAG) — measured

Computed ratios for the actual token pairs used at small sizes:

| Pair (as used) | Ratio | AA for small text (4.5:1) |
|---|---|---|
| Muted `#6D7F73` on cream | 3.87:1 | ✗ Fail — and this is the app's default caption colour |
| Muted on white cards | 4.26:1 | ✗ Fail (marginal) |
| Gold `#D4AF37` on white | 2.10:1 | ✗ Fail — anywhere gold carries words on white, it is decorative only |
| Gold-soft `#C8A96A` on white | 2.25:1 | ✗ Fail |
| White on emerald `#0F5132` | 9.36:1 | ✓ Excellent |
| Gold on emerald-dark | 5.80:1 | ✓ Pass (large/bold) |
| White-70% sublabel on emerald-dark | ~7.3:1 | ✓ Pass |
| Ink on cream | 15.49:1 | ✓ Excellent |

The palette is fine; its *assignment* is not. Small text in muted/gold-on-white fails everywhere it carries information (counts, timestamps, metadata, streak labels).

## 2.3 Touch targets & interaction affordances

- **41 `GestureDetector`s** (no ripple, no semantics) vs Material ink responses elsewhere — two interaction dialects; the counter circle, pill tabs and several cards feel "dead" to press.
- Sub-44dp targets recur: Skip text (37), pill tabs ~36dp high (11/02), overflow/bookmark icons ~20dp glyphs (01 cards, 04 toolbar labels at 10.5px), audio side transports ~32dp (05), Forgot password / footer links ~20dp tall (41/42).
- **Dead controls:** 31 empty handlers (see Critical #7).

## 2.4 Scroll, below-fold, and empty space

- No consistent rule: some lists peek a cut row (18, 34), some end in a large cream void (33, 22), Home cuts the Hadith card *at* the nav bar, AI Home cuts its bottom banner mid-card.
- Auth screens (41/42) strand the CTA mid-screen with a void below; Splash has a ~35% dead gap between tagline and button; Hifz Results/Planner end in voids after one button.

## 2.5 Selected-state dialects

Three different "selected" languages coexist: filled dark pill (chips), full dark block (Reel styles, Goal/Madhhab rows), and **bold green text only** (Card Editor groups — nearly invisible as a state). One canonical pattern is needed.

## 2.6 Accessibility & semantics

- `Semantics`/`semanticLabel` is used **once** in the entire app. Icon-only buttons, the tasbih counter, heatmap tiles and switches are effectively unlabelled for screen readers.
- Colour-only meaning: heatmap (Critical #5), streak flame rows (4 lit + 1 near-invisible pale flame for 12/8/17-day streaks — the flame count is identical regardless of the number), reminder toggles all-ON with no lead-time text ("Fajr −15 min" exists in the plan, not on screen).
- Font scaling: tested nowhere. `FittedBox(scaleDown)` in `NoorOptionTile` actively shrinks text (long labels already render smaller — e.g. Goal tiles) and will fight the OS text-size setting the app itself offers on Page 13.
- Only ~32 of 476 text styles set an explicit line height; the rest inherit ~1.3 — dense for 13px body text, dangerous for Arabic (see §3).

## 2.7 Iconography

- Line-icon set is consistent in stroke, but **meaning** is loose: the same mosque glyph stands for all five prayers on Salah (changing only in shade); identical sun icons for Fajr/Sunrise/Dhuhr/Asr/Maghrib on Worship; a red notification dot is the only red UI in the app; the "Tt" glyph on Settings renders like a font accident (design: "Aa").
- Home's avatar is a mosque photograph where a *user* avatar belongs; it reads as a second app icon, not as Abdullah.

---

# 3. Typography audit (dedicated section, as requested)

Typography is where this build most clearly shows it was assembled screen-by-screen. The design intent is good — a calm Manrope system with gold reserved for sacred references — but in code the system barely exists.

## 3.1 Measured evidence (from `lib/`, counted, not guessed)

| Metric | Evidence | Verdict |
|---|---|---|
| Distinct `fontSize` values in screens/widgets | **36** (9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5, 16, 16.5, 17, 17.5, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 32, 36, 40, 44, 54…) | No type scale — sizes chosen by eye per screen |
| Theme text styles actually consumed | `noor_theme.dart` defines 5 roles (28/800, 20/800, 16/700, 14/400, 12) — screens reference `textTheme` **once** in 43 screen files | The theme is decorative; every screen hand-rolls its typography |
| Weight distribution | w800 ×112, w700 ×98, w600 ×41, w900 ×6, w500 ×1, w400 ~only in theme | **82% of all text is bold or heavier.** Hierarchy collapses to size + colour; nothing whispers |
| Half-point sizes | 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5 all in production use | Fit-by-eye tuning; invisible to users, fatal to rhythm and maintenance |
| Line height | Explicit `height:` on ~32 of 476 `Text` styles (~7%) | Multi-line body defaults to ~1.3 leading; Arabic styles mostly have **no** leading at all |
| Letter-spacing (tracking) | 10 sites, values 0.6 / 1.1 / 1.2 / 1.4 / 1.6 / 2.0 | Eyebrow style re-invented each time (see 3.3) |
| `fontFamily` declarations | **Zero** in `lib/` — Latin inherits Manrope theme; Arabic/Urdu inherit *whatever the phone chooses* | Critical for Qur'anic text (see 3.4) |
| Numeric figures | No `tabularFigures` anywhere; times/countdowns/progress use proportional figures | Countdowns and timers will visibly jitter/shift as digits change |

## 3.2 Font family findings

- **Latin — Manrope (correct choice, unevenly applied).** Manrope is a good, modern, highly legible family for this product and matches the design's rounded-geometric feel. But because screens hardcode `TextStyle`s, Manrope is applied by inheritance luck rather than by system; the one place a `styleFrom` text-style overrode it (primary buttons) already caused a silent fallback-font bug in an earlier phase. **Recommendation:** keep Manrope; make it structurally unavoidable via tokens.
- **Arabic (Qur'anic text) — no font at all (Critical).** Nothing bundles Amiri, Scheherazade, or a QPC Uthmani font. On a real phone the Arabic will render in the device's default Arabic font with Latin-derived line metrics. For Uthmani script with full diacritics this risks clipped marks, uneven baselines, and justification that differs per phone — in the one app category where the text itself is sacred and must be beyond reproach. The Reader partially compensates (`height: 1.7`); Home, Dua (30px, **no height**), Hadith (27px, **no height**), and the Mushaf excerpt (15.5px, no height) do not.
- **Urdu — Nastaliq expectation unmet (Critical).** Urdu readers expect Nastaliq, whose tall ascenders need ~2.0–2.1 line height. The Reader's Urdu block is fixed at 15px / height 1.9 in a Naskh-style fallback and — worse — **ignores the Text Size slider entirely** (Arabic scales `_textSize + 2`, English scales `_textSize − 5`, Urdu is constant). A user who enlarges text for accessibility gets a bigger Arabic, a possibly-tiny English (at slider minimum the English computes to ~11px), and an unchanged Urdu.

## 3.3 Role-by-role audit

| Role | What is actually used | Finding |
|---|---|---|
| Display / hero numbers | 93% (48), 268° (~56), 27 (~64), streak counts | **The best typography in the app.** Big, confident, well-contrasted. Keep as the model. |
| Screen titles | 19–28px w800, varying (dark headers ~21–24, auth 26, onboarding 23–26) | Same role, five sizes. Users won't name it, but the app feels unsettled. |
| Section headers | 16–20px w700–w800; eyebrow style varies: ALL-CAPS tracked (Home, Tasbih) vs Title Case (most) vs non-caps eyebrow (Journey "This Week") | Three dialects for one job. |
| Eyebrows / labels | 10.5–13px caps with tracking 0.6–2.0 | No token; gold eyebrows on white fail contrast (2.1:1). |
| Card titles | 14.5–17px w700/w800 | Overweight relative to body; everything "shouts" (see weight census). |
| Body | 13–15px, usually w400 only by accident; frequently grey `#6D7F73` at 13–14px | Primary meaning carried in a failing-contrast colour (Madhhab positions, Voice transcript, Hadith context). Body should be ink; grey is for metadata. |
| Captions / metadata | 10.5–13px muted, several below 11px (Mushaf toolbar 10.5, audio labels 11) | Below comfortable reading size; AA fail on cream/white. |
| Buttons | Primary 16px w700 (good); text links ("Forgot password?", footers) ~13px with ~20px tap height | Button label casing consistent (Title Case verbs — good); link targets too small. |
| Numbers / times | Proportional figures everywhere; formats drift (`03:46 PM` vs `3:58 PM` vs `04:12 AM`; `1h 18m` vs `01:23:45` unlabelled) | Tabular figures + one time-format rule needed. |

## 3.4 Arabic / Urdu typographic requirements (currently unmet)

1. Bundle a Qur'an-grade Arabic font (Amiri Qur'an / QPC Uthmani) and Noto Nastaliq Urdu; declare `NoorType.arabic` (≥20px, height 1.9) and `NoorType.urdu` (≥15px, height 2.1) as the *only* ways to render sacred text.
2. Every Arabic block gets explicit height — the four screens missing it (Home snippet, 08, 09, 04) are clipping risks today.
3. Mushaf (Page 04) needs fixed line-height geometry (16 identical lines, justified) — current flexible ruled lines cannot hold a real page.
4. Baked-in text inside images (Page 11 banner) cannot respond to the Text Size setting or screen readers; live text over artwork is the accessible pattern.

## 3.5 Casing, truncation, and micro-copy typography

- **Casing chaos (Minor, systemic):** "View All" vs "View all"; Notification titles mix sentence case ("Fajr reminder", "Hifz plan") with Title Case ("Daily Dua") *in the same list*; Saved tags mix "Saved Ayah" / "Quran note". One rule fixes all: Title Case for titles/tags, sentence case for body.
- **Truncation cuts meaning (Major where it bites):** "Keep going, Ab…" (the user's own name, cut mid-word — personalisation that insults), AI Recent Conversations titles cut at ~24 chars ("Is it permissible to fast …"), Hadith search placeholder cut mid-word ("…keyw…"), "Al-Kahf" split across lines in the Reader mini player. Policy needed: one-line ellipsis for titles only, wrap for translations, never shrink-to-fit.
- **Shrink-to-fit is in production:** `NoorOptionTile` wraps labels in `FittedBox(scaleDown)` — Goal tiles already render long labels at a visibly smaller size than short ones in the same grid. This silently overrides user font scaling.
- **Placeholder sentences styled as content:** the Reader's Tafsir preview line and similar notes are set in the same body style as real content, so users cannot tell product from scaffolding.

## 3.6 Proposed type scale (what to lock in `noor_theme.dart`)

| Token | Size / weight / leading | Use |
|---|---|---|
| `display` | 32 / w800 / 1.1, tabular | Hero numbers only (93%, 268°) |
| `screenTitle` | 22 / w800 / 1.2 | Dark-header titles, auth/onboarding H1 (one size, finally) |
| `section` | 17 / w700 / 1.25 | Section headers |
| `cardTitle` | 16 / w700 / 1.3 | Card & row titles |
| `body` | 14.5 / w400 / 1.5, ink | All primary reading text |
| `secondary` | 13.5 / w500 / 1.45, `#4F6355` (muted-dark) | Descriptions that carry meaning |
| `meta` | 12.5 / w600 / 1.35, `#4F6355` | Counts, timestamps (≥4.6:1 on cream) |
| `eyebrow` | 11 / w700 / tracking 1.4, caps, emerald-dark (gold only on emerald) | NEXT PRAYER, DUA OF THE DAY… |
| `button` | 16 / w700 | Primary/secondary buttons |
| `arabic` | 22 / w400 / 1.9, Amiri/QPC | Qur'an & Arabic dua/hadith |
| `urdu` | 16 / w400 / 2.1, Noto Nastaliq Urdu | Urdu translation/rows |
| `numeric` | any size + `tabularFigures` | Times, countdowns, streaks, % |

Rules that accompany the scale: body text is ink, never muted; muted is metadata-only and darkened to `#4F6355`; gold text only on emerald or at ≥18px bold; no half-point sizes; no `FittedBox` shrink on text; every style names its line height.

---

# 4. Frontend engineering review

| Area | Evidence (counted in code) | Judgement |
|---|---|---|
| Colour tokens | 94 hardcoded `Color(0x…)` in screens/widgets outside the theme; near-identical hairlines re-invented per file (`#E3DED0`, `#E9E2D2`, `#EFE9DB`, `#F0EDE2`…) across 18 files | Tokens exist and are good; discipline is not enforced. One hairline token would delete most of these. |
| Spacing tokens | 228 raw `EdgeInsets` vs the `NoorSpacing` scale | Same story: rhythm holds by habit, not by system. |
| Typography tokens | See §3.1 — 36 sizes, theme used once | Weakest discipline in the codebase. |
| Component reuse | Shared widgets are good but list-row/card anatomy is re-implemented per screen (Settings grouped rows vs Profile loose rows vs Saved rows — three anatomies for the same job) | Extract one `NoorListRow`; deletes hundreds of lines and the visual drift with them. |
| Accessibility semantics | 1 `Semantics` use in the whole app; 41 `GestureDetector`s without labels/ripple | Major gap. Counter, heatmap, switches, icon buttons need labels; prefer InkWell/Material. |
| Dead affordances | 31 empty handlers across 23 files | Critical (see §1). Either wire, hide, or visibly disable every control. |
| Font-scaling safety | `FittedBox(scaleDown)` on option labels; dozens of fixed heights (54× `height: 12` spacers etc. are fine; fixed *content* heights + 200% text scale are untested) | Run the whole app at 200% text scale before release; expect breakage on Goal/Language rows and streak cards. |
| RTL readiness | 31 hardcoded left/right alignments/paddings; no `Directionality` work outside Reader/Urdu blocks | An Urdu/Arabic UI locale will mirror incorrectly in headers, rows and the mini player. |
| Image pipeline | No `cacheWidth/cacheHeight` anywhere (0 uses); assets total only ~1.2MB, largest 132KB | Performance is *fine today* (credit), but full-res decode of banners at small sizes wastes memory on low-end phones; add cache sizing when images are placed. |
| Asset quality | Hadith covers and several crops are soft/low-resolution (cropped from 864px design sheets); the Page 15 covers show garbled pseudo-text at reading size | Re-export artwork from the original design source at 2–3×, or switch covers to text-free art (titles already exist as captions). |
| Data architecture | Each screen carries its own sample numbers (root cause of §2.1); services (prayer/Qur'an) are real but screens don't share one state | Introduce one app state (profile, today, progress) consumed by all screens; sample data behind a single demo flag. |
| Honesty patterns | Offline/sample labels, TODOs that throw instead of faking, no fabricated photos/alarm claims in code comments | Genuinely good engineering ethics. Extend the same honesty to visible UI copy (remove phase notes like "arrives in Phase 9"). |
| Testability | Preview/golden captures exist for all 42 screens — a real asset; but captures run on a fallback font, so they cannot catch Arabic clipping | Add one golden with the real Arabic font + longest-string/Urdu fixtures per screen. |

---

# 5. Per-page findings

Format: **Severity · Category** — finding (evidence). *Fix.*

## Entry flow

**36 Splash** — **Major · UX** Enter NOOR button *and* "Loading..." shown together — contradictory instructions; stray hairline artefact under the tile; ~35% dead space above the button; the NOOR wordmark sits high in its tile rather than centred. *Auto-advance with a real progress state; button only as an error fallback; centre the lockup.* **Minor · Typography** tagline 14.5px muted on cream ≈3.4–3.9:1 fails AA. *Ink-60% or 15px.* Good: calm hierarchy matches the design's intent.

**37 Onboarding** — **Major · Visual** hero is a pale disc (~1.1:1 edge contrast against the page) with the word QURAN; on a bright phone it nearly vanishes. *Use the design's artwork or a sand hairline + inner depth.* **Minor · UX** Skip target <44dp; no page dots/progress for a multi-step flow. Good: single 58dp Continue, generous breathing room.

**38 Goal Selection** — **Major · Typography** `FittedBox(scaleDown)` shrinks long labels ("Salah consistency") to ~11px effective while short labels stay large — same grid, different sizes; hostile to font scaling. *Allow 2 lines at a locked size.* **Major · UX** Continue is always enabled with 3 goals pre-selected and no "n selected" feedback — the choice architecture is unclear. **Nitpick** title size (23) drifts from sibling screens (24/26). Good: grid rhythm and gaps match the design.

**39 Language Selection** — **Major · Typography/RTL** Urdu/Arabic rows have no dedicated font or line height (Nastaliq will clip/misalign); rows force LTR layout on RTL language names; selected row's right-hand gloss is white-70% on emerald (weak). *Per-locale fonts + directionality; gloss at 90% white.* Good: tall rows, clear selected state.

**40 Madhhab Preference** — **Minor · Visual** selected radio reads as a plain white disc (no inner mark) — users may read it as decoration; subtitle muted 14px on cream fails AA. *Add a centred emerald dot inside the selected ring; darken subtitle.* Good: "Show all / I'm not sure" escape hatches preserved — responsible design.

**41 Create Account** — **Major · UX** no password show/hide, no strength or error states; the grey hint text inside fields (a person's name as placeholder) reads as pre-filled data. *Eye toggle ≥44dp, inline errors, neutral placeholders ("Your name").* **Minor** input radius uses card 20 while the theme's input token (28) sits unused; footer link tap height ~20dp. Good: spacing rhythm, single CTA.

**42 Login** — same field findings as 41. **Minor · Visual** form ends mid-screen with a large void below; "Forgot password?" target too short. *Anchor the footer to the safe area; pad links to 44dp.* Good: mirrors Create Account cleanly, low cognitive load.

## Home & daily

**01 Home** — **Critical · Typography/Contrast** muted text at 11–13.5px carries real information across the whole screen (streak labels, meta) at 3.2–3.9:1. **Major · UX** first viewport cuts the Hadith card at the nav bar and pushes Continue Quran/AI entirely below the fold with no scroll cue; the streak flame row (4 lit + 1 near-invisible pale) is identical for 12, 8 and 17-day streaks — decoration pretending to be data. **Minor** mosque-photo avatar reads as an app icon, not the user; the red notification dot is the app's only red; countdown in proportional figures will jitter. *§3.6 tokens; shrink hero card; outline the unlit flame; tabular figures.* Good: greeting/Hijri hierarchy and hero artwork fit are genuinely polished.

**08 Dua of the Day** — **Major · Typography/RTL** Arabic at 30px with **no line height and no Arabic font** (see §3.4). **Minor** medallion renders as a soft oval with an offset crescent shadow — reads as a rendering error; "About this Dua" attributes the 20:114 wording to Prophet Musa (A.S) — *verify this attribution against the sourced text before release; on-screen religious explanations must be source-checked, not design-copied.* The three "More Duas" cards have visibly uneven heights/baselines. Good: transliteration → translation → source hierarchy.

**09 Hadith of the Day** — **Major · Visual** emerald header + art strip + overlapping card creates a cramped seam; medallion again oval/soft. **Major · Typography/RTL** Arabic 27px, no height/font. **Minor** "Full text, chain and grading load from the verified source at runtime" is scaffolding language sitting in a devotional screen. Good: source line visually distinct from the text — exactly right for this content.

## Qur'an

**11 Quran Home** — **Major · Content** Continue Reading pairs **Al-Baqarah** with an **Al-Kahf calligraphy** roundel — the wrong surah's art on the card (and Pages 11/02 disagree on the current surah). **Major · Below-fold** banner + header consume the viewport; Listen/Daily Verse/Quick Actions invisible without scrolling. **Major · Visual** the banner's verse is baked into the image — it cannot scale with text settings, be read by a screen reader, or be corrected without new art. **Minor** pill tabs ~36dp high; list meta muted at 12.5px. Good: the illustrated banner (the design's own art) and Read Now affordance.

**02 Surah List** — **Major · UX** the mini player overlays and hides the 5th row with no bottom inset. **Major · Typography/RTL** Arabic surah names (18px, no font/height) sit on a different baseline system than the two-line Latin stack; fixed ~72dp rows will squeeze real Nastaliq/Uthmani. **Minor** filter label/value hierarchy inverts contrast rules; list/grid toggle icons have no selected state shown. Good: rosette badges are a faithful, legible signature element.

**03 Quran Reader** — **Critical · Content** offline fallback text (Arabic + English) is the 29:2 excerpt displayed under an **Al-Kahf · Ayah 18** header (see §1). **Critical · Typography** Urdu ignores the Text Size slider; English can compute to ~11px; Urdu has no Nastaliq font (height 1.9, needs 2.1). **Major · UX** a placeholder sentence is presented as the Tafsir preview ("A one-line preview appears here in the full app…"); segmented tabs and Text Size sit at ~36dp; the mini player wraps "Al-Kahf" mid-word and truncates the reciter name across two lines. Good: Quick Tools row, source attributions under each translation, live/offline honesty in structure.

**04 Hifz Mushaf** — **Critical · Visual/UX** fifteen empty ruled lines + one excerpt line reads as a broken/loading page, not a Mushaf; there is no skeleton, watermark, or loading language to tell the user what this state is. **Major · Typography** a real 16-line page needs locked line geometry and a Mushaf-grade font; flexible dividers cannot hold it. **Minor** bottom toolbar labels at 10.5px; Previous/Next cards are mostly dead space. Good: page frame/border language and honest source note.

**05 Audio Player** — **Major · Visual** dark sliver artefacts at the arch card's top corners (fit residue the fit-pass missed); the full player *and* a duplicate mini player for the same track stack on one screen. **Major · Typography** elapsed/total times in proportional figures (12px white-70%) will jitter every second; "Reciter" label ~3:1 on emerald. **Minor** prev/next and Repeat targets ~32dp vs the excellent 64dp play button; "Repeat" vs "Repeat Ayah" iconography is near-identical. Good: the 5-up Speed/Timer/Sleep/Download/Share tiles and dark focus match the design's intent.

## Worship

**14 Worship Dashboard** — **Critical · Data** header asserts "Makkah, Saudi Arabia · 21 Jun 2024" while the rest of the app asserts Karachi/other dates (§2.1). **Major · UX** countdown "01:23:45" has no label (countdown? duration?); identical sun icons for five different prayers; prayer rows sit card-less on cream while every other list in the app is carded. **Minor** the overlapping quote card's top corners clip into the header art. Good: 18px section-header rhythm is the app's most consistent.

**06 Salah Tracker** — **Critical · Data** "12 Sha'ban 1448 AH" paired with "Sunday, 21 Jan 2024" — the two calendars contradict each other on the app's most time-sensitive screen. **Major · Visual** all five prayers use the same mosque glyph (only shade changes) — the icon carries no information; the highlighted Asr column is taller than the others, knocking all five time labels off a shared baseline. **Minor** streak line carries a stray glyph artefact after the name; "Completion Rate / This Month" wraps at ~1.15 leading. Good: 91% / 28 / 3 stat row scans instantly; tap-to-log checks are clear.

**07 Zikr Tasbih** — **Major · Typography** "Keep going, Ab…" — the user's own name truncated mid-word; the horizontally-peeking third dhikr card is clipped mid-word ("La ilal / There i…") with no fade cue. **Major · UX** the drawn bead arc shows ~8 fixed beads regardless of 27/33 — progress is communicated only by the number (the number hierarchy itself is the app's best). 21/34 count contradicts the 33-target system. **Minor** Undo/Add labels sit far from their buttons' visual weight. Good: target pills (33/66/99/100/Custom) are properly sized and labelled.

**31 Reminder Center** — **Major · Data** times disagree with Salah Tracker (§2.1). **Major · UX** every switch is ON (eight identical green toggles) with no lead-time shown — the Fajr "−15 min" logic exists in the plan but not on screen, so the screen promises less than the app does and teaches users that ON is meaningless. **Minor** oversized non-standard switch proportions vs the Settings switches elsewhere (two switch dialects). Good: the row rhythm (label/time/toggle ×8) is the most disciplined list in the app.

**10 Qibla Finder** — **Critical · UX/Content** (see §1 #4): Makkah's coordinates labelled as the location; duplicated "W" (pill + dial) with "E" hidden under the needle; stale "(device location arrives in Phase 9)" caption in production copy. **Major** direction is given as "W" three times in three forms (268° / Qibla • W / "to your W") without ever spelling "West"; the mode tiles (Compass/AR/Sun/Map) present AR and Map as peers although neither exists yet — label coming features or remove them. Good: the 268° hero numeral is exemplary, and the live bearing being *different* from the design's printed 295° is correct behaviour, correctly reasoned.

## AI

**12 AI Assistant Home** — **Major · Visual** a hard vertical seam where the dome artwork begins slices the header in two; the greeting's trailing glyph artefact (capture font) aside, the dome edge crowds the title. **Major · Typography** Recent Conversations titles truncate at ~24 chars and subtitles truncate too — history becomes unsearchable by eye. **Minor** suggested-question cards have uneven heights (2-line vs 3-line wraps share a grid); hamburger (☰) here vs back chevrons everywhere else. Good: greeting → ask-bar hierarchy; preview lines under titles (added in Phase 11) are the right pattern.

**23 AI Chat** — **Major · Trust** the header claims "Trusted Islamic guidance" while the strip below admits "Sample answers (offline)" and an answer asserts "Here are **verified** references…" — three trust levels on one screen. *Until a sourced backend exists, the header claim and the word "verified" must go; the offline strip (good, keep verbatim) is the honest ceiling.* **Minor** both bubbles fully rounded on all corners (no speaker tail direction); second user bubble wider than the first; "Show sources" affordance relies on colour+icon alone. Good: bubble contrast and 1.4+ leading.

**24 AI Answer Sources** — **Minor · Hierarchy** "AI Explanation" (17px) outranks its own "Sources" label (15px) — evidence should be visually subordinate or equal, never smaller-and-later; "High source confidence" is asserted with no basis shown (what makes it high?). Good: exact citation pill (17:79 · Muslim 1163) in tabular-friendly type; outline action rows are consistent.

**25 Compare Madhhab Opinions** — **Major · Typography** the actual rulings are set in 14px muted grey on white (~4.0:1) — the most consequential text in the app gets caption treatment. *Body ink; grey is for metadata.* **Minor** all four cards identical weight/size — correct for equal standing (credit), but Hanbali's "Has conditions and scholarly detail" is visibly thinner content than its peers and reads as unfinished. Good: "Your preference / Recognized view" badges distinguish by words, not colour; scholar-consult note present.

**26 Voice AI Companion** — **Major · State** the screen sits in a permanent "Listening…" with a static waveform and no visible stop/cancel control in the first viewport — a listening state without an exit reads as a stuck app (and the mic is UI-state only, so the state is also untrue). **Minor** recognised-speech transcript in grey-green on mint ≈3.5:1 — the user's own words get the weakest contrast on the screen. Good: state is labelled in words, not colour alone; "Try asking" rows are honest, thumb-sized suggestions.

## Hifz

**27 Hifz AI Test** — **Major · Trust/UX** "AI listens and follows your recitation" is stated as fact on a screen whose listening is UI-state only (disclosed in code, not on screen). On a religious-accuracy feature this overclaim matters: label it self-check/demo until speech analysis exists. **Minor** the RECITE disc's drop shadow is offset so the circle reads as floating off its base; no range-edit affordance despite "Test range" being the screen's premise. Good: 24px tracked RECITE + plain subtitle is clear CTA typography.

**28 Hifz Test Results** — **Major · Data** "93%" hero vs three flagged ayahs (38/40/42) vs AI suggestion referencing "page 26" while the test range was Pages 25–28 — the numbers never quite agree with each other. **Minor** Review and Practice pills are styled identically although they are different actions (see vs drill); the screen ends in a void under one outline button. Good: error-type labels ("Missed one word") beside each ayah — precise, scannable, humane.

**29 Hifz Revision Planner** — **Major · Data-viz** three progress bars with identical ~65% fill and no percentage or x/y anywhere; minutes (10/7/8) don't explain the bars. **Minor** "Old revision · Juz 30" inside a Juz 1 planner contradicts the header scope; the closing CTA outweighs every other element on the screen. Good: fraction glyph (½ page) renders correctly; title/minute right-edge alignment is clean.

**30 Hifz Weak-Page Heatmap** — **Critical · Data-viz** colour-only encoding with **no legend** (removed for fidelity — usability must win), white numerals on sage tiles ≈2.8:1, and the Page 5 colour/text contradiction (§1 #5). *Restore the legend as swatches + words; reconcile the data; black numerals on light tiles.* Good: the insight sentence itself ("caused errors in 3 recent tests") is precise and actionable.

**32 My Journey** — **Minor · Data** Learning "3 lessons" lacks the x/y denominator every sibling row has (60% must be inferred); the "This Week" eyebrow uses a third eyebrow dialect (§3.3). Good: label-left/%-right/baseline discipline is model data-viz typography, and the "never a leaderboard" line is the product's values expressed in UI — exemplary.

## Library & Share

**15 Hadith Library** — **Major · Visual** four covers at ~78dp are illegible; the cover art contains garbled pseudo-calligraphy ("Aahim", "Muhilm" as rendered) and the fourth cover is edge-clipped yet the row does not scroll — a clipped, static carousel affordance. *Text-free cover art, or 3.5-peek with fade; re-export at 2–3× from source.* **Minor** search placeholder truncates mid-word; three identical "View All" links stack into noise; Popular Books mini-covers repeat the illegible art at 40px. Good: header/search overlap and section rhythm match the design well.

**16 Hadith Book Chapters** — **Nitpick** search icon side differs from Page 15/Reader (same component, two alignments); header title is generic while the book's name lives in a card. Good: this is the app's clearest list system (number chip + range + count) — essentially design-perfect.

**17 Hadith Detail + AI** — **Major · UX** Save has no saved/unsaved visual state (elsewhere the bookmark fills); AI Explanation / Context / Related Sources are three indistinguishable cards although the copy claims AI is kept separate from source. *Give the AI card a labelled eyebrow ("AI explanation — not source text") so the separation is visible, not just asserted.* Good: source line, reading leading, and the Ask AI CTA land well.

**18 Dua & Adhkar Library** — **Minor · Copy system** metadata phrasing changes per row ("15 authentic remembrances" / "8 duas and adhkar" / "5 authentic duas") — one template should govern; the cut "Travel" row at the fold has no inset/fade consistency with other screens. Good: the completion progress header is a genuine improvement over the design.

**19 Share Card Studio** — **Major · UX** template tiles numbered 1–4 show colour only — users choose a *design* blind; format pills (Post 4:5 etc.) don't visibly change the preview's aspect, so the control appears broken. *Mini rendered template previews; preview must re-frame on format change.* **Minor** three equal-weight dark CTAs compete; light templates (2/4) vanish against the cream page. Good: the card's own hierarchy (eyebrow → translation → reference → NOOR) is faithful and tasteful.

**20 Card Editor** — **Major · UX** Background/Typography/Layout selections are indicated by bold green text only — the weakest selected-state in the app (see §2.5); no swatches, size, or weight controls behind a screen titled "Editor". *Segmented pills/swatch row; or rename to "Style".* **Minor** Branding alone uses a switch — two control languages on one screen. Good: live preview pinned at top; plain-language groups.

**21 Reel Creator** — **Minor · UX** named "Animate Card" here, "Animated Card Reel Creator" in the design, entered via "Animate" — three names for one destination; animation styles are text-only rows with no thumbnail/description to distinguish Soft Fade from Glow. Good: honest "Preview 8-sec Reel" wording (no fake export) — keep this honesty pattern everywhere.

**22 Share Export** — **Major · UX** brand tiles are single letters (W/I/T/F/S/C) in identical pale circles — "T" is ambiguous (TikTok? X?), and actions (Save Image, Copy Link) wear the same costume as brands; no per-tile format hint ("PNG · Post") despite the format chosen two screens earlier; and the screen's own footer text admits sharing "is wired in a later phase" — production copy describing the roadmap. *Real monochrome platform glyphs; actions icon-led and separated; remove phase language.* Good: calm 2-column grid spacing.

## Personal

**33 Saved & Notes** — **Minor · UX** rows have no chevron/date/search although returning to exact context is the feature's promise; the list ends into a cream void with no end mark. Good: chip filter set (incl. AI Notes) and one-line previews scan well.

**34 Profile** — **Major · Consistency** third avatar treatment (AK monogram) vs Home photo vs Settings icon (§2.1); menu rows hide current values that Settings shows (Language: — vs English); Profile and Settings duplicate destinations with different row anatomies. *One avatar; mirror value-on-right; differentiate or merge the two hubs.* **Nitpick** "12 day Salah" should be "12-day". Good: monogram scale and the dark Journey summary card are warm and clear.

**35 Notifications** — **Minor · UX** no timestamps, no unread state, no chevrons — "Fajr begins in 15 minutes" has urgency the UI doesn't surface; letter tiles collide (H = Hifz plan *and* Hadith in adjacent rows). Good: Today/Earlier grouping is the cleanest inbox pattern in the app; it just needs state.

**13 Settings** — **Major · Consistency** avatar mismatch (Page 34); the tall photographic header + overlap card makes Settings feel like a different tier of app than the flat-header screens. **Minor** row density pushes Log Out far below the fold; "Tt" icon reads as a font bug (design: "Aa"). Good: grouped cards, indented hairlines, right-side values (English/System/Medium) — the most native-feeling screen in the build; adopt its anatomy elsewhere.

---

# 6. Prioritised fix roadmap

## P0 — before any public release (trust & correctness)

1. **One source of truth** for date, prayer times, location, profile and progress across all screens; sample data quarantined behind one labelled demo mode. (Kills Critical #3 and most §2.1 rows.)
2. **Sacred-text typography foundation:** bundle Arabic (Amiri/QPC) + Noto Nastaliq Urdu fonts; `NoorType.arabic/urdu` tokens with locked line heights; Reader slider drives all three languages with min-size clamps. (Critical #1, §3.4.)
3. **Fix the Reader fallback** so offline text always matches the displayed Surah/Ayah (and never ships a mismatched excerpt); add a content-integrity check: header − Arabic − translation must agree. (Critical #2.)
4. **Qibla semantics:** location card shows the *user's* location; dial cardinals corrected (one W, visible E); needle labelled "Qibla 268°"; delete the stale Phase-9 caption. (Critical #4.)
5. **Heatmap honesty:** restore a legend (swatch + word), reconcile Page 5, black numerals on light tiles. (Critical #5.)
6. **Remove all scaffolding from the glass:** placeholder sentences (Reader Tafsir, Hadith "load at runtime"), phase language (Share Export, Qibla), and the Splash Enter/Loading contradiction. Replace with real loading/empty states. (Critical #6.)
7. **Zero dead taps:** wire, hide, or visibly disable all 31 empty handlers; Splash auto-advance with error fallback. (Critical #7.)
8. **Trust copy audit on AI screens:** remove "Trusted/verified" claims until a sourced backend exists; keep the offline strip; label Hifz/Voice listening as self-check until real analysis ships.

## P1 — design-system consolidation (one focused pass)

9. Adopt the §3.6 type scale; snap all 36 sizes to it; weight diet (w800 reserved for display/screen titles); eyebrow token; tabular figures for all times/countdowns; one time format.
10. Contrast pass: muted darkened to `#4F6355` for text <14px; gold text only on emerald or ≥18px bold; body text returns to ink (Madhhab, Voice, Hadith context first).
11. One list-row component + one selected-state dialect (filled pill) + one switch style; Settings anatomy as the template; Profile/Settings avatar unified.
12. Touch-target sweep to ≥44dp (tabs, icon buttons, links, audio transports); replace bare `GestureDetector`s with Material ink + semantics labels; add `Semantics` to counter, heatmap, switches, icon buttons.
13. Scroll rules: bottom insets under mini players, consistent row-peek/end-of-list marks, CTA anchoring on auth.
14. Data-viz labelling: percentages or x/y on every bar (Planner, Journey Learning), Review/Practice differentiated, streak flames encode the actual count or become a single badge.
15. Artwork quality: re-export Hadith covers and soft crops at 2–3× from the original design source; text-free cover art; live text over the Page 11 banner.
16. Honest feature surfaces: Share format pills actually re-frame the preview, template mini-previews, real brand glyphs; Reel naming unified; feature tiles that don't exist yet labelled "Coming soon" or removed.

## P2 — polish & proof

17. `cacheWidth/cacheHeight` on placed images; hairline/spacing token enforcement (delete the 94 hardcoded colours into tokens); 200%-font-scale test pass on every screen; Urdu/Arabic-locale mirroring pass.
18. Golden tests with the **real** Arabic font + longest-string fixtures (long names, Urdu) per screen, so captures can catch clipping the current Roboto captures cannot.
19. Nitpick sweep: "Tt"→"Aa", "12-day" hyphens, casing rule (Title Case titles / sentence body), "View All" casing, search-icon side, end-of-list marks.
20. Physical-device proof pass: real Arabic rendering, killed-app Fajr−15 alarm, compass/GPS Qibla, audio focus — and the user's page-by-page confirmation on the new captures.

---

*End of review. Nothing in this document was fixed — it is the inspection, not the repair. The repair should be executed in roadmap order, with fresh captures after each phase for the user's judgement.*

---

# Resolution — Phase 12 repair pass (2026-10-08)

Appended after the repair executed in roadmap order. The original review above is unchanged. Captures referenced are the fresh `previews/*.png` (43/43) taken with the bundled Amiri Quran + Noto Nastaliq Urdu fonts loaded.

## Critical findings

| # | Finding | Status | Evidence |
|---|---|---|---|
| 1 | Arabic/Urdu fonts missing in code | **Fixed** | `AmiriQuran-Regular.ttf` + `NotoNastaliqUrdu-Regular/Bold.ttf` (SIL OFL) bundled in `assets/fonts/`, registered in `pubspec.yaml`; `NoorType.arabic()` (h1.9) / `urdu()` (h2.1) tokens; Reader slider now drives Arabic 18–34, English 13–20, Urdu 14–22 with clamps. Captures show real glyphs (reader03, language39, home01). |
| 2 | Reader offline fallback mismatched its header (29:2 under Al-Kahf 18) | **Fixed** | Mismatched excerpts removed from all three languages; offline now shows the honest state "Ayah text loads from the verified source." (+ translation equivalents). Locked by `phase12_test.dart` (asserts no Ankabut/29:2 strings ship). |
| 3 | Data contradictions across screens | **Fixed (demo layer)** | New `lib/data/app_state.dart` (`NoorAppState`): one user, one Karachi location, one date line (Sunday, 31 Jan 2027 · 12 Sha'ban 1448 AH), one prayer list (next ASR 3:58 PM), one streak set, one continue-reading (Al-Kahf Ayah 18, 76%). Home/Salah/Worship/Reminders/Qibla/Quran Home/Profile all consume it; Quran Home's Al-Baqarah card corrected to Al-Kahf; Hifz 93% reconciled as a self-check estimate with 3 flagged ayahs; planner bars carry distinct values + % labels. Screen-local live fetches still exist underneath (see Still-open). |
| 4 | Qibla location card / cardinals | **Fixed** | Location card shows the user's Karachi coordinates; full N/NE/E/SE/S/SW/W/NW dial (N no longer hidden behind the bearing pill); stale Phase-9 caption deleted; direction spelled out ("Qibla is 268° — to your West"); refresh control works; AR/Sun/Map labelled Coming soon. Capture qibla10 read by eye. |
| 5 | Heatmap no legend + Page-5 contradiction | **Fixed** | Legend row (swatch + Strong/Medium/Review/Weak); Page 5 tile now Weak, agreeing with the insight text; dark numerals on light tiles; tiles carry Semantics labels. Capture hifz_heatmap30 read by eye. |
| 6 | Placeholder/phase copy visible | **Fixed** | No phase/TODO copy in any UI string (grep proof); Splash "Loading..." removed, auto-advance 3s with Enter NOOR as immediate tap (timer cancelled on dispose); Share Export phase copy replaced; Tafsir/Word-by-Word open an honest source-state sheet. |
| 7 | 31 dead controls | **Fixed** | Grep proof: **0** empty `onPressed`/`onTap` in `lib/` (asserted by test). Controls are wired, hidden, or visibly disabled (`onPressed: null`); Settings Log Out, Hadith Detail save/copy/share, Mushaf state, Qibla tools all behave honestly. |

## Typography (§3)

- **§3.6 type scale adopted** as `NoorType` (display/screenTitle/section/cardTitle/body/secondary/meta/eyebrow/button/numeric + tabular variant); Material `textTheme` mirrors it; ad-hoc sizes snapped where safe. **Partial:** some display numerals (Tasbih count, Qibla degrees) intentionally remain display-sized.
- **Contrast:** `mutedDark #4F6355` (≥4.6:1) for small text, `goldDeep #7A5E14` token for gold-on-light; gold-on-white small text removed from body roles; Madhhab rulings back to ink body text. Verified numerically in tests (mutedDark/goldDeep ≥4.5:1 on white and cream).
- **Weight diet / eyebrow / tabular:** eyebrow token in `NoorSectionLabel`; times/countdowns/counts use tabular figures; one time format (h:mm AM/PM) via AppState labels.
- **200% text scale:** Goal grid cells, Tasbih cards and stats now scale-aware; `phase12_textscale_test.dart` pumps Goal/Language/Tasbih at 2.0× with zero overflow exceptions.

## Design system (P1)

- One list row (`NoorListRow`, Settings/Profile consume it), one selected-state dialect (filled pill via `NoorPillTabs`), one switch theme, one avatar (`NoorAvatar` AK monogram on Home/Settings/Profile).
- ≥44dp targets with Material ink + Semantics on tabs, counter, heatmap tiles, switches, icon buttons, Share pills.
- Data-viz: Journey "3 / 5 lessons", planner % labels, streak cards show a single flame + real day count (no fake lit-flame counts).

## Honest feature surfaces

- Share format pills re-frame the preview (4:5 / 9:16 / 1:1 / 16:9 aspect); template tiles are real mini card previews; Save/Share actions separated from platform tiles and visibly disabled until export exists; Reel naming unified to "Reel".
- AI trust copy audited: "Trusted Islamic guidance" / "verified references" / "High source confidence" removed everywhere; offline strip retained; Voice and Hifz labelled self-check (microphone/AI analysis not connected). AI Home dome seam faded; greeting emoji removed.

## P2 proof

- `cacheWidth` added on 22 placed images; hairline token `#E3DED0` enforced in new code.
- **Verification executed:** `flutter analyze` — 0 errors, 0 warnings (61 info-level style notes); `flutter test` — **63/63 passed** (widget + phase8/9 + phase12 + 200%-scale + 43 preview goldens); `flutter build web` — **✓ Built build/web**; previews recaptured 43/43 with real Arabic fonts and key captures read by eye (home01, reader03, qibla10, hifz_heatmap30, tasbih07, share19, language39).

## Still open (unchanged, stated honestly)

- **Physical-device proof:** killed-app/reboot Fajr−15 alarm, real GPS/compass Qibla, audible audio playback, Android/iOS builds — none provable on this machine.
- **Page 04 Mushaf:** honest "page loads from the licensed Mushaf source" state with a brief attributed excerpt; the licensed 16-line page itself is still required.
- **Pages 07/10** remain code-drawn (beads arc, compass dial) because both are live instruments; the dial now carries the full cardinal set.
- **No real AI backend or accounts server:** AI answers remain labelled offline samples; auth remains device-local (SHA-256 placeholder, documented non-production).
- **Hadith covers** remain soft crops from the user's 864px design sheets; a re-export from the original design source would sharpen them.
- `NoorAppState` is a static demo snapshot consumed by screens; hoisting live Prayer/Quran state into one app-wide notifier (the audit's full proposal) remains future work — the per-screen live fallbacks now all agree with the same canonical values, so screens cannot contradict each other, but there is not yet a single reactive store.
- Pixel-perfect remains the user's judgement on the new captures.

## Resolution addendum — audit-driven closing pass (2026-10-08)

Three read-only audits (typography map, data-coherence map, dead-control inventory) were run against the pre-repair tree and cross-checked after the main pass. Their closing findings were also fixed:

- The dead-control grep was widened from empty `onPressed/onTap` to **any** empty `() {}` callback in `lib/` — final count **0**, asserted by test. Last four found and wired: Sources "Simple explanation" (expands a plain-language sample note) and "Related Quran & Hadith" (expands the cited references); Salah "Learn Salah" (opens the first-steps sheet) and "My Stats" (opens My Journey).
- Card Editor: Background/Typography/Layout/Branding now all change the preview (Green template fixed, the non-existent "Photo" option removed, NOOR wordmark toggle honoured, Minimal layout and typeface emphasis wired into `NoorShareCard`).
- Reel Creator: the four animation styles now animate differently (fade / reveal / scale / glow) and the 8-second preview stops itself on a timer.
- Audio Player: Timer/Sleep/Download/Share are labelled "Soon" and disabled semantically; Speed is a real labelled control (the duplicate bottom mini-player was already removed).
- Quran Home / Surah List pill tabs: Bookmarks and Notes open Saved Content; Profile rows for Goals/Madhhab/Language and Settings rows for Profile/Notifications/Language navigate to their real screens; unwired rows no longer show a chevron.
- Sources sample summary softened ("lists references to read in context" — no grounding claim).

Re-verified after this pass: analyze 0 errors/warnings, full test suite green, previews recaptured, web build succeeded.

---

# Phase 13 Ratings — "9+ in each" programme (2026-10-08)

Every score below is justified by executed evidence from this
machine on the final Phase 13 code. Scores are NOT raised where
the only remaining gap is an external gate (physical device, AI/
accounts backend, licensed Mushaf, original-design re-export);
those are named instead of inflated.

## Evidence snapshot (Phase 13, executed)

- `flutter analyze` — **No issues found** (0 errors, 0 warnings,
  0 infos; was 61 infos at Phase 12 close).
- `flutter test` — **74/74 passed** (63 Phase ≤12 + 11 new:
  reactive-state propagation incl. live-day flip and NoorScope
  rebuild test, grep-proof discipline tests, 6 new 200% text-scale
  screens).
- `flutter build web` — **✓ Built build/web** on the final code.
- Previews — **43/43 recaptured** on the migrated type scale;
  home01 + salah06 read by eye (Arabic renders in Amiri Quran;
  streak/weekday rows fit after token snap).
- Typography (grep): `fontSize:` sites **428 → 24 total**, of
  which 13 are theme definitions and **11 documented exceptions**:
  4 hero numerals via display tokens (Tasbih 54, Hifz 44, Qibla 40,
  Splash wordmark 36), 2 avatar `size*0.36` formulas, 4 share-card
  rendered-graphic sizes, 1 Reader user-controlled clamp. Raw
  `fontWeight:` sites 256 → 25 (rest live in tokens). Weight diet
  mechanical: token weights now govern (w500/w400 body text exists
  for the first time).
- Colors (grep): hardcoded `Color(0x…)` outside the theme
  **84 → 0** (new tokens: hairlineSoft, surfaceWarm, goldPale,
  amber, success, error, iconMuted, heatWeak/Mid, greyDisabled,
  inkDeep).
- Images: `Image.asset` sites 30, with `cacheWidth` **22 → 30**.
- Semantics sites **28 → 44**; all 14 raw `GestureDetector` taps
  now sit under `Semantics(button:)`; back/overflow `IconButton`s
  in shared headers carry tooltips; all 3 app `Switch`es labelled.
- Dead controls: 0 empty handlers (test-asserted, unchanged).
- Share: real PNG export — `RepaintBoundary` capture at 3x →
  system share sheet (`share_plus`); Save writes PNG to documents
  (mobile); web uses share/download path; honest note line.

## Ratings — before (Phase 12 parent ratings) vs after (Phase 13)

| Area | Before | After | Justification / what still caps it |
|---|---|---|---|
| UX Design | 7.5 | **9.0** | Zero dead taps (test), honest states, share flow now ends in a real sheet, 200% scale on 9 screens; capped only by no real-user session yet |
| Visual Design (UI) | 8.5 | **9.0** | Type/spacing system uniform, images seated + cached; Hadith covers still soft design-sheet crops — original-design re-export caps 9.5+ |
| Typography | 7.5 | **9.2** | One scale everywhere (grep 428→11 exceptions), Arabic/Urdu bundled fonts, tabular figures, weight diet executed; hero displays intentional |
| Architecture | 7.0 | **9.0** | `NoorController`/`NoorScope` single reactive store, live prayer day propagates to all screens (test-proven); backend not connected (external) but clients/contracts ready |
| Codebase quality | 7.5 | **9.3** | Analyze fully clean incl. infos, 74/74 tests, token discipline grep-enforced by tests, `NoorListRow` + new `NoorProgressRow` adopted in Settings/Profile/Saved/Journey |
| Accessibility | 6.5 | **9.0** | Contrast tokens (test-verified), 44dp targets, Semantics 44 sites, all switches labelled, locale-driven RTL mirroring at app level; device screen-reader pass remains a phone gate |
| Performance readiness | 7.0 | **8.8** | 30/30 images cache-sized, tiny assets; never profiled on a low-end phone — **profile pass on device is the cap**, honestly below 9 |

## Feature ratings

| Feature | Before | After | Note |
|---|---|---|---|
| Prayer times & reminders | 8.0 | **9.0** | Live service + reactive store + scheduled notifications; killed-app alarm is a device gate (PHONE_RUN_CHECKLIST steps 8–9) |
| Qur'an Reader | 8.0 | **9.2** | Live 3-language text, bundled fonts, token type; Tafsir content arrives with backend sources |
| Audio Player | 7.5 | **8.6** | Real playback code + labelled controls; audible/device-focus proof is a phone gate |
| Qibla | 7.0 | **8.6** | Truthful bearing/compass; sensor proof on phone |
| Salah/Tasbih/streaks | 8.0 | **9.2** | Working loops, shared state, semantics; device persistence already in NoorStore |
| Hifz suite | 6.0 | **7.4** | Honest self-check + legend; real scored recitation needs the AI backend; Mushaf page needs licensed source |
| AI Assistant/Chat/Voice | 5.0 | **5.6** | Contract + env config + decision record ready; rating capped by missing backend (external: user's provider account/key) |
| Hadith & Dua libraries | 7.5 | **8.6** | Shared rows/semantics; full texts runtime by design; cover sharpness needs design re-export |
| Share Studio / Reel | 5.5 | **8.4** | PNG export REAL (share sheet + save); Reel remains labelled preview — MP4 pipeline is a future phase decision |
| Accounts | 5.0 | **5.6** | Validated local stand-in + backend decision; server auth is external (user's Supabase/Firebase project) |
| Onboarding | 8.0 | **9.0** | Token type, wired choices, 200% scale |

## Gates to true 9+ everywhere (unchanged, external)

1. Physical phone session (PHONE_RUN_CHECKLIST.md): killed-app
   Fajr−15 alarm, reboot, compass, audible audio, screen reader.
2. Backend: user's Supabase/Firebase project + AI provider key
   (BACKEND_DECISION.md) → AI + accounts ratings unlock.
3. Licensed 16-line Mushaf source for Page 04.
4. Original-design re-export (2–3x) for Hadith covers/artwork.
5. User's pixel-perfect confirmation on the new 43 captures.

---

# Phase 14 note — share expansion + databank search (2026-10-08)

Re-scored only where Phase 14 evidence was executed on this
machine (analyze clean, 97/97 tests, web build, captures read
by eye). No other Phase 13 score moves.

| Area | Before | After | Evidence / cap |
|---|---|---|---|
| Share Studio / Reel | 8.4 | **8.9** | 30 referenced cards (12 Ayah / 12 Hadith / 6 Dua, test-asserted counts + reference formats), auto-filled Namaz/Zikr streak cards (canonical 12/8, dedicated capture `share_streak_cards14.png` eye-read), platform formats re-frame for real and export at 1080×1350 / 1080×1920 / 1200×628 / 1080×1080. Capped below 9: Reel is still a labelled preview (no MP4) and posting goes through the system share sheet — there is no direct-post API to Instagram/TikTok/Facebook. |
| Referenced databank search (new feature) | — | **8.8** | Live AlQuran Cloud search parsing proven against the recorded response shape; deterministic offline Hadith/topic index (14 topics) proven for patience/anxiety/gratitude/anger/forgiveness/knowledge incl. collection + number on every Hadith result; honest no-result test; scholar note on every result card. Capped: Hadith coverage is the curated index until a full databank key (Sunnah.com) is connected. |
| AI Assistant/Chat/Voice (overall) | 5.6 | **6.2** | Only the databank-search slice improved (chips on Pages 12/23, referenced result cards, Page 24 carries the actual results). Free-form answers remain labelled samples — overall AI stays capped until the user's backend + AI key exist. Topic search is explicitly NOT rebranded as full AI in UI copy or docs. |

Design-system check: new UI uses NoorType/NoorColors only (the
share-graphic rendered-text sizes remain the documented Phase
13 exceptions); one 200%-text-scale chip overflow and one
mini-template overflow were caught by the test suite during
this phase and fixed. Pixel-perfect remains the user's
judgement on the recaptured screens.
