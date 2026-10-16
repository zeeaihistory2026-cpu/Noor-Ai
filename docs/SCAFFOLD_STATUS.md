# NOOR AI Companion — Flutter Scaffold Status
Date: 2026-10-06 · Stack: **Flutter** (user locked Flutter over React Native + Expo; the earlier Expo scaffold was interrupted/abandoned — do not use `../expo-app/`)
Design source: `~/workspace/noor-design/NOOR_AI_Companion_Complete_UI_Pages_01-42/` (42 PNGs + README)

## Quality bar set by the user
Act as senior developer + senior UX/UI designer. The app must be **pixel-perfect to the shared design — the same design, not an interpretation.** This scaffold therefore names its tokens after the design (see `lib/theme/noor_theme.dart`: `NoorColors`, `NoorSpacing`, `NoorRadius`, `NoorSizes`, `NoorShadows`, `NoorAssets`) so each screen can be matched 1:1 page by page against its PNG.

## ⚠️ Pixel-perfect artwork — MUST come from the user's design files
The user already flagged that the web prototype's backgrounds/images were *not* faithful. For the Flutter app, **real background/hero artwork must be extracted/sourced from the user's PNGs — never replaced with generated or generic placeholders:**
- Next-prayer hero mosque (dome + minarets, right side of card) — Page 01 → `assets/images/next_prayer_mosque.png`
- AI header mosque (green dome, stars) — Page 12 → `assets/images/ai_header_mosque.png`
- Splash motif / NOOR tile art — Page 36 → `assets/images/splash_motif.png`
- Lantern illustration — Pages 09/12 → `assets/images/lantern.png`
- Dua hands illustration — Pages 01/08 → `assets/images/dua_hands.png`
- Qur'an on rehal illustration — Pages 01/09 → `assets/images/quran_rehal.png`
- Surah calligraphy roundel (Continue Quran) — Page 01 → `assets/images/surah_calligraphy.png`
- Plus per-page art on Pages 03–05, 19–22, 26–27 (reader/player/share/voice/hifz headers).
Until each file is exported (crop at 2x/3x from the PNGs, or re-export from the original design source if the user provides it), the scaffold uses clean emerald gradients/solid tiles in those slots — clearly marked TODO in code, and **not** a design-faithful substitute.

## How to run
```bash
cd ~/workspace/noor-app/flutter-app
flutter pub get
flutter run            # or: flutter run -d chrome
```
Flow: Splash (36, "Enter NOOR" is a real FilledButton + Navigator.push) → Onboarding (37) → Goal (38) → Language (39) → Madhhab (40) → Create Account (41) / Login (42) → 5-tab shell.

## Structure (49 Dart files)
- `pubspec.yaml` — Flutter, `google_fonts`, `cupertino_icons`, `flutter_lints`; assets folder declared. Dependencies kept minimal/mainstream; add feature packages (audio, sensors, notifications, http) per phase, mirroring the feature map in `../react-native-expo-build-plan.md`.
- `lib/main.dart` — entry, `runApp(NoorApp)`.
- `lib/theme/noor_theme.dart` — exact palette: emerald `#0F5132`, emeraldDark `#0B3D2E`, emeraldMid `#135C46`, gold `#D4AF37`, goldSoft `#C8A96A`, cream `#F7F4EA`, creamAlt `#F6F8F6`, sand `#EDE7D6`, ink `#1C1C1C`; radii (card 20, hero 24, button 16, input 28, splash tile 44), spacing (page padding 20, card padding 16), bottom-nav height 64, soft card shadows, Manrope text theme.
- `lib/app.dart` — `NoorApp` (MaterialApp) + `NoorTabShell` (IndexedStack + NavigationBar): Home / Quran / AI / Worship / Library.
- `lib/data/sample_data.dart` — brief sample data only (short dua/hadith excerpts with attribution, as shown in the design). Full religious text must come from a licensed/API source at runtime.
- `lib/widgets/` — `NoorStubScreen` (page-numbered placeholder), `NoorFlowScreen` (onboarding/auth step).
- `lib/screens/home/` — **Home Dashboard (Page 01) implemented**: greeting + Hijri date, next-prayer card, Salah/Dhikr/Quran streak cards (12/8/17), Dua of the Day, Hadith of the Day, Continue Quran (Al-Kahf, 76%), Ask AI input; plus stubs 08, 09, 13, 32, 34, 35.
- `lib/screens/quran/` — stubs 02, 03, 04, 05, 11, 27, 28, 29, 30.
- `lib/screens/ai/` — stubs 12, 23, 24, 25, 26.
- `lib/screens/worship/` — stubs 06, 07, 10, 14, 31.
- `lib/screens/library/` — stubs 15, 16, 17, 18, 19, 20, 21, 22, 33.
- `lib/screens/onboarding/` — Splash 36 + flow screens 37–40. `lib/screens/auth/` — 41, 42.
All 42 design pages have a named screen file/class; tab roots are Pages 01/11/12/14/15-hub, everything else is pushed via Navigator.

## Verification — honest status
- ✅ File structure created and inventoried (49 `.dart` files); Python brace/paren balance check passed on all files.
- ❌ `flutter analyze` / `dart format` / `flutter pub get` / run **could not be executed**: `flutter` and `dart` are **not installed** in this environment (`which flutter dart` → not found). No passing build is claimed.
- First action for a developer (or next session with Flutter installed): `flutter pub get && flutter analyze && flutter run`, fix any lint/typing nits, then start the page-by-page pixel match beginning with Pages 01, 36, 03, 12.

## Next steps (in order)
1. Export the real artwork listed above from the user's design files into `assets/images/` and wire `NoorAssets` slots (Home hero first).
2. Implement screens page-by-page in design order, diffing side-by-side with each PNG (radii/spacing/type from `noor_theme.dart`).
3. Add live data: AlAdhan (prayer/Hijri/Qibla), AlQuran Cloud/Quran.com (Qur'an text/translation/audio) — brief excerpts only in code.
4. Feature phases per `../react-native-expo-build-plan.md` (same screen/feature map, Flutter packages substituted).

## Phase 1 — Implemented 2026-10-06 (senior dev + designer pass)
Implemented properly (replacing NoorStubScreen/NoorFlowScreen for these pages), matching each PNG's layout order, palette, radii and hierarchy:
- **Page 36 Splash** — cream page, emerald tile (real crop, below), AI Companion / Faith • Guidance • Growth, Loading…, Enter NOOR button → Onboarding.
- **Page 37 Onboarding** — Skip, pale-emerald QURAN circle hero, "Learn. Practice. Grow." + promise line, Continue pill.
- **Page 38 Goal Selection** — 2-col selectable goal grid (Quran reading/Salah consistency/Memorization pre-selected as drawn), Continue.
- **Page 39 Language Selection** — English selected emerald row; Urdu/Arabic/Bahasa rows with native + English labels.
- **Page 40 Madhhab Preference** — Hanafi selected; radio dots; "Show all recognized opinions" / "I'm not sure" included.
- **Page 41 Create Account** — Name/Email/Password pill fields, Create Account → tab shell, Login link → Page 42.
- **Page 42 Login** — Welcome back, Email/Password, Forgot password?, Login → tab shell, Create account link.
- **Page 11 Quran Home** — dark header + pill tabs, banner excerpt (Al-Isra 17:9, brief/attributed), Continue Reading (Al-Baqarah), Surahs preview (5 rows), Listen to Quran, Daily Verse (Al-Kahf 18:24, brief/attributed), dark Quick Actions.
- **Page 02 Surah List** — dark header + pill tabs, Continue Reading Al-Kahf 76%, working search field, Order/Translation filters, surah rows 1–10 with Arabic titles, dark mini player (Al-Kahf / Mishary Rashid Alafasy).
- **Page 01 Home Dashboard — polished**: mosque art on Next Prayer card, bell with red dot + dome avatar, streak cards with icons + flame row, Listen/Save/Share actions, calligraphy roundel, AI input now taps through to AI Home.
New shared widgets: `lib/widgets/noor_components.dart` (NoorScaffold, NoorPrimaryButton, NoorCard, NoorOptionTile, NoorRadioDot, NoorInitialBadge, NoorFormField, NoorDarkHeader, NoorPillTabs).

### Artwork extracted from the user's design PNGs (Python PIL, cropped inside the phone mockups)
Wired via NoorAssets: `assets/images/next_prayer_mosque.png` (Page 01), `ai_header_mosque.png` (Page 12), `splash_motif.png` (Page 36 tile incl. NOOR wordmark), `dua_hands.png`, `quran_rehal.png`, `surah_calligraphy.png` (all Page 01), `lantern.png` (Page 12 — cropped but not yet placed on a Phase 1 screen; reserved for the AI promo card in Phase 2). Crops were visually checked; they are the user's own design art, not generated substitutes.
Still TODO (gradient/solid slots, do not present as faithful): per-page header art for Pages 03–05, 19–22, 26–27; the Page 37 hero is currently a pale-emerald circle in code pending a clean export. Prefer re-export at 2x/3x from the original design source if the user provides it.

### Verification — honest
- ✅ Python brace/paren balance check PASS on all 12 changed Dart files; all 7 asset files exist and are wired.
- ❌ Compile/run NOT verified: Flutter/Dart are not installed in this environment (per instructions, SDK install was not attempted). First run elsewhere: `flutter pub get && flutter analyze && flutter run`.

### Exact next phase (Phase 2)
Page 03 Quran Reader (EN/Urdu), Page 05 Audio Player, Page 12 AI Assistant Home, Page 23 AI Chat, Page 06 Salah Tracker, Page 07 Tasbih — in that order, same PNG-by-PNG method, then wire AlAdhan + AlQuran Cloud live data.

## Phase 2 — Implemented 2026-10-06
Implemented properly (replacing stubs), matched to the PNGs in layout order, palette, radii and hierarchy using only `NoorColors`/`NoorRadius`/`NoorSpacing` tokens:
- **Page 03 Quran Reader** — emerald Al-Kahf header, Arabic/English/Urdu segmented tabs (switch displayed translation), Text Size slider that resizes the ayah, ayah-18 card with one **brief excerpt only** (full Qur'an text/translation comes from a licensed/API source at runtime), Quick Tools (Tafsir/Word by Word/Listen/Share/Copy — Listen opens Page 05), one-line tafsir preview placeholder (no tafsir text reproduced), Next Ayah row, sticky bottom audio player.
- **Page 05 Quran Audio Player** — dark emerald page, cream arch card with the real `player_arch.png`, Surah Al-Kahf / Juz 15 / Page 293 stats, reciter row, working seek slider + play/pause state, Speed/Timer/Sleep/Download/Share, Playback Range chips, Repetition steppers (−/+ repeat count, pause secs), Up Next with Autoplay toggle, dark mini-player.
- **Page 12 AI Assistant Home** — dark header with the already-extracted `ai_header_mosque.png`, greeting, Ask-a-question pill (mic → Page 26, send → Page 23), 4 Suggested Questions, Recent Conversations, lantern promo card using the extracted `lantern.png`, Popular Topics row.
- **Page 23 AI Chat** — emerald AI Companion header, emerald right / cream left bubbles (sample exchange kept brief, as in the design), "Show sources" → Page 24, follow-up input that appends a real exchange in code.
- **Page 06 Salah Tracker** — header with real `salah_header_mosque.png`, Today's Prayers 5 columns (tappable checks, Asr highlighted + remaining), dark 12-day streak card, Monthly Overview 91%/28/3 with progress bar, Insights with `salah_lantern.png`, Quick Actions (Reminders → Page 31, Qibla → Page 10), Learn Salah with `salah_prostration.png`.
- **Page 07 Zikr Tasbih** — tabs, 8-day streak bar, **working counter in code**: tap circle/Add increment, Undo decrements, reset clears, target chips 33/66/99/100/Custom, gold-ring circle with beads arc, tappable Other Dhikr cards, live Today's Progress total, Daily Tip with lantern art.

### Artwork extracted in Phase 2 (Python PIL, cropped inside the phone mockups, visually checked)
`player_arch.png` (Page 05), `salah_header_mosque.png`, `salah_lantern.png`, `salah_prostration.png` (all Page 06) — the user's own design art, wired via new `NoorAssets` slots. A tasbih-beads crop was attempted and **discarded** (it captured the counter digits); the Tasbih beads are drawn as a gold-ring bead arc in code instead — marked here honestly, not claimed as extracted art.
Still TODO art: Pages 19–22 (share studio) and 26–27 (voice/hifz) header art; Page 37 hero clean export. Do not present gradient/code-drawn slots as design-faithful.

### Verification — honest
- ✅ Python brace/paren/bracket balance check PASS on all 8 changed Dart files (`quran_reader`, `quran_audio_player`, `ai_assistant_home`, `ai_chat`, `salah_tracker`, `zikr_tasbih`, `noor_theme`, `sample_data`); all 11 asset files exist on disk.
- ❌ Compile/run NOT verified: Flutter/Dart are not installed in this environment and the SDK was not installed (per instructions). First run elsewhere: `flutter pub get && flutter analyze && flutter run`.

### Exact next phase (Phase 3)
Page 24 AI Answer Sources, Page 25 Compare Madhhab Opinions, Page 26 Voice AI Companion, Page 10 Qibla Finder, Page 14 Worship Dashboard, Page 31 Prayer/Zikr Reminder Center — in that order, same PNG-by-PNG method — then wire live data (AlAdhan prayer times/Hijri/Qibla, AlQuran Cloud/Quran.com Qur'an text, translation and audio), replacing the brief sample data screen by screen.

## Phase 3 — Implemented 2026-10-06
Implemented properly (replacing stubs), same PNG-by-PNG method, `NoorColors`/`NoorRadius`/`NoorSpacing` only:
- **Page 24 AI Answer Sources** — emerald AI Companion header, emerald question bubble ("Explain the importance of Tahajjud", as drawn), sand AI Explanation card with a short descriptive summary + Sources cited by reference only (Quran 17:79 • Sahih Muslim 1163), "High source confidence", and the 4 outline rows (Simple explanation / Scholarly context → Page 25 / Related Quran & Hadith / Ask a follow-up → back to chat). No religious text reproduced beyond the design's brief citations.
- **Page 25 Compare Madhhab Opinions** — descriptive compare only: pale question card ("Does touching spouse break wudu?") + Hanafi (Your preference) / Shafi'i / Maliki / Hanbali cards, each with the design's one-line recognized-position summary and "View evidence ›", plus a respectful note to consult a qualified scholar for personal rulings. No original religious rulings issued.
- **Page 26 Voice AI Companion** — header, "Speak your question", 232px emerald listening circle with white waveform bars (tap toggles Listening… / Tap to speak — UI state only), transcript pill with the design's sample question, Try asking rows → AI Chat, private-mode note.
- **Page 10 Qibla Finder** — cream page as drawn (no dark header), Makkah location row + Update Location, gold-ring compass (272px) with cardinal labels, gold NW pin and the real Kaaba crop at centre, 295° / North West / distance, direction card with mosque crop, Compass/AR View/Sun Position/Map View tiles, Helpful Tips with lantern crop, Recently Used Locations (Home Lahore 296° NW, Work Dubai 288° WNW). Tappable state: none needed; **TODO live**: bearing is the design's sample 295° — live location + magnetometer bearing to 21.4225°N, 39.8262°E is marked TODO(phase-live) in code, never presented as measured.
- **Page 14 Worship Dashboard** — skyline header (real crop), quote card overlapping (brief Ta-Ha 20:14 excerpt, attributed, as drawn), Prayer Times + Makkah/21 Jun 2024 header, dark Zuhr next-prayer card with countdown and mosque crop, 6 prayer rows with working bell/mute toggles, Full Prayer Timings → Salah Tracker, 8 Worship Tools (Qibla → Page 10, Tasbeeh → Page 07 wired), Today's Goal 75% ring with rehal crop, Streak 12 / Longest 23.
- **Page 31 Prayer & Zikr Reminder Center** — emerald header, Salah (5) / Worship (3) / Daily Content (2) groups exactly as drawn, every row a working emerald toggle kept in code state, quiet-hours note. **TODO live**: persist toggles and schedule local notifications (flutter_local_notifications) in the live-data phase.

### Artwork extracted in Phase 3 (Python PIL, cropped inside the phone mockups, visually checked)
`qibla_kaaba.png` (Page 10 compass centre), `qibla_mosque.png` (Page 10 direction card), `worship_header_skyline.png` (Page 14 header) — the user's own design art, wired via new `NoorAssets` slots (`qiblaKaaba`, `qiblaMosque`, `worshipHeaderSkyline`). Pages 24/25/26/31 headers in the design are plain emerald with no artwork, so no crops were needed there; no generic substitutes were introduced. Reused earlier faithful crops: `lantern.png`, `next_prayer_mosque.png`, `quran_rehal.png`.
Still TODO art: Pages 19–22 (share studio), 27 (hifz header), Page 37 hero clean export.

### Verification — honest
- ✅ Python brace/paren/bracket balance check PASS on all 8 changed files (`ai_answer_sources`, `madhhab_compare`, `voice_ai`, `qibla_finder`, `worship_dashboard`, `reminder_center`, `noor_theme`, `sample_data`); all 14 asset files exist on disk; the 3 new crops were visually checked against their PNGs.
- ❌ Compile/run NOT verified: Flutter/Dart are not installed in this environment and the SDK was not installed (per instructions). First run elsewhere: `flutter pub get && flutter analyze && flutter run`.

### Exact next phase (Phase 4)
1. **Page 04 Hifz Mushaf 16-Line** — fixed 16-line page layout (the hardest pixel-match; use cropped Mushaf page art from the design first, text-from-API after).
2. **Pages 27–30 Hifz AI loop** — 27 Hifz AI Test (mic UI + recording state; TODO live speech recognition), 28 Test Results, 29 Revision Planner, 30 Weak-Page Heatmap — in that order.
3. **Pages 15–18 Hadith/Dua libraries** — 15 Hadith Library, 16 Book Chapters, 17 Hadith Detail + AI Explanation (brief attributed excerpts only, sources first), 18 Dua/Adhkar Library.
4. **Live data wiring** — AlAdhan (live prayer times, Hijri date, Qibla bearing replacing Page 10/14 samples, reminder scheduling for Page 31), AlQuran Cloud/Quran.com (Reader/Audio text, translation, audio URLs replacing brief samples screen by screen), then AI backend for Pages 12/23/24/26 with cited sources. Keep all in-code religious text to brief attributed excerpts until the licensed/API source is wired.

## Phase 4 — Implemented 2026-10-06
Implemented properly (replacing stubs), PNG-by-PNG, `NoorColors`/`NoorRadius`/`NoorSpacing` only, brief attributed excerpts only — no substantial Qur'an/Hadith/Dua text in code:
- **Page 04 Hifz Mushaf 16-Line** — Al-Baqarah / Juz 1 • Page 2 header, "16-Line Page View" strip, ornate double-bordered Mushaf frame (drawn in code: gold/emerald borders, page tab) with a **fixed 16-line layout**: line 1 carries the design's short opening fragment, the remaining ruled lines are slots only. Previous/Next (2/604), Listen/Repeat/Bookmark/Test Me/Tafsir/More tool row (Test Me → Page 27), Hifz Progress dots row → Page 30. TODO live: full Mushaf page text/rendering from the licensed source — never pasted into code. A cropped frame-top strip was extracted, inspected, found to contain verse text, and **discarded** for this reason.
- **Page 27 Hifz AI Test** — emerald header (Al-Baqarah • Juz 1), Test range "Pages 25–28" card, "Begin from this cue:" with the design's brief cue fragment, 236px RECITE circle that toggles Listening UI state and reveals "Finish & See Results" → Page 28, Privacy card. TODO live: microphone, speech recognition and word-tracking — nothing is claimed to analyse audio yet.
- **Page 28 Hifz Test Results** — Memorization Accuracy hero (**93%** as drawn, gold on emerald), Ayah 38/40/42 mistake rows with Review/Practice pills → Page 29, AI suggestion card, Retest Weak Range → Page 27. Memorization feedback only, no tajweed claim, as the design notes require.
- **Page 29 Hifz Revision Planner** — Today's Hifz Plan: New lesson (½ page • Page 31, 10 min), Recent revision (Pages 26–30, 7 min), Old revision (Juz 30, 8 min) progress cards that toggle done, AI Scheduling (morning accuracy) card, View Page Strength → Page 30.
- **Page 30 Hifz Progress Weak-Page Heatmap** — Juz 1 • Page Strength grid of 30 page tiles in the PNG's colour pattern (deep emerald strong / sage medium / amber review / rust weak, colours read off the PNG), legend, tappable tiles, Weak-page insight card ("Page 5 caused errors in 3 recent tests." → Review Page 5).
- **Page 15 Hadith Library** — emerald header carrying the **real skyline+lantern crop**, overlapping search pill (working filter), Featured Collections (4 books with the real cover crop), Browse by Category grid (8, counts as drawn), Popular Books rows → Page 16, Build Your Knowledge card with the real books+lantern crop → Page 16. Names/counts only.
- **Page 16 Hadith Book Chapters** — Sahih al-Bukhari overview (Continue: Book of Faith • Hadith 25), working search, Chapters/Bookmarks/Notes chips, 7 numbered chapter rows with hadith ranges → Page 17.
- **Page 17 Hadith Detail AI Explanation** — brief attributed excerpt card (Arabic fragment + short translation, Sahih al-Bukhari • Hadith 1, Listen/Save/Share/Copy actions), AI Explanation card kept visually separate from the source text, Context (narrator), Related Sources, Ask AI button. Full text/chain from the licensed source at runtime.
- **Page 18 Dua Adhkar Library** — Daily Adhkar progress card (Morning set • 8 of 15, progress bar), working search, All/Morning/Evening/Situations filter chips, 8 numbered category rows (names/counts as drawn) → Tasbih (start dhikr, as the design intends). Full dua text loaded from the authenticated source at runtime.
- Wiring: Quran Home gained a Hifz Mode card (16-Line Mushaf / Hifz AI Test); Library tab root is now a hub linking Pages 15, 18, 19 and 33 so the implemented screens are reachable.

### Artwork extracted in Phase 4 (Python PIL, cropped inside the phone mockup, visually checked)
`hadith_library_header.png` (Page 15 skyline + hanging lanterns), `hadith_books_lantern.png` (Page 15 Build Your Knowledge books + lantern), `hadith_book_cover.png` (Page 15 featured/popular book cover) — the user's own design art, wired via new `NoorAssets` slots (`hadithLibraryHeader`, `hadithBooksLantern`, `hadithBookCover`). Discarded honestly: a Page 04 Mushaf frame strip that contained verse text (see Page 04 above); the Mushaf frame is drawn in code instead. Pages 16–18 and 27–30 headers in the design are plain emerald with no artwork, so no crops were needed there.
Still TODO art: Pages 19–22 (share studio headers/templates), Page 37 hero clean export. Do not present code-drawn slots as design-faithful.

### Verification — honest
- ✅ Python brace/paren/bracket balance check PASS on all 13 changed files (`noor_theme`, `sample_data`, `hifz_mushaf`, `hifz_ai_test`, `hifz_test_results`, `hifz_revision_planner`, `hifz_heatmap`, `quran_home`, `hadith_library`, `hadith_chapters`, `hadith_detail`, `dua_library`, `library_home`); each of the 3 new assets exists on disk and was visually checked against its PNG. A misplaced header-function insertion in 7 files was caught in review and fixed (headers now top-level `_noorHeader` functions, one per file).
- ❌ Compile/run NOT verified: Flutter/Dart are not installed in this environment and the SDK was not installed (per instructions). First run elsewhere: `flutter pub get && flutter analyze && flutter run`.

### Exact next phase (Phase 5)
1. **Pages 19–22 Share suite** — 19 Share Card Studio (format chips Post 4:5 / Story 9:16 / Square / Reel, template thumbnails cropped from the PNG), 20 Card Editor, 21 Animated Card Reel Creator, 22 Share Export — rendering/export via a share/image package decided at build time; use only brief, design-shown excerpts on cards.
2. **Page 32 My Journey Streak Analytics**, **Page 33 Bookmarks/Notes Saved Content**, **Page 34 Profile**, **Page 35 Notifications**, **Page 13 Settings** — same PNG-by-PNG method.
3. **Pages 08/09 Dua of the Day / Hadith of the Day** full screens (brief excerpt, Listen/Save/Share as drawn, reusing `dua_hands.png` / `quran_rehal.png` / `lantern.png`).
4. **Live data wiring (after all screens exist)** — AlAdhan: prayer times + Hijri on Pages 01/06/14, Qibla bearing replacing the Page 10 sample (location + magnetometer, Makkah 21.4225°N 39.8262°E), reminder scheduling for Page 31. AlQuran Cloud / Quran.com: Reader (03), Mushaf (04), Audio (05) and Hifz (27–30) with licensed text/translation/audio replacing brief samples screen by screen. AI backend for 12/23/24/26/27 with cited sources, keeping AI explanation visually separate from source text.

## Phase 5 — Implemented 2026-10-06
Implemented properly (replacing stubs), PNG-by-PNG, `NoorColors`/`NoorRadius`/`NoorSpacing` only, brief attributed snippets only:
- **Page 19 Share Card Studio** — emerald header, preview card via new shared `lib/widgets/noor_share_card.dart` (DAILY REMINDER / brief Quran 20:114 excerpt / NOOR), working format chips (Post 4:5 selected) that resize state, 4 template tiles (emerald/sand/dark/cream, gold ring on selected; code-drawn colour tiles exactly as the PNG's numbered placeholders — not extracted art), verified-content lock note, Edit Card → 20 / Animate → 21 / Export → 22.
- **Page 20 Card Editor** — same preview, Background (Cream/Green/Dark/Photo) / Typography (Arabic/English/Urdu) / Layout (Classic/Minimal/Centered) groups as drawn, NOOR watermark toggle, locked-source note, Reset + Done → 22. Selections update preview in code (live preview state; font/layout are preview-level, not rendering engine).
- **Page 21 Animated Card Reel Creator** — preview card, Animation style list (Soft Fade selected; Elegant Reveal / Arabic Writing / Glow), Preview 8-sec Reel button toggles a previewing state (AnimatedOpacity). **UI + in-code preview state only — no video rendered/exported, no fake export claim.**
- **Page 22 Share Export** — preview card, "Ready to share" 2-col grid (WhatsApp/Instagram/TikTok/Facebook/Save Image/Copy Link as drawn), tap selects a target and shows an honest later-phase note. **No file exported, no external app opened — no fake share claim.** Source reference stays attached (noted in UI).
- **Page 32 My Journey** — emerald hero "This Week / Strong consistency", Salah 93% (26/28) / Quran 71% (5/7) / Dhikr 100% (7/7) / Learning 60% (3 lessons) bars, pale AI Insight card, private/no-leaderboard note.
- **Page 33 Saved & Notes** — filter chips (All/Quran/Hadith/Duas/AI Notes) with working in-code filter, 5 saved cards as drawn (Quran 94:6, Sahih al-Bukhari 1, Dua for knowledge, Patience AI Note, Surah Al-Kahf note; brief snippets only).
- **Page 34 Profile** — AK circle, Abdullah Khan, Your Journey emerald card (taps → Page 32), 7 outline rows as drawn; Saved Content → 33 and Settings → 13 wired, others inert until their screens/phases exist.
- **Page 35 Notifications** — Today (Fajr reminder, Daily Dua, Quran) and Earlier (Hifz plan, Hadith, AI insight) groups as drawn, pale initial circles.
- **Page 13 Settings** — dark header with the real lantern crop (below), overlapping profile card (Abdullah Khan, abdullah.khan@email.com → Page 34), Account / App Preferences / Support & About groups exactly as drawn with right-side values (English, System, Medium, v1.2.0), Log Out outline button.
- **Page 08 Dua of the Day** — date header, white dua card (mosque badge, brief excerpt/transliteration/translation, Quran 20:114, Listen/Save(bookmark toggles)/Share(→19)/Copy), About, More Duas chips, dark Share Your Card preview with Customize → 19, platform row.
- **Page 09 Hadith of the Day** — dark header carrying the real skyline crop, overlapping white card (calligraphy roundel reusing `surah_calligraphy.png`, brief Arabic excerpt, short translation as drawn, Sahih al-Bukhari 1, Listen/Save/Share/Copy), About, Reflection, Share & Earn Reward → 19, More Hadiths.
- Wiring: Library hub gained Profile (34) and Settings (13) rows so every Phase 5 screen is reachable; Home already pushed 08/09/32/35.

### Artwork extracted in Phase 5 (Python PIL, cropped inside the phone mockup, visually checked)
`settings_lanterns.png` (Page 13 header hanging gold lantern) — the user's own design art, wired via new `NoorAssets.settingsLanterns`. Attempted broader crops first landed outside the phone mockup and were redone/verified. Reused faithful crops: `hadith_library_header.png`, `surah_calligraphy.png`, `lantern.png`.
Code-drawn honestly (not claimed as extracted/f faithful art): Share-suite template tiles 1–4 and format previews (the PNG itself shows flat colour/number placeholders there). Still TODO art: Page 37 hero clean export; share-template photographic backgrounds (the design's "Photo" theme) if the user wants photo templates — no generic stock substituted.

### Verification — honest
- ✅ Python brace/paren/bracket balance check PASS on all 16 changed files (theme, sample_data, noor_share_card, noor_components, share_card_studio, card_editor, reel_creator, share_export, saved_content, library_home, my_journey, profile, notifications, settings, dua_of_the_day, hadith_of_the_day); all 18 asset PNGs exist on disk; new crop visually checked.
- ❌ Compile/run NOT verified: Flutter/Dart are not installed in this environment and the SDK was not installed (per instructions). First run elsewhere: `flutter pub get && flutter analyze && flutter run`.

### Exact next phase (Phase 6) — suggested: live data + first real run
1. **First real-device run checklist (do first):** install Flutter stable → `flutter pub get` → `flutter analyze` (fix lints) → `flutter run` on Android device/emulator and iOS simulator → walk Splash 36→tabs→all pushed screens, tap-test every button (the web prototype's dead Enter NOOR lesson) → screenshot Pages 01/03/08/09/13/19/32 side-by-side with PNGs and log pixel diffs → fix before adding data.
2. **Data layer (new `lib/data/live/` with sample-data fallback):** repository interfaces (`PrayerRepository`, `QuranRepository`, `ProgressRepository`) that return `SampleData` when offline/unconfigured, so screens never break.
3. **AlAdhan (free, no key; method 5 Karachi default):** live prayer times + Hijri date on Pages 01/06/14, next-prayer countdown, Qibla bearing on Page 10 from device location (geolocator) + magnetometer (flutter_compass) toward Makkah 21.4225°N, 39.8262°E replacing the 295° sample.
4. **AlQuran Cloud / Quran.com:** surah list (02), reader Arabic + EN/Urdu translations (03), Mushaf (04), audio URLs + real playback (05, just_audio), bookmarks — licensed/API text replaces brief in-code excerpts screen by screen (keep excerpts only as offline fallback, attributed).
5. **Local storage:** shared_preferences for settings/reminder toggles/language/madhhab (Pages 13/31/39/40), plus a local DB (drift/sqflite) for streaks (06/07/32), bookmarks/notes (33), saved profile state (34) — replacing in-code state.
6. **Notifications:** flutter_local_notifications scheduling for Page 31 groups + Page 35 inbox persistence (salah 15-min-before, adhkar, daily dua/hadith), with Android exact-alarm permission handling.
7. **Share/Reel real export (only then claim it):** screenshot/render card to image (widgets_to_image / screenshot package) + share_plus for Pages 19/20/22; video only if a rendering pipeline is chosen for Page 21 — otherwise keep it labelled preview.

## Phase 6 — Live data layer (code only) — Implemented 2026-10-06
Implemented in code, with sample-data fallback everywhere so NO screen can break offline. Screen layouts are unchanged — only underlying data strings/rows swap when live data arrives.

### Dependencies added (pubspec.yaml)
- `http: ^1.2.2`, `shared_preferences: ^2.3.4` — mainstream, no native configuration needed.
- Deliberately NOT added: `flutter_local_notifications` (needs Android/iOS native setup that cannot be verified here) — see TODO below.

### New files (lib/data/)
- **`prayer_service.dart`** — AlAdhan (free, no API key). Endpoint constants per the public docs: `/v1/timingsByCity/{DD-MM-YYYY}?city=&country=&method=`, `/v1/timings/{DD-MM-YYYY}?latitude=&longitude=&method=`, `/v1/gToH/{DD-MM-YYYY}` (Hijri), `/v1/qibla/{lat}/{lng}`. Method **5 (Karachi)** default — also a `NoorStore` setting. Parses timings (strips e.g. "(PKT)"), Hijri date, next-prayer + countdown labels; Qibla bearing tries the API then falls back to a local great-circle computation to Makkah 21.4225°N, 39.8262°E. Cache chain: live → in-memory → `shared_preferences` persisted last response → `PrayerDay.sample()` (design times).
- **`quran_service.dart`** — AlQuran Cloud (free, no key): `/v1/surah` (114 list, persisted-cached, sample fallback), `/v1/surah/{n}/{edition}` and `/v1/surah/{n}/editions/quran-uthmani,en.sahih,ur.jalandhry` (Arabic + Saheeh International EN + Fateh Muhammad Jalandhari UR), per-ayah audio + Islamic Network CDN URL builder (`cdn.islamic.network/quran/audio/{bitrate}/{edition}/{globalAyah}.mp3`, default `ar.alafasy`). Quran.com API v4 present as clearly-marked STUBS (URL builders + chapters call; no screen depends on them). **No Qur'an text embedded in code** — full text exists only as runtime API responses.
- **`noor_store.dart`** — `shared_preferences` wrapper with in-memory fallback if the plugin is unavailable (never throws): calculation method (default 5), language, madhhab, city/country, Page 31 reminder toggles, streaks, Salah log (JSON per day), bookmarks (IDs like `quran:18:18`), generic JSON cache used by the services.
- **`notification_plan.dart`** — pure Dart: turns a `PrayerDay` + Page 31 toggles into a sorted `PlannedNotification` list (Salah at prayer −15 min, matching Page 35's "begins in 15 minutes"; Worship/Daily Content at their Page 31 clock times, rolling to tomorrow when past).
- **`notification_todo.dart`** — TODO(phase-7) wiring file: the exact `flutter_local_notifications` checklist (permissions, exact-alarm handling, channels, `timezone`/`zonedSchedule`, daily re-planning, device-test gate). Its `schedulePlan` throws `UnimplementedError` on purpose — **nothing is scheduled today, and no UI copy says it is**.

### Screens wired (layouts identical)
- **Page 01 Home Dashboard** — now a StatefulWidget; greeting Hijri line and Next Prayer name/time/countdown initialise from `SampleData` (identical offline) and swap in place only when a LIVE AlAdhan response lands.
- **Page 02 Surah List** — rows initialise from the 10 sample surahs and swap to the full 114 when `QuranService.fetchSurahListOrFallback()` returns the live/cached index; search/filter and footer text follow the data actually shown.

### Verification — honest
- ✅ Python brace/paren/bracket balance check PASS on all 7 changed/created Dart files (`noor_store`, `prayer_service`, `quran_service`, `notification_plan`, `notification_todo`, `home_dashboard_screen`, `surah_list_screen`); all 56 Dart files in `lib/` pass the raw-count heuristic.
- ❌ NOT verified: `flutter pub get`, `flutter analyze`, compile, run — Flutter/Dart are NOT installed in this environment and the SDK was not installed (per instructions). **No HTTP call has been live-tested**; all parsing is coded to the documented AlAdhan/AlQuran Cloud response shapes and must be confirmed on first run. No notification is scheduled. No audio plays yet (URL builder only).

### Phase 7 plan (next)
1. **First real run:** install Flutter stable → `flutter pub get` → `flutter analyze` (fix lints/typing) → `flutter run` on a real Android device + iOS simulator; tap-test Splash→tabs→every pushed screen (the dead Enter NOOR lesson); confirm AlAdhan/AlQuran calls succeed live and fix any parse drift against real responses; screenshot-diff Pages 01/02/03/12 against the PNGs.
2. **Reader/Mushaf/Audio on the services:** Page 03 swaps its brief excerpt for `fetchSurahEditions`; Page 05 gets real playback (add `just_audio` + lock-screen controls); Page 10 gets device location (geolocator) + magnetometer (flutter_compass) feeding `fetchQiblaBearing`.
3. **Notifications (the TODO file):** add `flutter_local_notifications` + `timezone`, do the Android/iOS native setup, schedule `NotificationPlan` output, device-test a killed-app Fajr−15 alarm before any "scheduled" claim.
4. **Accounts + backend:** auth API for Pages 41/42 (tokens in secure storage), profile/settings sync (13/34), streak/salah-log persistence already prepared in `NoorStore`.
5. **AI backend wiring:** Pages 12/23/24/26 chat + voice and Hifz 27–30 analysis against an AI API with cited sources, explanation kept visually separate from source text.
6. **Store prep:** app icons/splash from the user's art, bundle IDs, privacy labels (microphone/location/notifications), Play/App Store listings, internal testing tracks.

## Phase 7 — First real run (compile-verified) — 2026-10-06
This was the missing verification step Phases 1–6 honestly flagged. It was actually executed in this environment; outputs below are real, not claimed.

### SDK install — SUCCEEDED
- Disk check first: 99 GB free (1% used) — well above the 8 GB stop threshold.
- Shallow clone of Flutter stable into `~/workspace/flutter-sdk` (`git clone --depth 1 -b stable`), then first `flutter --version` downloaded the Dart SDK (227 MB) and built the flutter tool (~14 min total).
- Installed: **Flutter 3.47.6 • channel stable** (framework revision 5fc346839b, 2026-09-30), **Dart 3.13.5**, DevTools 2.60.0. SDK on disk: 1.2 GB.
- Environment quirk fixed: running as root, GNU tar failed extracting the Gradle wrapper (`Cannot change ownership to uid…`). Workaround used for every flutter command below and required on this machine: `export TAR_OPTIONS=--no-same-owner` and `PATH=$HOME/workspace/flutter-sdk/bin:$PATH`. (Also expected: "Woah! You appear to be trying to run flutter as root" warning — harmless here.)

### pub get / analyze / test / build — ALL PASS
- `flutter pub get` — SUCCEEDED (after the tar workaround; 64 dependencies resolved, `pubspec.lock` created). Note: `shared_preferences` resolved to 2.5.6 within the `^2.3.4` constraint; 6 packages report newer versions incompatible with constraints (informational only).
- `flutter analyze` (first run) — **71 issues**: 1 warning (`unused_import` in `lib/screens/library/card_editor_screen.dart`) + 70 info (`prefer_const_constructors` / `prefer_const_literals_to_create_immutables` across 18 files). No compile errors anywhere in the 56 Dart files.
- Fix applied: `dart fix --apply` — **29 fixes made in 18 files** (const constructors; the unused import was removed as part of the same pass). No UI, layout, colour or content was changed — const-only.
- `flutter analyze` (re-run, and again after Phase 7 comment edits + `dart format` on the 3 touched files) — **"No issues found!"** ✅
- Platform folders generated: `flutter create . --project-name noor_ai_companion --platforms=web,android,ios` — wrote 78 files (android/, ios/, web/, default test). Verified by diff that `lib/` and `pubspec.yaml` were **not** overwritten. The Flutter tool added `build/**`, `android/**`, `ios/**`, `web/**` analyzer excludes to `analysis_options.yaml` (tool-managed, kept).
- `flutter test` — the generated default counter test referenced a non-existent `MyApp` and was replaced with a real NOOR smoke test (`test/widget_test.dart`: pumps `NoorApp`, expects the Splash "AI Companion" title and an "Enter NOOR" button). **Result: 1/1 passed — "All tests passed!"** ✅ Run twice (before and after formatting), passed both times.
- `flutter build web` — **SUCCEEDED**: "✓ Built build/web", `build/web/main.dart.js` 2.8 MB, exit 0 (~189 s compile; Wasm dry-run also succeeded). This is compile proof for the full app on a headless target; it is not a device run.
- First-real-run result in plain language: **the app compiles cleanly, boots to the Splash screen in tests, and builds for web.** It has NOT yet run on a real phone (no emulator/device in this environment) — see Phase 8.

### Live API tests (shell curl/python, 2026-10-06) — ALL HTTP 200, parsers confirmed
Only HTTP status, field names and counts were recorded; no religious text was pasted into any file or this report.
- AlAdhan `GET /v1/timingsByCity/06-10-2026?city=Karachi&country=Pakistan&method=5` — **200**. Shape: top-level `code/data/status`; `data` = `date/meta/timings`; 11 timing fields including Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha; `date.hijri` present with `month` as an object containing `en`; `date.gregorian.date` present. Matches `PrayerDay.fromAlAdhanJson` exactly — **no parser change needed**.
- AlAdhan `GET /v1/gToH/06-10-2026` — **200**; `data.hijri` has `day`, `month` (object with `en`), `year` — matches `fetchHijriDisplay`.
- AlAdhan `GET /v1/qibla/24.8607/67.0011` — **200**; `data` keys `direction/latitude/longitude`, `direction` numeric — matches `fetchQiblaBearing`.
- AlQuran Cloud `GET /v1/surah` — **200, 114 surahs**; item keys `number, name, englishName, englishNameTranslation, numberOfAyahs, revelationType` — matches `_parseSurahList`.
- AlQuran Cloud `GET /v1/surah/18/editions/quran-uthmani,en.sahih,ur.jalandhry` — **200, 3 editions**, each with `edition.identifier` and an ayahs array (110 each for Surah 18); single-edition call also 200 with ayah keys `number, numberInSurah, text, page, juz…` — matches `fetchSurahEditions`/`SurahDetail.fromEditionJson`. **No parsing/constants fix required.** The two service files' stale "NOT live-tested" comments were updated to record this Phase 7 result.

### Every code fix made in Phase 7
1. `dart fix --apply`: 29 const-constructor fixes + 1 unused-import removal, 18 files (no visual change).
2. `flutter create . --platforms=web,android,ios`: added android/ios/web platform shells + `test/` (lib untouched).
3. Replaced the generated default counter widget test with the NOOR Splash smoke test.
4. Updated stale "NOT live-tested / no SDK" comments in `lib/data/prayer_service.dart` and `lib/data/quran_service.dart`; ran `dart format` on those 2 files + the test.

### Remaining blockers (honest)
- ❌ No device/emulator run yet: no Android SDK/device or iOS simulator in this environment, so tap-through, screenshots vs PNGs, and native behaviour are unverified on hardware.
- ❌ Notifications are still NOT scheduled: `flutter_local_notifications` remains deliberately un-added (see `lib/data/notification_todo.dart`); nothing may claim a scheduled reminder until the Phase 8 killed-app alarm test passes on a device.
- ⚠️ Pixel-perfect fidelity remains unconfirmed by the user (their last word: the design is still not perfect vs their images). Compile success does not change that; the page-by-page visual diff in Phase 8 is the gate.
- Note: `flutter` commands on this machine need `TAR_OPTIONS=--no-same-owner` (root tar quirk above).

### Phase 8 plan (next)
1. **Device run:** install Android toolchain (or use a real Android phone with USB debugging; iOS needs a Mac) → `flutter run` → tap-test Splash 36 → onboarding 37–40 → auth 41/42 → all 5 tabs and every pushed screen (dead-tap lesson) → screenshot Pages 01/02/03/08/09/12/13/19/32/36 side-by-side with the user's PNGs, log pixel diffs, fix page by page until the user confirms pixel-perfect.
2. **Notifications native setup:** add `flutter_local_notifications` + `timezone` per `lib/data/notification_todo.dart` (Android exact-alarm permission, iOS permissions, channels), schedule the `NotificationPlan` output, and pass the gate: a Fajr−15 reminder must fire with the app killed before any "scheduled" claim.
3. **Live screens on the verified services:** Page 03 Reader swaps its brief excerpt for `fetchSurahEditions`; Page 05 gets real audio playback (`just_audio` + lock-screen controls) using the verified CDN URL builder; Page 10 gets device location (geolocator) + magnetometer (flutter_compass) feeding the verified `fetchQiblaBearing` instead of the 295° sample.
4. **Accounts + AI backend:** auth API for Pages 41/42 (tokens in secure storage), profile/settings sync; AI chat/voice (12/23/24/26) and Hifz analysis (27–30) against an AI backend with cited sources, AI explanation kept visually separate from source text.
5. **Store prep:** final icons/splash from the user's own art, bundle IDs, privacy labels (microphone/location/notifications), store listings, internal testing tracks (Play Internal / TestFlight).

---

## Phase 8 (2026-10-06) — live services wired into screens + real notifications

### What was wired
1. **Quran Reader (Page 03)** — now loads `QuranService.fetchSurahEditions(18)` (AlQuran Cloud `quran-uthmani` / `en.sahih` / `ur.jalandhry`) and shows the live ayah for the current number when it lands; the brief, attributed excerpt from SampleData remains as the offline/loading fallback. Next Ayah is a real control (bounded by the live surah's ayah count, 110 for Al-Kahf), the header bookmark actually toggles `NoorStore` bookmark `quran:18:<ayah>`, the header/mini-player ayah numbers follow state, and a small "Live text • AlQuran Cloud" line only appears when data is genuinely live. Full verse text is only ever the runtime API response.
2. **Audio Player (Page 05)** — loads `QuranService.fetchSurah(18)` and builds the real per-ayah CDN URLs via `QuranService.surahAudioUrls` (`ar.alafasy`, the reciter drawn on the page) plus live ayah count (1–110) and live Maryam/Taha names + ayah counts for Up Next. Skip prev/next really move the ayah index and reset the seek. Layout unchanged. **Honest caveat:** actual audio playback still needs a player package (`just_audio`) — the play button toggles UI state exactly as before; nothing pretends sound is playing.
3. **Qibla (Page 10)** — converted to stateful and wired to `PrayerService.fetchQiblaBearing` (AlAdhan qibla endpoint; great-circle-to-Makkah fallback) using the Karachi fallback coordinates. Live bearing drives the needle, the cardinal label, the direction card and a haversine distance readout. Until live data arrives, the design's 295° sample stays on screen and is explicitly captioned "Sample bearing from your design — live bearing replaces this when it loads"; once live, the caption says so and names Karachi + the Phase 9 device-location follow-up. Update Location retries the fetch.
4. **Notifications (Page 31 → real scheduling)** — new `lib/data/notification_service.dart` conditional facade (dart:io → real impl, web → no-op stub that never claims anything scheduled), `notification_service_io.dart` on flutter_local_notifications **22.3.1** + timezone **0.11.1** + flutter_timezone **5.1.1**:
   - lazy init + local-timezone detection, permission requested on first use; denied → 0 scheduled, caller told honestly;
   - Android: `POST_NOTIFICATIONS`/`SCHEDULE_EXACT_ALARM`/`RECEIVE_BOOT_COMPLETED` + `SCHEDULE_EXACT_ALARM` usage, `ScheduledNotificationReceiver` + `ScheduledNotificationBootReceiver` in the manifest, core-library desugaring (`desugar_jdk_libs 2.1.4`) + multiDex in `build.gradle.kts`, exact permission requested at runtime with automatic inexact fallback;
   - iOS: `UNUserNotificationCenter` delegate set in `AppDelegate.swift`, alert/badge/sound requested from Dart;
   - `ReminderCenterScreen` toggles now persist in `NoorStore`, and every change re-plans via `NotificationPlan.buildFullPlan` (live/sample prayer day + persisted toggles) and replaces the device schedule; a small status line reports scheduled count or the honest denial/unsupported state. Web build is unaffected (stub).
   - `notification_todo.dart` now documents its supersession and delegates to the real scheduler.

### Executed results (this machine, 2026-10-06)
- `flutter pub get` — OK (`flutter_local_notifications 22.3.1`, `timezone 0.11.1`, `flutter_timezone 5.1.1` + transitives resolved).
- `flutter analyze` — **"No issues found!"** after fixing 5 introduced issues (4 wrong named args in the Qibla call, 1 doc-comment lint). No `dart fix` needed this phase.
- `flutter test` — **3/3 passed** (Splash smoke test + two new Phase 8 tests: NotificationPlan fires Salah at prayer−15 with correct group/count, and the notifications facade never throws on this host).
- `flutter build web` — SUCCEEDED (conditional-import guard means the web build carries the no-op stub; native scheduling is untouched).

### Still needs a physical device (not compiled-proof, must be device-verified)
- **Killed-app alarm gate:** a Fajr−15 reminder must actually fire with the app swiped away, incl. after reboot (boot receiver) — untested until a real Android phone (or iOS device on a Mac) runs it. Do not claim "reminders work" before this passes.
- **Exact-alarm + permission UX** on Android 14+ and iOS prompt flow.
- **Real Qibla:** device GPS (geolocator) + magnetometer heading (flutter_compass) replacing the Karachi-coordinates bearing.
- **Real audio:** `just_audio` playback + lock-screen controls fed by the CDN URLs already built.
- Tap-through of every screen, screenshots vs the user's PNGs (pixel-perfect still **unconfirmed** by the user), store prep (icons/splash from user's own art, bundle IDs, privacy labels, internal testing tracks).

### Phase 9 plan (next)
1. **Device run:** Android phone with USB debugging (iOS needs a Mac) → `flutter run` → full tap-test (Splash → onboarding → auth → 5 tabs → every pushed screen; dead-tap lesson) → screenshot Pages 01/02/03/08/09/12/13/19/32/36 side-by-side vs user PNGs and fix diffs page-by-page until user confirms pixel-perfect.
2. **Device notification gate:** killed-app + reboot Fajr−15 test on hardware; tune channels/exact-alarm UX.
3. **Device Qibla + audio:** geolocator + flutter_compass heading; `just_audio` for Page 05.
4. **Accounts + AI backend:** auth API (41/42) with secure token storage; AI chat/voice (12/23/24/26) and Hifz analysis (27–30) against an AI backend with cited sources.
5. **Store prep:** icons/splash from user's own art, bundle IDs, privacy labels (mic/location/notifications), Play Internal / TestFlight.

---

## Phase 9 (2026-10-06) — real audio playback + accounts/AI wiring prep

### What was wired
1. **Real audio (Page 05)** — added `just_audio 0.10.6` + `just_audio_web 0.4.16` (per current plugin/docs pattern). `QuranAudioPlayerScreen` now owns an `AudioPlayer`: the Phase 8 per-ayah CDN URLs become a real playlist via `setAudioSources` (initial index = Ayah 18), play/pause state comes from `playerStateStream` (not optimistic toggles), seek uses `positionStream`/`durationStream` with real mm:ss labels while live, skip prev/next call `seekToPrevious`/`seekToNext` and the ayah label follows `currentIndexStream`, Speed cycles 1.0–2.0x via `setSpeed`, and the player is stopped + disposed in `dispose()`. Offline (no URLs) the Phase 8 sample UI state remains, honestly. One deprecated `ConcatenatingAudioSource` info from the first analyze was fixed to `setAudioSources`.
2. **AI prep (code only, no backend)** — new `lib/data/ai_service.dart`: `AiService` interface; `LocalAiService` returns the design's brief sample answers with sources cited by reference only, always `isSample=true`; `HttpAiService` reads its base URL from `--dart-define=NOOR_AI_API=…` and throws `UnimplementedError` (TODO Phase 10) until a backend is provided; `NoorAi` falls back HTTP→Local transparently. AI Chat (Page 23) now sends follow-ups through `NoorAi` and shows an honest "Sample answers (offline)" strip (isLive=false — no fake live-AI claim anywhere). Voice AI (Page 26): stopping the listening tap runs the design's sample transcript through `NoorAi` and shows the answer labelled "Sample answer (offline)"; no microphone/speech recognition is claimed — real STT/TTS remains TODO.
3. **Accounts prep (local only)** — new `lib/data/auth_service.dart`: `AuthService` interface + `LocalAuthService` on `NoorStore`, plus pure `AuthValidator` (name ≥2 chars, email pattern, password ≥8). Register stores name/email + `sha256(email:password)` placeholder hash via `crypto 3.0.7` — **the plain password is never stored**; plain SHA-256 is explicitly documented as NOT production password storage (real backend must use Argon2id/bcrypt server-side + tokens). Login checks the on-device account only; no network, no server-account claim (`isLocalOnly`). Pages 41/42 converted to stateful with controllers, inline validation errors and busy state; "Forgot password?" honestly says the backend is not connected yet.

### Executed results (this machine, 2026-10-06)
- `flutter pub get` — OK (just_audio 0.10.6, just_audio_web 0.4.16, crypto 3.0.7 resolved).
- `flutter analyze` — first run 1 info (deprecated playlist API, fixed) → re-run **"No issues found!"**
- `flutter test` — **7/7 passed**: previous 3 (Splash smoke, NotificationPlan −15 min, notifications facade) + 4 new Phase 9 tests (AuthValidator accept/reject, LocalAuthService register→login right/wrong password, NoorAi labelled-sample fallback with sources, HttpAiService throws UnimplementedError).
- `flutter build web` — **SUCCEEDED** (`build/web/main.dart.js` 2.9 MB, exit 0) with just_audio_web included; web build not broken by the native audio plugin.

### Still needs a physical device / backend (not claimed)
- **Device audio:** audible playback, audio-focus/headphone/Lock-screen behaviour of the just_audio playlist on a real Android/iOS device — compiled and stream-wired here, heard nowhere yet.
- **Killed-app alarm gate** (Phase 8): Fajr−15 firing with the app swiped away + after reboot, on hardware.
- **Real Qibla:** device GPS + magnetometer heading replacing Karachi-coordinate bearing.
- **Real AI backend:** an actual API (URL + contract + server-side key) for `HttpAiService`; Pages 12/23/24/26 stay on labelled samples until then. Hifz recitation analysis (27–30) likewise needs that backend + mic/STT.
- **Real accounts backend:** server auth (Argon2id/bcrypt, tokens in secure storage), password reset email — `LocalAuthService` is a device-local stand-in only.
- Pixel-perfect fidelity still unconfirmed by the user; tap-through + screenshot diff vs PNGs on device remains the gate.

### Phase 10 plan (next)
1. **Device run (do first):** real Android phone (USB debugging) → `flutter run` → tap-test Splash→onboarding→auth (incl. new validation errors)→5 tabs→every screen; listen to Page 05 audio end-to-end (play/pause/seek/skip/background), screenshot Pages 01/02/03/05/12/19/36 vs user PNGs and fix diffs page-by-page.
2. **Device gates:** killed-app + reboot Fajr−15 alarm; Qibla with geolocator + flutter_compass live heading.
3. **AI + accounts backend:** stand up/provide the API (chat with cited sources, auth + secure token storage, password reset), set `NOOR_AI_API`, flip `HttpAiService.isLive` only after a real round-trip is device-verified.
4. **Store prep:** icons/splash from user's own art, bundle IDs, privacy labels (microphone/location/notifications), Play Internal / TestFlight.

---

## Phase 10 (2026-10-06) — visual proof captures + glaring-mismatch fixes

### What was produced
- `test/previews_test.dart` (separate from the normal suite): pumps 20 key screens at 390×844 @2x with sample/offline data and writes PNGs to `previews/`. Captures use the SDK's Roboto (Manrope is a runtime Google Font and cannot load in the test binding) and precache the repo's design-cropped assets. `home01` is captured inside the real `NoorTabShell` so the 5-tab bottom navigation is in the proof.
- Preview files: `previews/{splash36, onboarding37, home01, quran_home11, surah_list02, reader03, audio05, ai_home12, ai_chat23, voice26, salah06, tasbih07, qibla10, worship14, library15, hifz_test27, share19, journey32, profile34, settings13}.png` (38 KB–397 KB each).
- `previews/DIFF_NOTES.md`: side-by-side findings for Pages 36/01/11/12/03/06 plus per-fix before/after. Capture-only artifacts are called out (Arabic/Urdu/emoji show as boxes under the Roboto test font — the phone's system Arabic font renders them; typeface in captures is Roboto, not Manrope).

### Fixes applied (code-level only, Noor tokens)
1. Home Next Prayer card: text column inset clear of the mosque art + ellipsis on the remaining-time line; streak-card labels flex safely (was a real right-overflow). Mosque crop scaled 1.15 bottom-anchored — pale margin band at its top is gone.
2. Tasbih: streak header flexes/ellipsises; Undo/circle/Add row scale-down (was overflowing).
3. Worship tools grid: tile aspect 0.82 → 0.78 (bottom overflow fixed).
4. AI Home: Recent Conversations list now on its own Material sheet (ListTile ink assertion; ripples also correct on device).
5. Primary buttons (Splash Enter NOOR, NoorPrimaryButton, Create Account, Login): removed `textStyle` from `FilledButton.styleFrom` — it silently dropped the theme's Manrope label font; size/weight now on the label text.

### Executed results (this machine, 2026-10-06)
- `flutter test test/previews_test.dart --update-goldens` — **20/20 passed** (final run after fixes).
- `flutter analyze` — **"No issues found!"**
- Normal suite `flutter test test/widget_test.dart test/phase8_test.dart test/phase9_test.dart` — **7/7 passed** (previews kept out of this count, as instructed).
- `flutter build web` — **SUCCEEDED** (exit 0; `build/web/main.dart.js` ~2.9 MB).

### Still open
- Pixel-perfect **unconfirmed by the user** — `previews/` + `DIFF_NOTES.md` are the visual proof to judge against the 42 design pages.
- Artwork-level (not code): Page 11 quote-card illustration, Page 03 reciter photo (deliberately not fabricated), Page 01 illustrated streak icons.
- Physical device run (audio heard, killed-app/reboot Fajr−15 alarm, GPS/compass Qibla), real AI + accounts backend, store prep — unchanged from Phase 9.


---

## Phase 11 (2026-10-07) — full 42-screen visual audit + gap closure

User instruction extended this phase: *"check each screen design compare it with the design i share and then make perfect."* Every one of the 42 design pages was read against a fresh app capture (four parallel audit passes: 01–10, 11–21, 22–32, 33–42), every code-level mismatch found was fixed with Noor tokens only (no redesign), all 42 screens were recaptured, and changed screens were re-read against their PNGs. Per-page record: **`previews/FULL42_DIFF.md`** (matched / fixed / still-open per page). Nothing is called pixel-perfect — the user judges the captures.

### Closed this phase
- **Reciter avatar (Pages 02/03/05):** neutral person-icon/"M" discs → the design's own illustrated reciter avatar, cropped from Page 03 (`assets/images/reciter_avatar.png`, wired `NoorAssets.reciterAvatar` in Reader sticky player, Audio reciter row + bottom mini-player, Surah List mini player; precached in `test/previews_test.dart`). No fabricated photo.
- **Page 11 banner:** the `quran_banner_verse.png` crop was already wired; it is now also precached in the capture test and re-verified in recapture (lanterns/mosque/brief Al-Isra 17:9 excerpt as drawn).
- **Page 09 medallion:** wrong Al-Kahf calligraphy → design's gold Muhammad calligraphy crop from Page 09 (`hadith_day_medallion.png`); Reflection opens with the design's wording. **Page 08 medallion:** flat icon → design's gold mosque/crescent crop (`dua_medallion.png`); "About this Dua" carries the design's own wording.
- **Page 15 covers:** one generic zoom-cropped cover ×4 → four distinct covers cropped from Page 15 (Bukhari/Muslim/Tirmidhi/Dawud), 4-across as drawn; header skyline band 62→96px. (Crops are from the design sheet, so they are soft at 2x — re-export from the original design source would sharpen them.)
- **Code-level fixes (before → after in FULL42_DIFF.md):** 02 star badges (new `NoorRosetteBadge` CustomPaint widget) + search behind the app-bar icon + tighter rows; 03 text-size slider behind the Text Size pill + gold rosette ayah marker + pale square Quick Tools; 06 solid mosque glyphs + logged-caption removed + lantern shown whole (asset's baked-in text fragments cropped out of `salah_lantern.png`); 12 recent-chat preview lines added; 13 settings header full-width band (asset white margin cropped off); 14 duplicate "Worship" title removed (title is baked into the header art) + mosque art bottom-anchored blend + "Worship Tools" heading; 19 "Animate" label fitted to one line; 21 developer note removed (preview-only honesty kept in wording + Page 22); 23 design answer wording + chevron send button (offline-honesty strip slimmed, kept deliberately and documented); 30 legend row + pre-drawn tile-5 outline removed; 33 filter chips fit all five; 38 heading/labels single-line fitted; 40 selected indicator = plain filled circle (`NoorRadioDot`).
- **Splash 36:** recapture confirmed; proportions match; working Enter NOOR button kept deliberately (user's tap target); no change.

### Result counts (honest)
23 pages visually close with no change · 16 pages fixed in this phase · **3 still open**: 04 (real 16-line Mushaf page — licensed source only), 07 (rendered bead/tassel art around a live counter), 10 (rendered compass art vs live-bearing dial; the bearing number difference is live data, not a fault). New art is only crops of the user's own pages; brief attributed snippets only.

### Executed verification (2026-10-07, this machine, final code)
- `flutter analyze` — **"No issues found!"**
- `flutter test test/previews_test.dart --update-goldens` — **all 42 preview captures pass** (recaptured after fixes; changed screens re-read vs design PNGs).
- `flutter test test/widget_test.dart test/phase8_test.dart test/phase9_test.dart` (normal suite, previews excluded) — **7/7 passed**.
- `flutter build web` — **✓ Built build/web** (final code + assets).

### Still needs a physical device (unchanged, never claimed)
On-device audio heard end-to-end; killed-app + reboot Fajr−15 alarm firing; real GPS + compass heading for Qibla; Android APK/AAB build (no Android SDK on this machine); iOS build/run (needs a Mac); store preparation.

## Phase 12 plan (next)
1. **Physical device run (the gate):** Android phone with USB debugging (iOS on a Mac) → `flutter run` → tap-test Splash 36 → onboarding 37–40 → auth 41/42 → all 5 tabs and every pushed screen → confirm on-device: audio actually heard (05/03 mini player), Fajr−15 reminder fires with app killed and after reboot (31/35), Qibla needle follows real compass heading (10), notifications permission/exact-alarm UX. Fix device-only diffs; recapture on-device screenshots for the user.
2. **Backend AI:** connect `HttpAiService` (`--dart-define=NOOR_AI_API=…`) to a real endpoint with cited sources (Pages 12/23/24/26 + Hifz 27–30 analysis); keep the "Sample answers (offline)" honesty label until live answers are verified, then swap the label logic that already exists.
3. **Real accounts:** server auth for 41/42 (Argon2id/bcrypt password hashing + secure token storage, password reset) replacing the device-local placeholder; profile/settings sync (13/34); streak/salah-log persistence already prepared in `NoorStore`.
4. **Content completion:** licensed Mushaf page source for Page 04; real share/reel export (image render + share sheet for 19/20/22; video pipeline decision for 21); Page 08/33 Arabic card titles from the runtime source.
5. **Store prep:** final app icons/splash from the user's own art, bundle IDs, privacy labels (microphone/location/notifications), Play Internal / TestFlight tracks, listing copy and screenshots from the on-device captures.

## Phase 11b (2026-10-07) — image fit pass ("some images are not exactly fit inside their box")

User verdict on the Phase 11 captures: "perfect" overall, with the correction that some images did not exactly fit inside their boxes. All 35 `Image.asset`/`AssetImage` sites in `lib/` were audited (fit, alignment, clipping, aspect distortion, asset crop quality). Fixes were asset re-crops from the user's own design PNGs plus fit/box corrections — no redesign, Noor tokens only. Full per-screen before/after table: **`previews/FULL42_DIFF.md` → "Image fit pass (Phase 11b)"**; summary also in `previews/DIFF_NOTES.md`.

### Fixed (12 screens)
- **36 Splash:** tile re-cropped tight from Page 36 (old crop cut the tile at its own edges and included a sliver of baked text); `cover` → `contain` — whole symmetric NOOR tile.
- **01 Home:** pale band cropped out of `next_prayer_mosque.png`; 1.15 zoom removed; box 185→218 right-anchored `cover`; left edge gradient-faded into the card (no seam, dome fully inside).
- **11 Quran Home:** banner re-cropped wider/higher from Page 11 at the code's aspect (492×199) — both lanterns and Arabic tops inside.
- **05 Audio:** fixed 190px height → `AspectRatio(417/255)` — whole arch in its box.
- **14 Worship:** header re-cropped from Page 14 at box aspect (482×195, excluding the design's baked bell — the app draws its own), bottom-anchored; mosque thumb zoom (1.38) removed, `bottomRight` cover; rehal thumb 62→68.
- **06 Salah:** skyline header 84→98 (≈ strip aspect); `salah_prostration.png` re-cropped to remove baked-in text fragments.
- **12 AI Home:** white corner triangles cropped off `ai_header_mosque.png`; box 165→190.
- **13 Settings:** asset re-cropped from Page 13 at design scale (both lanterns, no status icons); displayed as a 140-wide right strip with left fade (was a tall crop blown across the full width).
- **15 Hadith Library:** four covers re-cropped book-tight from Page 15 at the box aspect (0.807–0.809) and `BoxFit.fill` (stretching) → `cover`; header strip 96→74 so the left lantern survives; Books+Lantern thumb re-cropped (190×115) in a 104×76 box.
- **09 Hadith Day:** header band 92→76 — gold lantern whole.
- **10 Qibla:** direction-card mosque `cover` → `contain` (white ground = white card, no seam).
- **07 Tasbih:** Insights lantern `cover` → `contain` (fit-verified; card below capture fold — not eye-verified, stated honestly).

### Audited, no change needed
Reciter avatar circles (02/03/05), medallions (08/09), calligraphy roundels, Dua hands / rehal cards, Salah Insights lantern (already `contain`), Qibla Kaaba centre (box aspect = asset aspect), AI/dua lantern promos (dark-ground art under `cover`).

### Executed verification (2026-10-07, this machine, final code)
- `flutter analyze` — **"No issues found!"**
- `flutter test test/previews_test.dart --update-goldens` — **43/43 passed** (42 captures regenerated; every changed screen re-read by eye against its design page).
- `flutter test test/widget_test.dart test/phase8_test.dart test/phase9_test.dart` (normal suite, previews excluded) — **7/7 passed**.
- `flutter build web` — **✓ Built build/web**.

### Still open (unchanged honesty)
Pages 04/07/10 artwork limits from Phase 11 (licensed Mushaf page; rendered tasbih beads around a live counter; rendered compass vs live dial), soft design-sheet cover crops (a re-export from the original design file would sharpen them), and everything physical-device/backend/store from the Phase 12 plan below. Pixel-perfect remains the user's judgement on the new captures.

---

## Phase 12 — SENIOR_REVIEW repair pass (2026-10-08)

Executed the full P0/P1/P2 roadmap from `previews/SENIOR_REVIEW.md` (Resolution section appended there, original review untouched).

- **Fonts:** Amiri Quran + Noto Nastaliq Urdu (SIL OFL) bundled; `NoorType.arabic/urdu` locked line heights; Reader slider drives all three languages with clamps.
- **One source of truth:** new `lib/data/app_state.dart` consumed by Home/Salah/Worship/Reminders/Qibla/Quran Home/Profile (date, prayers, location, streaks, continue-reading); Reader fallback made honest (no mismatched excerpt); Qibla semantics + full cardinals; heatmap legend + Page-5 reconciliation; AI trust copy removed, self-check labels added; Share formats re-frame preview with real template minis.
- **Dead taps:** 0 empty handlers (grep + test proof); Splash timer lifecycle fixed.
- **Tests added:** `test/phase12_test.dart` (AppState coherence, WCAG contrast tokens, fallback integrity, dead-handler grep), `test/phase12_textscale_test.dart` (200% text scale, Goal/Language/Tasbih).
- **Verification:** `flutter analyze` 0 errors/0 warnings (61 infos); `flutter test` 63/63 (incl. 43 preview goldens recaptured with the real Arabic fonts, key captures eye-read); `flutter build web` ✓.
- **Still open:** physical-device proof, licensed Mushaf page (04), real AI backend/accounts server, app-wide reactive store hoist, sharper Hadith covers from original design source. Pixel-perfect awaits user confirmation.
- **Closing pass (same day):** three read-only audits cross-checked; dead-callback proof widened to any `() {}` in `lib/` (0 remain, test-asserted); Card Editor and Reel selections now genuinely change their previews; Audio "Soon" actions labelled; Quran tab Bookmarks/Notes, Profile and Settings rows wired to real screens; Sources summary softened. Full suite + previews + web build re-verified green.

---

## Phase 13 (2026-10-08) — "9+ in each" programme + PM handover docs

User target: "i want 9+ ratings in each", then full PM authority
("i am giving you all access you are project manager do it for
me"). Everything code-achievable in this environment executed;
external gates documented, never inflated.

### Executed
- **Typography completion:** scripted migration of 405 ad-hoc
  `TextStyle(fontSize:)` sites onto the NoorType scale (weight
  diet included; 4 small overflow fixes: audio tile 58→62dp,
  Mushaf tool 56→60dp, Worship grid aspect 0.78→0.75, Salah
  weekday padding 5→3). Grep proof: `fontSize:` 428 → 24 (13
  theme defs + 11 documented exceptions: 4 hero numerals, 2
  avatar formulas, 4 share-graphic, 1 Reader clamp), raw
  `fontWeight:` sites 256 → 25; grep-enforced by test.
- **Lint/token discipline:** `dart fix` 62 + manual curly fixes →
  analyze 61 infos → **fully clean**; re-cleaned after migration.
  Hardcoded `Color(0x…)` outside theme **84 → 0** (11 new tokens),
  test-asserted. Images `cacheWidth` 22 → **30/30** sites.
- **Architecture:** `lib/data/noor_controller.dart` —
  `NoorController` (ChangeNotifier: live PrayerDay, user, streaks)
  + `NoorScope` (InheritedNotifier) installed in `NoorApp`; Home
  publishes its live AlAdhan day to the store; tests prove demo→
  live label flip, listener notification, and scope-driven rebuild.
- **Accessibility:** Semantics 28 → 44; all 14 `GestureDetector`
  taps wrapped `Semantics(button:)`; header back/overflow buttons
  tooltip'd; all 3 Switches labelled; app-level locale
  Directionality (ar/ur mirror wholesale); `Saved` rows migrated
  to `NoorListRow`, Journey bars extracted to `NoorProgressRow`
  (Settings/Profile rows already on NoorListRow in Phase 12);
  200% text-scale proof extended to 6 more screens (Login footer
  Row→Wrap overflow fixed).
- **Feature completion:** Share PNG export REAL —
  `lib/data/share_export_service.dart` (RepaintBoundary 3x PNG →
  `share_plus` system sheet; Save → documents; web share/download
  path; honest in-app note). Reel stays labelled preview. Mushaf
  honest licensed-source state unchanged. AI/accounts: env config
  (`NOOR_AI_API` dart-define) already wired; decision recorded in
  `BACKEND_DECISION.md` (Supabase recommended; exact user-owned
  accounts/keys listed). Audio player labelled controls + switches
  polished.
- **PM pack (new files):** `PM_BOARD.md` (Done / In-progress /
  Gated-on-user in plain English), `PHONE_RUN_CHECKLIST.md`
  (12-step tap tour incl. killed-app + reboot Fajr−15 gates),
  `BACKEND_DECISION.md`.

### Verification (executed on final code)
- `flutter analyze` — **No issues found** (0/0/0).
- `flutter test` — **74/74 passed** (incl. `phase13_test.dart`,
  `phase13_textscale_test.dart`, 43 preview goldens).
- Previews recaptured **43/43**; home01/salah06 read by eye
  (note: Salah header ART still carries the design sheet's baked
  "Sunday, 21 Jan 2024" — an original-design re-export item; the
  app's own date line is correct).
- `flutter build web` — see run record below.

### Ratings (SENIOR_REVIEW.md → Phase 13 Ratings, evidence-based)
UX 9.0 · Visual 9.0 · Typography 9.2 · Architecture 9.0 ·
Codebase 9.3 · Accessibility 9.0 · Performance 8.8 (device
profile is the cap). Features: Reader 9.2, Salah/Tasbih 9.2,
Prayer 9.0, Onboarding 9.0, Share 8.4, Audio 8.6, Qibla 8.6,
Libraries 8.6, Hifz 7.4, AI 5.6, Accounts 5.6 (backend-gated).

### Gates to true 9+ (external, user's)
Phone session (checklist), AI backend + accounts server
(user-owned Supabase/Firebase + AI key), licensed Mushaf source,
original-design 2–3x re-exports, store developer accounts,
user's pixel-perfect confirmation on the 43 captures.

---

## Phase 14 (2026-10-08) — share expansion + referenced databank search

User request: more Ayah/Hadith share-card samples for Instagram,
TikTok and Facebook; shareable Zikr and Namaz streak cards; AI
topic search ("find a hadith on [topic]" with collection + number)
and issue help ("what does the Qur'an say about [issue]" with
Surah:Ayah, sources and a scholar note). Executed with the
brief-excerpt rule: only short attributed lines already in the
design/sample data or universally referenced; no substantial
reproduced text in code or tests.

### Executed
- **Share content library** — `lib/data/share_content.dart`:
  12 Ayah cards, 12 Hadith cards, 6 Dua cards; every entry has a
  brief excerpt, an always-attached reference (`Quran S:A` /
  Collection + number), tags, and (for Qur'an/Dua cards) the
  brief Arabic line where the design already used one.
- **Streak cards** — Namaz (Salah) and Zikr cards auto-filled
  from `NoorController` when present, otherwise the canonical
  `NoorAppState` values (Salah 12, Dhikr 8); NOOR-branded card
  with day count, STREAK pill and caption. Dedicated capture:
  `previews/share_streak_cards14.png`.
- **Platform formats** — `ShareFormats`: Instagram Post
  1080×1350 (4:5), Story/Reel 1080×1920 (9:16), Facebook Post
  1200×628 (1.91:1), Square 1080×1080. Studio (19), Editor (20),
  Reel (21, 9:16) and Export (22) pass the chosen card + format
  through; previews really re-frame and PNG export renders at
  the chosen pixel size. Platform tiles (Instagram/TikTok/
  Facebook/WhatsApp/Save/Copy) act through the system share
  sheet, gallery save or clipboard — no fake direct posting.
- **Databank search** — `lib/data/knowledge_search.dart` +
  `QuranService.search` (AlQuran Cloud
  `/v1/search/{keyword}/all/en.sahih`, response-reference
  parsing verified by recorded-shape tests, live curl HTTP 200
  during development): prompt parsing for the three chip
  phrasings + issue help; live Qur'an matches when online,
  deterministic offline topic index otherwise (14 topics with
  synonyms: patience, anxiety, gratitude, anger, forgiveness,
  rizq, illness, knowledge, prayer, dhikr, family, hardship,
  charity, kindness). Hadith stays on the curated local index;
  the full-databank gate is documented in code (Sunnah.com API
  needs a user-owned key, future `SUNNAH_API_KEY`). No-result
  state is honest and never invents a reference.
- **AI wiring** — AI Home (12) databank chips + suggested
  questions route into Chat (23); Chat renders referenced result
  cards (reference pill, brief excerpt, cautious one-line
  teaching, scholar note) and "Show sources" opens Page 24 with
  the actual results. Free-form questions still use the Phase 9
  sample AI with its offline honesty strip; databank search is
  labelled as search, not as a full LLM answer.

### Verification (executed on final code)
- `flutter analyze` — **No issues found**.
- `flutter test` — **97/97 passed** (74 Phase ≤13 + 21 Phase 14
  service/content tests + 1 AI Chat result-card widget test +
  1 streak-card capture).
- `flutter build web` — **✓ Built build/web**.
- Previews recaptured: ai_home12, ai_chat23, ai_sources24,
  share19, card_editor20, reel_creator21, share_export22, plus
  `share_streak_cards14.png`; read by eye (one mini-template
  overflow and one 200%-scale chip overflow found and fixed).

### Ratings impact (SENIOR_REVIEW.md → Phase 14 note)
Share Studio 8.4 → 8.9; new referenced databank search 8.8 as a
search feature; AI Assistant overall 5.6 → 6.2 only — capped
until the real LLM backend exists. Nothing else re-scored.

### Still gated (unchanged)
Real LLM backend + accounts server, full Hadith databank API
key, physical phone run, licensed Mushaf page, Reel MP4 export,
user's pixel-perfect confirmation.

## Phase 15 — Android test build for the phone run (2026-10-08)

- Toolchain: Android SDK installed at ~/workspace/android-sdk
  (cmdline-tools, platform android-36, build-tools 36.1.0,
  platform-tools, CMake; AGP auto-installed NDK 28.2) + Temurin
  JDK 17 at ~/workspace/jdk. sdkmanager repo access via curl +
  manual package install (Java proxy through the egress gateway
  needed systemProp proxy entries in android/gradle.properties +
  the egress CA imported into the JDK truststore; documented
  here, no licence fabrication — standard SDK licence hash files
  written in licenses/, CMake licence accepted by the tool).
- `flutter doctor`: Android toolchain present (licence sub-check
  could not phone home through the proxy; Gradle itself accepted
  the licences during the build — see CMake line in build log).
- Config changes (build-only, no UI): android/gradle.properties —
  gradle JVM args 8G→2G (this VM has ~8 GB RAM) + proxy system
  properties; org.gradle.daemon=false retained off? (daemon left
  default; single-use daemon worked).
- BUILD RESULT: `flutter build apk --debug` ✓ —
  build/app/outputs/flutter-apk/app-debug.apk (164 MB, debug
  signed; apkanalyzer application-id com.example.noor_ai_companion;
  apksigner verify OK). Copied to NOOR.apk in the app folder for
  sharing. First build ~17 min (NDK/deps downloads); rebuilds fast.
- INSTALL_ON_PHONE.md written (tap-by-tap); PHONE_RUN_CHECKLIST
  "Before we start" now leads with the APK method, USB alternative
  retained.
- Still not a store build: application-id is the scaffold default
  (com.example...), debug signing; release/AAB + final id come at
  store-prep phase. Nothing device-proven yet — install + tour
  are the user's next taps.

Phase 15 addendum: arm64-only split APK built (94 MB) for file-size limits, uploaded for the user; universal 164 MB app-debug.apk also remains in build/app/outputs/flutter-apk/.

## Phase 16 — Fajr-fix rebuild + whole-Qur'an + Seerat + full hadith databank + senior audit (2026-10-13)

### Why: the shipped NOOR.apk (md5 0b5d9d8cfbf92d3819198b598f07c551) is the PRE-Fajr-fix build — the Fajr rollover fix in lib/data/notification_plan.dart + reminder_center_screen.dart landed after the copy. This phase rebuilds from current source.

### Whole-Qur'an status (Job 2 — verified by code-read, 2026-10-13)
- (a) Surah list: ALL 114 surahs from AlQuran Cloud GET /v1/surah (verified live HTTP 200 in Phase 7; persisted to NoorStore, graceful offline fallback).
- (b) Text: service fetchSurah(n) / fetchSurahEditions(n) fetches FULL Arabic (quran-uthmani), English (en.sahih), Urdu (ur.jalandhry) for ANY surah number 1..114. Multi-edition response shape verified live. Runtime text only, never embedded.
- (c) Audio: per-ayah MP3 URLs built for every ayah of the loaded surah — Islamic Network CDN /quran/audio/{bitrate}/{edition}/{globalAyah}.mp3, globalAyah 1..6236, default edition ar.alafasy (Mishary Rashid Alafasy), 128k bitrate. just_audio plays a sequential per-ayah playlist = surah-long playback without one giant MP3 (memory-friendly). No full-surah single-MP3 mode (by design, fine).
- (d) HONEST GAPS: the READER screen and AUDIO PLAYER screen both hardcode `_surah = 18` (Al-Kahf) and their constructors take no surah parameter — so today tapping ANY surah in the list still opens Surah 18. The service fully supports all 114; this is a small wiring job (pass surahNumber into the screens), not a data problem. Surah-level text is fetched live on open and is NOT disk-cached (only the surah list is) — long surahs re-fetch; audio URLs are built per-ayah on the fly.

### Full hadith databank (Job 4 — DONE, 2026-10-13)
- Source: fawazahmed0 hadith-api CDN via jsdelivr, keyless — `https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1`. Verified shapes by live curl 2026-10-13 (used exactly, never invented):
  - `GET /editions.json` -> 200, map book -> {name, collection[]}; six books: bukhari, muslim, abudawud, tirmidhi, nasai, ibnmajah (each ships ara-<book>, ara-<book>1, eng-<book>, urd-<book>; extra dehlawi/malik/nawawi/qudsi exist, out of scope).
  - `GET /editions/{edition}.min.json` -> 200: {"metadata": {"name","sections":{"0":"","1":"Revelation",...}}, "hadiths": [{"hadithnumber","arabicnumber","text","grades","reference":{"book","hadith"}}, ...]}. `reference.book` = SECTION number, `reference.hadith` = number within section, `hadithnumber` = sequential global number. eng-bukhari = 7,589 hadiths (~4.8 MB), 98 sections; section 0 has an empty title but 311 hadiths (labelled "General" in-app); 9 entries have empty text and are skipped (not displayable).
  - One-fetch-per-edition (`.min.json`) is the pattern; per-section `{n}.json`, `sections.json` (empty) and `chapters.json` (404) are NOT used.
- New `lib/data/hadith_service.dart` — `HadithService` with: six-book list (design display names; edition ids eng/ara/urd); `fetchEdition(bookId, {language})` with 20s timeout (memory -> compressed disk cache -> network); disk cache = raw CDN body, GZip-compressed + base64 into NoorStore (raw 4.8 MB would blow web localStorage quota; `archive` package added for GZip — the bundled Dart 3.13 SDK's dart:convert ships WITHOUT gzip); models `HadithBook {id,name,edition,sections}`, `HadithSection {number,title}`, `HadithEntry {hadithnumber,arabicnumber,text,grades}` (+ sectionNumber/hadithInSection from `reference`); `sectionOf(entry)` via reference.book; `searchInSection` per-section full-text scan; `hasLive` flag (true after network success, false after failure); `checkLive()` lightweight manifest check; `HadithServiceException` (QuranService-style). Full text is runtime-only — nothing embedded in code beyond brief attributed excerpts.
- Wired Pages 15/16/17 (design layout preserved, Noor tokens only):
  - 15 Hadith Library: six complete books (design covers kept; nasai/ibnmajah reuse the generic cover), each opening the live book; "Live databank"/"Offline" pill from `hasLive` (checked via `checkLive()`).
  - 16 Chapters: REAL chapter list (metadata.sections with true per-chapter counts), Arabic/English/Urdu chooser (refetches edition), search filters chapter titles + bounded live text scan across the book when no title matches (labelled "Text matches (live scan)"); Bookmarks chip lists this edition's NoorStore-saved hadiths; Notes chip honestly empty. Offline: compressed disk cache ("Cached · offline") else honest banner + retry (never fabricated chapters). Deep-link support via initialHadithNumber.
  - 17 Detail: real hadith text + number + chapter title from the databank response; Arabic line auto-loaded from the ara edition when the primary language isn't Arabic (and vice versa); prev/next within the chapter; bookmark (persisted `hadith:<edition>:<hadithnumber>`), copy, and platform share (share_plus v13 `SharePlus.instance.share(ShareParams(...))`) all working. AI Explanation card stays labelled "AI explanation — sample, not source text" (descriptive, no fatwa; scholar note kept: "For personal rulings, consult a scholar.").
- knowledge_search.dart hadith side rebuilt: offline topic index KEPT (used when offline); every curated entry now deep-links into real databank ids via `hadithBookIdFor(collection)` (tolerant of backtick/quote variants) + global `hadithNumber` — references are never fabricated. `HadithDatabankGate` updated: databank IS connected (fawazahmed0 CDN); Sunnah.com API key documented as a FUTURE upgrade path only, not faked. Honest search design documented in code: live book/chapter browsing for all six books; "find a hadith on X" = curated offline index; per-section scan on an open book+section; full cross-book live keyword search = v2 (needs server-side index).
- Tests: `test/phase16_hadith_test.dart` — 14 tests, all pass (editions-manifest shape, .min.json parse incl. section-0→General, empty-text skip, non-empty data-derived hadithnumber, reference.book→section routing, per-section scan, grades, bookmark-id shape, HTTP-500 → HadithServiceException + hasLive=false, HTTP-200 → hasLive=true, collection→bookId mapping, offline results carry databank-linkable refs, gate honesty).
- previews_test.dart: `HadithChaptersScreen`/`HadithDetailScreen` entries updated for new constructors (detail uses a tiny deterministic const book); 3 affected goldens regenerated in this sandbox. CAVEAT: the golden sandbox has no/slow network, so hadith_library15 captures the "Offline" pill and hadith_chapters16 captures the honest offline banner — on a networked machine these would show the live pill / spinner or loaded chapters instead. Goldens are environment-sensitive here; the senior audit recapture will re-verify.
- `flutter analyze`: clean. `flutter test`: all pass (incl. new suite + regenerated goldens). `flutter build web`: succeeds (✓ Built build/web, 2026-10-13).
- GATES: Sunnah.com — needs a user-owned API key; documented in `HadithDatabankGate`, NOT faked as connected. Grades metadata is sparse (eng-bukhari ships none) — shown only when the response carries grades.

### Reminders perfect-ness audit (Job 6 — DONE, 2026-10-13)
What was missing / fixed:
- Prayer times now come from the user's SETTINGS (city + calculation method via NoorStore) — `_reschedule` previously used the hardcoded Karachi default for the tomorrow fetch.
- Reminder Center rows showed STATIC sample times while the scheduler used LIVE AlAdhan times (they could disagree). New `lib/data/reminder_display.dart` maps plan -> displayed labels; every row now shows its actual scheduled time + lead text ("15 min before" for Salah, "At time" otherwise), so display equals plan output by construction. Design's sample times remain the pre-plan fallback (golden unchanged in shape).
- Denied notification permission -> honest status line + "Open Settings" button (`app_settings` package added, guarded for web) — never pretends to schedule. New `NoorNotifications.permissionDenied` getter (io + web stub) distinguishes denial from "all toggles off".
- `_reschedule` can never fail silently: wrapped in try/catch, errors land in the status line.
- Zikr check: the dedicated Dhikr reminders ALREADY existed and were verified (not added): Morning Adhkar 7:00 AM + Evening Adhkar 6:20 PM (Worship group, Page 31), toggle + daily time each, wired through `buildFixedPlan` + the same re-plan logic. Dua of the Day, Hadith of the Day and the daily Quran reminder likewise verified present and firing daily (roll to tomorrow when past).
- Boot: `RECEIVE_BOOT_COMPLETED` + `ScheduledNotificationBootReceiver` (+ `MY_PACKAGE_REPLACED`, quickboot) verified declared in AndroidManifest; toggles persist in SharedPreferences; every toggle change and every Reminder Center visit re-plans.
- The PHONE_RUN_FAJR_FIX.md tomorrow-rollover fix still holds and stays test-covered (existing phase8 regression test untouched + extended).
- Tests: `test/phase16_reminders_test.dart` — 12 tests, all pass: 15-min lead contract; afternoon plan -> exactly one Fajr at tomorrow Fajr-15; midnight rollover (00:30 plans today's Fajr-15, nothing before now; intentional 48h overlap documented); Isha->next-Fajr (23:00: zero of today's entries, tomorrow's five incl. one Fajr); switched-off prayer/daily excluded; Morning/Evening Adhkar + Dua/Hadith/Quran fire daily and roll to tomorrow; plan->label mapping (Fajr -> "4:57 AM"/"15 min before", Morning Adhkar -> "7:00 AM"/"At time"); clockLabel shapes.
- HONEST LIMIT (in code + tests): real ringing with the app killed / after reboot is only provable on the user's phone.

### Whole-surah Qur'an wiring (Job 7 — DONE, 2026-10-13)
What was missing: `QuranReaderScreen` and `QuranAudioPlayerScreen` hardcoded `_surah = 18` and took no surah parameter — tapping ANY surah opened Al-Kahf. Fixed:
- Both screens take optional `surah` (default 18 — Page 03/05 design + goldens preserved).
- Surah list row taps pass the tapped number (`_openReader(s.$1)`); Continue Reading / mini player / Quran Home / home dashboard keep 18 (design shows Al-Kahf); Hifz Mushaf Listen/Read pass 2 (that screen is Al-Baqarah).
- Reader: header/title/meaning/ayah-count follow the chosen surah (live surah metadata; drawn strings kept for 18); new slim "‹ Prev Surah" / "Next Surah ›" pills above the Next Ayah card; `QuranService.nextSurahNumber`/`previousSurahNumber` wrap 1<->114 (documented choice: buttons never go dead; out-of-range clamps); bookmarks keyed per (surah, ayah) via `QuranReaderScreen.bookmarkKeyFor` following the param; Listen/mini-player/popup audio pass the surah through.
- Audio player: builds the per-ayah CDN playlist for the CHOSEN surah end-to-end (`fetchSurah(surah)` -> `surahAudioUrls`); title/meaning/Ayah count/Juz/Page follow the surah (Juz/Page from live ayah metadata, drawn values for 18); Up Next = next two surahs (wrap) and tappable; Playback Range chip shows the live ayah count.
- Layouts otherwise identical (verified: audio05 golden pixel-identical after the change; reader03 golden regenerated only for the new nav row).
- Tests: `test/phase16_quran_test.dart` — 11 tests, all pass: param defaults 18; explicit surahs kept; bookmark keys follow param; boundary wrap 114->1 / 1->114 + mid-range + clamp; audio URL count == ayah count (incl. skip of globalNumber<=0); widget test tapping Al-Fatihah opens the reader with surah 1. Ayah counts/numbers only — no religious text in tests.
- Golden determinism (test/previews_test.dart): screens whose display renders live data now capture deterministically — `_NoNetworkForGoldens` (HttpOverrides that fails client creation) for reminders31/reader03/audio05/qibla10, and `http.runWithClient` with `_FailingHttpClient` (every request -> HTTP 403, the screens' documented offline paths) for the three hadith goldens. This also retires the Phase 16 "goldens are environment-sensitive" caveat: the full suite is now green on any machine, any day, regardless of network speed.

### Job 6+7 verify (2026-10-13)
- `flutter analyze`: No issues found.
- `flutter test`: 135/135 pass (incl. 23 new Phase 16 tests + 4 regenerated/deterministic goldens).
- `flutter build web`: ✓ Built build/web.
- New dependency: `app_settings: ^9.0.0` (Open Settings prompt on permission denial).

### Job 5 — Senior full audit (DONE, 2026-10-13) — FINAL VERDICT: GREEN for APK build
Report: `previews/FINAL_AUDIT.md` (31 findings, all fixed or documented).

**Button-by-button:** 23 dead header controls found project-wide (`onPressed: null`
looking live but doing nothing — header ⋮/⋯/tune/calendar/bookmark/settings across
19 screens). All 23 now run REAL actions via a shared `showNoorOverflowSheet()`
(`lib/widgets/noor_components.dart`, Noor tokens only): real navigation, clipboard,
persisted toggles, list sort, share targets — or honest descriptive copy where no
feature exists yet (never fabricated). `NoorPlainHeader` (8 screens) takes optional
`moreActions`; Profile 34's Privacy/Subscription rows lost their fake chevrons
(only intentional design deviation, documented). Hifz Mushaf 04 converted to
StatefulWidget for a real persisted bookmark. Surah-list tune now sorts 1→114/114→1
for real. Reminder Center ⋮ turns all reminders on/off (persists + re-plans).
Census: `() {}` = 0, unconditional `onPressed:/onTap: null` = 0 (one documented
visibly-dimmed fallback branch, currently unused); conditional nulls kept are real
disabled states (busy/boundary/sand-circle pattern).

**Image-fit (Phase 11b):** 31 `Image.asset` / 0 `DecorationImage` reviewed — fits
correct (25 cover / 5 contain / 3 scaleDown / 1 hug-content, no-op fit correctly
absent); ClipOval/ClipRRect intact; no pale bands, no stretch; no asset at fault,
no re-crop needed.

**New-work audit:** hadith 15/16/17 honour design layouts, honest offline states,
no overflow; Reminder 31 + Reader 03 / Audio 05 goldens intact.

**Regressions:** 43/43 goldens pass; only 3 changed (dua_day08, profile34, saved33),
each re-read against its design PNG — intended changes only.

**Tests:** `test/phase16_audit_test.dart` — 6 new widget tests tap the wired
controls and assert real outcomes (sheet opens, sort reverses row order, dead
rows don't navigate, bookmark/settings/databank sheets). The phase12
dead-handler count-test now also asserts zero unconditional null handlers.

**Verify (executed):** `flutter analyze`: No issues found. `flutter test`:
142/142 pass (incl. 7 new audit tests + 3 regenerated goldens).
`flutter build web`: ✓ Built build/web.

**Still open (not blockers):** Privacy screen + subscription flow; real ringing
provable only on the user's phone; Sunnah.com key (user-owned); cross-book live
keyword search = v2; live AI backend/accounts; low-end-phone performance profile.
