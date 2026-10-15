# NOOR — Full 42-Screen Visual Audit (Phase 11, 2026-10-07)

Method: every app capture in `previews/*.png` (390×844 @2x, `test/previews_test.dart`)
was read side-by-side with its design PNG in
`~/workspace/noor-design/NOOR_AI_Companion_Complete_UI_Pages_01-42/`
(phone mockup only; spec-sheet text ignored). Four parallel audit passes covered
Pages 01–10, 11–21, 22–32, 33–42; every code-fixable mismatch was fixed in this
phase (Noor tokens only, no redesign), then all 42 screens were recaptured and
the changed ones re-read.

**How to read the statuses:** "Visually close" = layout order, emerald/gold/cream
tokens and hierarchy match the design page; it is **not** a claim of pixel-perfect
— only the user can confirm that. "Fixed in this phase" lists the exact change.
"Still open" gives the exact reason (artwork/content that exists only in the
design, or device-only proof).

**Capture-only artifacts (not app faults, ignored in every row):** Arabic/Urdu
lines render as boxes (the offline capture font has no Arabic/Urdu glyphs; a
phone's system font renders them), Roboto stands in for Manrope, no status bar.

| Page | Screen | Capture | Status | Notes (before → after / exact open reason) |
|---|---|---|---|---|
| 01 | Home Dashboard | home01.png | Visually close | Greeting/Hijri, ASR next-prayer mosque card, 12/8/17 streaks, Dua/Hadith cards, 5-tab nav match. User-approved 2026-10-07. Streak icons remain line icons vs design's illustrated icons (art-level, minor). |
| 02 | Surah List | surah_list02.png | **Fixed in this phase** | Star badges: plain dark circles → code-drawn 8-point star medallions (`NoorRosetteBadge`). Search: always-visible field → hidden behind the app-bar search icon (autofocus when opened), as drawn. Rows tightened (13→10 vertical padding, 36→34 badge). Reciter avatar in mini player → design's own art (see 03). Minor open: pill tabs are text-only; design's Page 02 pills carry small glyphs (shared component with Page 11, whose design pills are text-only — left shared). |
| 03 | Quran Reader EN/Urdu | reader03.png | **Fixed in this phase** | Mini player: neutral person-icon disc → the design's own reciter avatar, cropped from Page 03 (`assets/images/reciter_avatar.png`, also wired on Pages 02/05). Text-size slider was always expanded → now behind the Text Size pill (tap toggles). Ayah marker: pale mint circle → gold-outline rosette as drawn. Quick Tools: filled mint circles → pale rounded-square tiles as drawn. Still simpler than design: the sticky mini player has no progress bar/times — real progress lives on Page 05, which the play button opens (no fake progress drawn). |
| 04 | Hifz Mushaf 16-Line | mushaf04.png | Still open | Needs the real 16-line Mushaf page (licensed source/artwork). App draws a 16-line frame with one brief excerpt line; full page text/rendering must come from the licensed source at runtime, never pasted into code. |
| 05 | Quran Audio Player | audio05.png | Visually close | Arch calligraphy card, 1–110/Juz 15/Page 293 stats, progress, transport, Speed/Timer/Sleep/Download/Share, Playback Range all match. Reciter rows now show the design's own avatar art (Phase 11) instead of the "M" initial. |
| 06 | Salah Tracker | salah06.png | **Fixed in this phase** | Prayer icons: thin outlines → solid mosque glyphs as drawn. Removed the extra "X of 5 prayers logged today" caption (design card ends at the times; tappable checks show progress). Insights lantern was hard-cropped → shown whole (`BoxFit.contain`), and the lantern asset's baked-in text fragments ("Fajr."/"to") were cropped out of `salah_lantern.png` itself. |
| 07 | Zikr Tasbih | tasbih07.png | Still open | Central artwork exists only in the design: a rendered bead string with gold spacers + tassel around the counter. App draws a gold-ring bead arc in code; layout (streak, 27/33, Undo/Add, target pills, Other Dhikr) matches. A static crop can't be used — the counter number is live. |
| 08 | Dua of the Day | dua_day08.png | **Fixed in this phase** | Top medallion: flat mosque icon → design's gold mosque/crescent medallion cropped from Page 08 (`dua_medallion.png`). "About this Dua" now carries the design's own wording with chevron (was runtime-placeholder copy). Minor open: More Duas cards lead with transliteration + English subtitle; design leads with Arabic calligraphy (card titles are source content, loaded at runtime — form difference only). |
| 09 | Hadith of the Day | hadith_day09.png | **Fixed in this phase** | Medallion showed the wrong art (Al-Kahf calligraphy) → design's gold Muhammad calligraphy medallion cropped from Page 09 (`hadith_day_medallion.png`). Reflection line now opens with the design's wording ("Let's purify our intentions…"). |
| 10 | Qibla Finder | qibla10.png | Still open | Compass is code-drawn vs the design's rendered ornate dial (fine ticks, double gold ring, detailed Kaaba medallion). It must stay drawn: the needle shows the **live** bearing (capture shows live Karachi bearing; the design's 295° is its printed sample — that number difference is live data, not a fault). Location/direction cards and Compass/AR/Sun/Map tiles match. |
| 11 | Quran Home | quran_home11.png | Visually close | Daily Verse banner uses the design's own cropped art (lanterns, mosque silhouettes, brief Al-Isra 17:9 excerpt as drawn) — re-verified in this phase's recapture, and the asset is now precached in the capture test. Header pills, Continue Reading, surah rows match. User-approved 2026-10-07. |
| 12 | AI Assistant Home | ai_home12.png | **Fixed in this phase** | Recent Conversations rows were one-line titles → now title + grey answer-preview line, as drawn. Header dome art, greeting, ask bar, Suggested Questions grid match. User-approved 2026-10-07. |
| 13 | Settings | settings13.png | **Fixed in this phase** | Header art was a narrow lantern strip with a white block (the crop carried a white page margin) → white band cropped out of the asset and the patterned emerald + lantern now fills the header band as drawn. Profile card and all setting rows/values match. Trivial: Text Size row icon renders "Tt" (Material glyph) vs design's "Aa". |
| 14 | Worship Dashboard | worship14.png | **Fixed in this phase** | "Worship" title rendered twice (ghost) — the title is baked into the header artwork, so the duplicate code title was removed. Next-prayer mosque was a boxed thumbnail with a pale top edge → bottom-anchored scaled art blending into the card, as drawn. Heading "WORSHIP TOOLS" (spaced caps) → "Worship Tools". Quote card, prayer rows/bells, tools grid match. |
| 15 | Hadith Library | hadith_library15.png | **Fixed in this phase** | Featured Collections reused one generic zoom-cropped cover for all books → four distinct covers cropped from Page 15 itself (Bukhari/Muslim/Tirmidhi/Dawud, `hadith_cover_*.png`), shown 4-across as drawn. Header skyline band 62→96px tall as drawn. Search, category grid, Popular Books match. |
| 16 | Hadith Book Chapters | hadith_chapters16.png | Visually close | Header, Continue card, search, chips and all 7 chapter rows match. Capture adds a small "Structured reading" subtitle (trivial). |
| 17 | Hadith Detail + AI | hadith_detail17.png | Visually close | Hadith card, AI Explanation / Context / Related Sources, Ask AI CTA match in order and text (brief attributed excerpt only; full text from source at runtime). |
| 18 | Dua Adhkar Library | dua_library18.png | Visually close | Daily Adhkar card, search, filter chips, numbered category rows (names/counts) match. Capture adds a small progress bar + header subtitle (minor additions). |
| 19 | Share Card Studio | share19.png | **Fixed in this phase** | "Animate" button label wrapped mid-word ("Animat/e") → fitted single line (smaller label, tighter padding). Preview card, format chips, template tiles match. |
| 20 | Card Editor | card_editor20.png | Visually close | Preview, Background/Typography/Layout groups and selected states match; watermark shows as an "On" toggle (equivalent). |
| 21 | Reel Creator | reel_creator21.png | **Fixed in this phase** | Removed a visible developer note ("wired in a later phase") that is not in the design. Honesty kept: the button says "Preview 8-sec Reel" and real export status is stated on Page 22 — no video file is created anywhere yet. |
| 22 | Share Export | share_export22.png | Visually close | Header, preview card, "Ready to share" 2×3 grid match (both design and app use letter tiles — no brand-logo gap). Tapping a target shows an honest later-phase note; no file is exported yet. |
| 23 | AI Chat | ai_chat23.png | **Fixed in this phase** | First answer now uses the design's wording ("Patience (sabr) is repeatedly praised in the Quran. Allah connects patience with prayer…"). Send button: arrow → design's chevron in emerald circle. Kept deliberately (documented, not design): the slim "Sample answers (offline)" strip — AI honesty labelling from Phase 9; and the "Show sources" row, which is the real route to Page 24. |
| 24 | AI Answer Sources | ai_sources24.png | Visually close | Question bubble, AI Explanation, sources pill (Quran 17:79 • Sahih Muslim 1163), confidence line, 4 outline rows match. Trivial: small check-badge before the confidence line. |
| 25 | Compare Madhhab | madhhab_compare25.png | Visually close | Question pill + four madhhab cards (position lines, badges, View evidence) match. Capture appends a scholar-consult disclaimer below the design content (deliberate, responsible addition). |
| 26 | Voice AI Companion | voice26.png | Visually close | Listening circle, transcript pill, Try asking rows match. Capture appends a "Private mode…" line (honest addition; mic is UI-state only). |
| 27 | Hifz AI Test | hifz_test27.png | Visually close | Range card, cue line, RECITE circle, Privacy card match. RECITE is listening-UI only — no real speech analysis yet (functional, stated honestly). |
| 28 | Hifz Test Results | hifz_results28.png | Visually close | 93% hero, Ayah 38/40/42 Review/Practice rows, AI suggestion match. Capture appends "Retest Weak Range" button below design content. |
| 29 | Hifz Revision Planner | hifz_planner29.png | Visually close | Today's plan cards + AI Scheduling match. Capture appends "View Page Strength" button (the real route to Page 30). |
| 30 | Hifz Heatmap | hifz_heatmap30.png | **Fixed in this phase** | Removed the legend row (not in the design) and the thick ink outline pre-drawn on tile 5 (selection outline now appears only after a tap). Grid colours/numbers and insight card ("Page 5 caused errors in 3 recent tests." → Review Page 5) match cell-for-cell. |
| 31 | Reminder Center | reminders31.png | Visually close | Salah + Worship rows (labels, times, on-toggles) match. Caveat: the capture ends mid-scroll, so Daily Content rows below the fold were not verified from this capture (they exist in code). |
| 32 | My Journey | journey32.png | Visually close | This Week card, Salah 93% / Quran 71% / Dhikr 100% / Learning 60% bars, AI Insight match. Capture appends the private/no-leaderboard line (design's own stance, honest addition). |
| 33 | Saved & Notes | saved33.png | **Fixed in this phase** | 5th filter chip ("AI Notes") was clipped at the screen edge → chip padding/font reduced; all five chips fit as drawn. Five saved cards match in text/order. |
| 34 | Profile | profile34.png | Visually close | AK avatar, Your Journey card, settings list order match (bottom crop is scroll position, not layout). |
| 35 | Notifications | notifications35.png | Visually close | Today/Earlier groups, letter avatars, texts, card styling match. |
| 36 | Splash | splash36.png | Visually close | Cream page, emerald NOOR tile, "AI Companion", "Faith • Guidance • Growth", "Loading..." match Page 36 proportions (re-confirmed this phase; no spacing/proportion change needed). The working **Enter NOOR** button is added on purpose — it is the user's tap target and stays. |
| 37 | Onboarding | onboarding37.png | Visually close | Skip, pale QURAN circle, "Learn. Practice. Grow.", Continue pill match. (Hero is a drawn pale circle; the design hero is likewise a flat pale circle.) |
| 38 | Goal Selection | goal38.png | **Fixed in this phase** | Heading wrapped to two lines → fitted one line as drawn. Goal labels wrapped mid-word ("Salah con/sistency") → single-line fitted labels (shared option tile; fitted size varies slightly with label length — minor). Selections (Quran reading / Salah consistency / Memorization) match. |
| 39 | Language Selection | language39.png | Visually close | English selected row + Urdu/Arabic/Bahasa rows + Continue match (script lines are capture-font boxes only). |
| 40 | Madhhab Preference | madhhab40.png | **Fixed in this phase** | Selected indicator was a white circle with a dark check → plain filled white circle as drawn (shared `NoorRadioDot`, used only here). Labels single-line fitted. |
| 41 | Create Account | create_account41.png | Visually close | Name/Email/Password fields, Create Account button, Login footer match. (Device-local validation only — server accounts are Phase 12.) |
| 42 | Login | login42.png | Visually close | Welcome back, fields, Forgot password?, Login button, Create account footer match. (Server sign-in: Phase 12.) |

## Totals

- **Visually close (no change needed): 23 pages** — 01, 05, 11, 16, 17, 18, 20, 22, 24, 25, 26, 27, 28, 29, 31, 32, 34, 35, 36, 37, 39, 41, 42.
- **Fixed in this phase: 16 pages** — 02, 03, 06, 08, 09, 12, 13, 14, 15, 19, 21, 23, 30, 33, 38, 40 (02/03/05 share the avatar fix; 05 also listed as visually close above).
- **Still open: 3 pages** — 04 (licensed Mushaf page source), 07 (rendered tasbih bead art around a live counter), 10 (rendered compass art vs live-bearing dial). Each needs design-only artwork or licensed content, not layout code.

## What did NOT change

- No redesign: every fix uses existing Noor tokens/components (`NoorRosetteBadge` is the only new widget — it draws the design's own star medallion in code).
- New artwork is **only crops of the user's own design pages**: `reciter_avatar.png`
  (Page 03), `dua_medallion.png` (Page 08), `hadith_day_medallion.png` (Page 09),
  `hadith_cover_*.png` ×4 (Page 15). No generated or stock substitutes, no fabricated photos.
- Brief attributed religious snippets only, exactly as drawn; full Qur'an/Hadith/
  Dua text still loads from the API/licensed source at runtime.
- Honest in-app labels kept where the design is silent: offline-AI labelling
  (23), reel preview-only wording (21/22), scholar-consult note (25).

## Verification (executed 2026-10-07, this machine)

- `flutter analyze` — **"No issues found!"**
- `flutter test test/previews_test.dart --update-goldens` — **all preview captures passed** (42 screens recaptured after the fixes; changed screens re-read against their design PNGs for this file).
- Normal suite (previews excluded): `flutter test test/widget_test.dart test/phase8_test.dart test/phase9_test.dart` — **7/7 passed**.
- `flutter build web` — see SCAFFOLD_STATUS.md Phase 11 (result recorded there after the run).
- Still **not** done (unchanged honesty): no physical phone run — on-device audio heard, killed-app/reboot Fajr−15 alarm, real GPS/compass heading, Android APK build (no Android SDK here), iOS (needs a Mac).

---

## Image fit pass (Phase 11b, 2026-10-07) — "some images are not exactly fit inside their box"

User feedback on the 42 captures: overall "perfect", but some pictures did not
sit exactly inside their boxes. Every `Image.asset`/`AssetImage` usage in
`lib/` (35 sites) was audited for fit/alignment/clipping/distortion, the faulty
assets were re-cropped from the user's own design PNGs, all captures were
regenerated and the changed screens re-read by eye. Verified = seen in the new
capture; the Tasbih lantern sits below the capture fold, so that one is
verified by fit math (contain cannot crop) and marked as such.

| Page(s) | Was mis-fitting | Change (fit / alignment / re-crop) | Verified now |
|---|---|---|---|
| 36 Splash | NOOR tile's rounded corners cropped unevenly by `cover` (the old asset crop itself cut the tile at its edges) | Asset re-cropped tight from Page 36 (`splash_motif.png` 372×390, no baked "AI Companion" text); fit `cover` → `contain` | ✅ Capture: whole symmetric tile on cream |
| 01 Home | Next Prayer mosque: pale band across the card top, dome pushed out of the card by a 1.15 zoom, hard seam at the picture's left edge | Cream band cropped out of `next_prayer_mosque.png`; zoom removed, box widened 185→218, `cover` right-anchored (dome+minaret inside), left edge gradient-faded into the card | ✅ Capture: dome + crescent fully inside, no band, soft blend |
| 11 Quran Home | Daily Verse banner: both hanging lanterns cut at the card edges, Arabic diacritics clipped at the top | Banner re-cropped wider/higher from Page 11 at the code's exact aspect (`quran_banner_verse.png` 492×199) | ✅ Capture: both lanterns whole inside the card |
| 05 Audio | Arch card: fixed 190px height cropped the arch apex and sides | Height → `AspectRatio(417/255)` (the art's own aspect), whole arch in the box | ✅ Capture: full arch with emerald margin as drawn |
| 14 Worship | Header: left lantern cropped out of frame; Next Prayer mosque thumb: 1.38 zoom pushed the dome out of its box | Header re-cropped from Page 14 at box aspect (482×195, design's own bell excluded — the app draws its own), `bottomCenter`; thumb zoom removed, `cover` anchored `bottomRight`; rehal thumb 62→68 high | ✅ Capture: both lanterns + skyline whole; dome/minaret inside thumb |
| 06 Salah | Header skyline: side domes cropped; Learn Salah art carried baked-in text fragments ("Step"/"audio") at its left edge | Header height 84→98 (≈ strip aspect at full width); `salah_prostration.png` re-cropped (185×157) with the text fragments cut out | ✅ Capture: crescent + skyline fuller; prostration text gone by crop (card is below the capture fold — fit-verified) |
| 12 AI Home | Dome header: white corner triangles baked into the asset's bottom showed as a white sliver; both minarets cropped | White corners cropped off `ai_header_mosque.png` (205×178); box widened 165→190 | ✅ Capture: no white sliver, left minaret back in frame |
| 13 Settings | Lantern blown up ~3× and cropped at the screen edge (tall portrait crop stretched across a wide header) | Asset re-cropped from Page 13 at design scale (both hanging lanterns, 160×195, no status-bar icons); shown as a right-side strip (140 wide, `topCenter`) with a left fade into the emerald | ✅ Capture: two whole lanterns hanging at the right, as drawn |
| 15 Hadith Library | Four covers **stretched** (`BoxFit.fill` squeezed 0.92-aspect crops into a 0.81 box); header strip: left lantern halved by the side crop; Books+Lantern thumb carried a stray strip on top and a lantern cut at the asset edge | Covers re-cropped book-tight from Page 15 at the exact box aspect (0.807–0.809) and fit `fill` → `cover`; header strip height 96→74 (≈ its own aspect, lantern survives); thumb re-cropped from Page 15 (190×115) in a wider 104×76 box | ✅ Capture: four undistorted whole books; lantern whole in the header band |
| 09 Hadith Day | Same header strip as Page 15: lantern halved at the left edge | Band height 92→76 (≈ strip aspect at full width) | ✅ Capture: gold lantern whole |
| 10 Qibla | Direction-card mosque: minaret tops cropped (tall asset, wide box, `cover`) | Fit `cover` → `contain` (asset's white ground matches the white card — no seam) | ✅ Capture: whole mosque + Kaaba in the card |
| 07 Tasbih | Insights lantern finial/base cropped (tall asset, wide box, `cover`) | Fit `cover` → `contain` | ⚠️ Fit-verified (contain cannot crop); the card is below the capture fold, so not eye-verified in this pass |
| 02/03/05, 08, others audited, no change | Reciter avatar circles (face centred, as drawn), medallions 08/09 (square assets in square ovals), calligraphy roundels (full-bleed as drawn), rehal/hands 92×92 cards, Salah Insights lantern (already `contain`), Qibla Kaaba centre (box aspect = asset aspect), lantern promo cards (dark-ground art, `cover` correct) | — | ✅ Re-read in recaptures; no distortion, no cut faces/calligraphy |

### Phase 11b verification (executed 2026-10-07, this machine)
- `flutter analyze` — **"No issues found!"**
- `flutter test test/previews_test.dart --update-goldens` — **43/43 passed** (42 screens + suite teardown); changed screens re-read by eye (36, 01, 11, 05, 14, 06, 12, 13, 15, 09, 10 above).
- Normal suite (previews excluded) — **7/7 passed**.
- `flutter build web` — **✓ Built build/web**.
- No redesign: Noor tokens only; every new pixel is a crop of the user's own design pages. Pixel-perfect remains the user's call on the new captures.
