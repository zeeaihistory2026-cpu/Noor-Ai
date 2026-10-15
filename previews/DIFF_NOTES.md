# NOOR — Visual Diff Notes (Phase 10)

Captures: `previews/*.png`, 390×844 @2x, rendered by `test/previews_test.dart` (20/20 pass with `flutter test test/previews_test.dart --update-goldens`).
Design source: `~/workspace/noor-design/NOOR_AI_Companion_Complete_UI_Pages_01-42/`.

**Capture limitations (not app behavior):** offline test font is Roboto, not Manrope; Roboto has no Arabic/Urdu/emoji glyphs, so Arabic/Urdu lines and emoji (👋, 💚) show as boxes in captures only — on a phone the system Arabic font renders them. `home01` is captured inside the real 5-tab shell so the bottom nav is genuine; other captures are single screens without the tab bar.

## Per-screen comparison (checked in detail: 36, 01, 11, 12, 03, 06)

- **36 Splash** — Matched: cream page, big emerald NOOR tile (art cropped from Page 36), "AI Companion", "Faith • Guidance • Growth", "Loading...". Difference by design decision: the app adds a working **Enter NOOR** button (your tap target from the prototype); Page 36 shows no button. Proportions of the tile match.
- **01 Home** — Very close: greeting/Hijri date, bell + dome avatar, ASR Next Prayer card with the same mosque art, Salah/Dhikr/Quran streaks 12/8/17 with flame dots, Dua of the Day (Quran 20:114) with hands art, Hadith of the Day, bottom nav (Home/Quran/AI/Worship/Library). Minor: streak icons are line icons (design uses small illustrated icons); fixed this phase — see below.
- **11 Quran Home** — Matched: dark header, Surahs/Juz/Bookmarks/Notes pills, Continue Reading Al-Baqarah + Read Now, surah rows 1–5 with verse counts. Quote card (Al-Isra 17:9) fixed 2026-10-07: now uses the illustrated banner cropped from the user's own Page 11 (`assets/images/quran_banner_verse.png`, lanterns + mosque silhouettes, brief excerpt as drawn; Semantics label carries the translation/source for accessibility) instead of the previous plain-white card. "Listen to Quran", "Daily Verse" and "Quick Actions" sit further down the scroll in the app.
- **12 AI Home** — Very close: dome header art, "Assalamu Alaikum", ask box with mic + send, 4 Suggested Questions, Recent Conversations, lantern promo. Minor: design centres suggested-card text, app left-aligns under the icon; design lists 4 recent chats, app shows 3 above the fold.
- **03 Reader** — Very close: Al-Kahf header, Arabic/English/Urdu tabs, Text Size, ayah card with English (Saheeh International) + Urdu (Jalandhari) sections, Quick Tools (Tafsir/Word by Word/Listen/Share Ayah/Copy), sticky mini player. Minor: app shows a text-size slider row the design tucks behind the Text Size pill; design's mini player uses a reciter photo, app uses a neutral icon disc (no reciter photo asset — not fabricated).
- **06 Salah** — Near-identical above the fold: mosque-skyline header with Hijri date, Today's Prayers with Asr highlighted (3:58 PM, 1h 16m remaining), "2 of 5 prayers logged today", 12-day streak card with weekday checks, Monthly Overview 91%/28/3, Insights with lantern. Quick Actions/Learn Salah continue below.

## Fixes applied this phase (code-level, Noor tokens only)

1. **Home Next Prayer card:** text could overflow and run under the mosque art (test failure: right overflow). Text column inset (right 150), remaining-time line ellipsises, streak-card label rows shrink safely. Mosque crop scaled 1.15 bottom-anchored to remove the pale margin band at its top edge. *Before: overflow error + white band; after: clean card in `home01.png`.*
2. **Tasbih:** streak header text and the Undo/circle/Add row could overflow narrow widths — header now flexes/ellipsises, counter row scale-down fits. *After: `tasbih07.png` renders clean.*
3. **Worship tools grid:** tiles overflowed at the bottom — tile aspect adjusted (0.82 → 0.78). *After: `worship14.png` renders clean.*
4. **AI Home recent chats:** ListTile inside a decorated card asserted "ink may be invisible" — list now sits on its own Material sheet (also makes taps ripple correctly on device).
5. **Button labels:** primary buttons (Splash Enter NOOR, Onboarding Continue via NoorPrimaryButton, Create Account, Login) set `textStyle` inside `styleFrom`, which silently drops the theme's Manrope label font. Removed the override; size/weight now on the label itself. *Before: labels rendered in fallback font; after: theme font everywhere (`splash36.png`, `onboarding37.png`).*

## Still open (honest)

- Pixel-perfect remains **unconfirmed by you** — these captures are the closest visual proof so far; please compare against your pages.
- Reciter photo on Page 03 player, illustrated streak icons on Page 01: artwork-level, not code-level. (Page 11 quote-card illustration fixed 2026-10-07 — see above; verified in refreshed `previews/quran_home11.png`, full suite 27/27 pass, analyze clean.)
- No physical phone run yet: notifications after app kill/reboot, real GPS/compass Qibla, on-device audio, real AI/accounts backend, store preparation — unchanged from Phase 9.

## Phase 11 update (2026-10-07) — full 42-screen audit

All 42 pages now have captures (`previews/*.png`, incl. mushaf04, sources24,
compare25, share suite 19–22, hifz 28–30, saved33, notifications35, dua/hadith
daily 08/09) and were each read against their design PNG. The per-page record
(matched / fixed-in-this-phase / still-open with exact reasons) lives in
**`previews/FULL42_DIFF.md`** — it supersedes the "Still open" list above:

- **Closed this phase:** Page 03/02/05 reciter avatar (design's own crop from
  Page 03 — no fabricated photo), Page 09 Muhammad-calligraphy medallion and
  Page 08 dua medallion (design's own crops), Page 15 four distinct book
  covers (design's own crops), Page 11 banner precached in captures, plus
  code-level fixes on Pages 02, 03, 06, 12, 13, 14, 19, 21, 23, 30, 33, 38, 40
  (see FULL42_DIFF.md for before/after per page). Splash Enter NOOR button kept
  deliberately; Page 36 recapture confirmed proportions, no change needed.
- **Still open (3):** Page 04 real Mushaf page (licensed source), Page 07
  rendered tasbih beads around a live counter, Page 10 rendered compass vs
  live-bearing dial. Everything else is listed as visually close, **not**
  pixel-perfect — the user's eye on the captures is the final gate.
- Verification: `flutter analyze` clean; previews recaptured after fixes
  (all pass); normal suite 7/7; `flutter build web` — see SCAFFOLD_STATUS.md
  Phase 11.

---

## Image fit pass (Phase 11b, 2026-10-07)

The user approved the 42 captures overall ("perfect") but noted some images
did not exactly fit inside their boxes. A full audit of all 35 image sites
found 12 mis-fitting screens — stretched Hadith covers (`BoxFit.fill`), a
Splash tile cropped at its own corners, a giant cropped Settings lantern,
halved header lanterns (15/09), a banded/zoomed Home mosque (01), a cropped
Audio arch (05), cropped Worship header + thumb (14), Salah skyline (06), AI
dome white corners (12), Qibla/Tasbih lantern crops (10/07) and a mis-cropped
Quran banner (11). All were fixed by re-cropping the user's own design PNGs
and/or correcting fit, alignment, clip and box aspect — then recaptured and
re-read. Per-screen before/after table: see **FULL42_DIFF.md → "Image fit
pass (Phase 11b)"**. Verification: analyze clean, previews 43/43, normal
suite 7/7, web build ✓. One honest limit: the Tasbih lantern card sits below
its capture's fold, so that fix is fit-verified, not eye-verified.
