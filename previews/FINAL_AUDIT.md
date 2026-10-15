# NOOR AI Companion — Phase 16 Job 5: SENIOR FULL AUDIT

Date: 2026-10-13 · Auditor role: auditor + senior app dev + PM + design expert + UX/UI designer
Scope: button-by-button audit, image-fit audit (Phase 11b criteria), new-work audit
(hadith databank 15/16/17, Reminder Center 31, Reader 03 / Audio 05 surah params),
regression pass over all 43 previews vs the user's design PNGs.

Design source: `~/workspace/noor-design/NOOR_AI_Companion_Complete_UI_Pages_01-42/`
Rule: Noor tokens only, no redesign, brief attributed religious excerpts only.

## Method
1. Grepped all of `lib/` for dead-handler patterns: `() {}`, `() async {}`,
   `onTap: null`, `onPressed: null`, `onChanged: null`, `UnimplementedError`,
   `NoorStubScreen` usages, "coming soon" handlers.
2. Read every hit in context; classified each as (a) wire to a real action,
   (b) honestly disabled, or (c) honest feedback.
3. Added shared `showNoorOverflowSheet()` (`lib/widgets/noor_components.dart`):
   bottom sheet, Noor tokens only; every entry runs a REAL app action
   (navigation, clipboard, persisted toggle, sort, share target) or shows
   honest descriptive copy — never a fabricated capability.
4. Extended the phase12 dead-handler count-test to also assert zero
   *unconditional* `onPressed:/onTap:/onChanged: null` outside the one
   documented visibly-dimmed fallback branch.
5. Added `test/phase16_audit_test.dart`: 6 widget tests that tap the
   newly-wired controls and assert the real outcome.
6. Recaptured goldens (`flutter test test/previews_test.dart --update-goldens`);
   re-read every changed golden against its design PNG.

## Findings & fixes

| # | Severity | Page / file | Finding | Fix applied / status |
|---|----------|-------------|---------|----------------------|
| 1 | High | 8 screens via `NoorPlainHeader` (`lib/widgets/noor_share_card.dart:162`): Studio 19, Editor 20, Reel 21, Export 22, Journey 32, Saved 33, Profile 34, Notifications 35 | Header ⋮ was `onPressed: null` on all 8 — looked live, did nothing. | **Fixed.** Header takes optional `moreActions`/`moreInfo`; each screen passes real actions (see rows 2–9). Screens passing none get the icon visibly dimmed (Opacity 0.38) — honestly disabled, never fake-live. |
| 2 | High | 32 My Journey | ⋮ dead. | **Fixed:** ⋮ → "Share milestone" (→ Share Card Studio, Phase 14 streak cards) + "Prayer reminders" (→ Reminder Center). |
| 3 | High | 35 Notifications | ⋮ dead. | **Fixed:** ⋮ → "Notification settings" (→ Reminder Center). |
| 4 | High | 34 Profile | ⋮ dead; worse: Privacy + Subscription rows showed chevrons (tappable affordance) with `onTap: null`. | **Fixed:** ⋮ → "Open Settings" + "Saved Content" (both real). Chevrons now render only where a target exists (settings-screen pattern); Privacy/Subscription are honest display rows. |
| 5 | High | 33 Saved & Notes | ⋮ dead. | **Fixed:** ⋮ → honest info sheet ("Bookmarks you save across NOOR collect here, kept on this device only"). Info-only by design — inventing a fake action would be worse. |
| 6 | High | 19 Share Card Studio | ⋮ dead. | **Fixed:** ⋮ → "Animate" + "Export" (same real targets as the body buttons). |
| 7 | High | 20 Card Editor | ⋮ dead. | **Fixed:** ⋮ → "Reset edits" (real setState) + "Continue to Share & Export" (real push). |
| 8 | High | 21 Reel Creator | ⋮ dead. | **Fixed:** ⋮ → "Continue to Share & Export" (real push). |
| 9 | High | 22 Share & Export | ⋮ dead. | **Fixed:** ⋮ → "Share" / "Save to device" / "Copy text" (the screen's real `_share`/`_save`/`_copy`). |
| 10 | High | 08 Dua of the Day | calendar + ⋮ dead. | **Fixed:** calendar → "Daily Dua" sheet (honest: new dua daily) + "Dua reminder settings" (→ Reminder Center — the Dua of the Day reminder verified in Job 6). ⋮ → Copy dua (real `_copyDua`), Save toggle (real), Open in Share Studio (real). |
| 11 | High | 09 Hadith of the Day | ⋮ dead. | **Fixed:** ⋮ → Copy hadith (real `_copyHadith`), Save toggle (real), Open in Share Studio (real). |
| 12 | High | 02 Surah List | tune (filter) icon dead. | **Fixed:** tune → "Sort Surahs" sheet: 1→114 / 114→1 — real sort applied to the list (new `_ascending` state). Widget-tested both directions. |
| 13 | High | 04 Hifz Mushaf | bookmark + settings dead. | **Fixed:** converted to StatefulWidget; bookmark toggles a real persisted NoorStore bookmark (`mushaf:al-baqarah:page2`) with snackbar + restores on open. Settings → "Mushaf options" sheet: "Test me on this page" (→ Hifz AI Test) + "Hifz progress" (→ heatmap) — both real. |
| 14 | High | 27 Hifz AI Test | ⋮ dead. | **Fixed:** ⋮ → honest info ("Recitation analysis is not connected yet") + "Restart test" (real state reset). |
| 15 | High | 28 Hifz Test Results | ⋮ dead. | **Fixed:** ⋮ → "Copy summary" (real clipboard of the on-screen summary), "Retake test" (real pushReplacement), "Open revision planner" (real nav). |
| 16 | High | 29 Hifz Revision Planner | ⋮ dead. | **Fixed:** ⋮ → "Mark all done" / "Clear all" (real `_done` set ops). |
| 17 | High | 30 Hifz Heatmap | ⋮ dead. | **Fixed:** ⋮ → honest legend ("emerald = strong … rust = weak") + "Open revision planner" (real nav). |
| 18 | High | 05 Audio Player | ⋯ dead. | **Fixed:** ⋯ → "Playback options" sheet with 1x–2x speeds — the same real `_player.setSpeed` path as the body's Speed chip. |
| 19 | High | 23 AI Chat | ⋮ dead. | **Fixed:** ⋮ → "Copy last answer" (real clipboard of the latest AI bubble) + "Clear conversation" (real `_messages` reset to the welcome thread). |
| 20 | High | 24 AI Answer Sources | ⋮ dead. | **Fixed:** ⋮ → "Copy references" (real clipboard of the exact refs shown on screen). |
| 21 | High | 25 Madhhab Compare | ⋮ dead. | **Fixed:** ⋮ → honest scope note ("not rulings — consult a scholar") + "Copy comparison" (real clipboard of the on-screen text) + "Ask AI about this" (→ AI chat). |
| 22 | High | 26 Voice AI | ⋮ dead. | **Fixed:** ⋮ → honest info ("microphone is not connected — demo") + "Open text chat" (→ AI chat). |
| 23 | High | 06 Salah Tracker | calendar + ⋮ dead. | **Fixed:** calendar → honest sheet ("log is kept for today only in this version") + "Prayer reminders" (→ Reminder Center). ⋮ → "Mark all as prayed" / "Clear today's log" (real `_done` ops). |
| 24 | High | 31 Reminder Center | ⋮ dead. | **Fixed:** ⋮ → honest lead-time note ("Salah reminders fire 15 min before") + "Turn all on" / "Turn all off" (real: persists every toggle via NoorStore + re-plans, reusing `_onToggle` semantics). |
| 25 | High | 15 Hadith Library | menu_book icon dead. | **Fixed:** → "Hadith databank" sheet with the honest sourcing (free hadith-api CDN; Sunnah.com = future, needs key). Same text the `HadithDatabankGate` documents. |
| 26 | High | 16 Hadith Chapters | ⋮ dead. | **Fixed:** ⋮ → honest limit ("full cross-book keyword search needs a server-side index") + "View my bookmarks" (real: jumps to the screen's Bookmarks tab). |
| 27 | High | 17 Hadith Detail | ⋮ dead. | **Fixed:** ⋮ → "Copy hadith text" (reuses the real `_copyHadith`) + "Ask AI about this hadith" (→ AI chat). |
| 28 | High | 18 Dua Library | ⋮ dead. | **Fixed:** ⋮ → "Dua categories" quick-jump (real: sets the screen's `_chip` filter). |
| 29 | Medium | `lib/screens/worship/reminder_center_screen.dart` (`_setAll`) | New bulk action used `setState(() {})` — trips the `() {}` dead-handler count-test. | **Fixed:** expanded to a commented block; count-test green. |
| 30 | Medium | Profile 34 (design fidelity note) | Design PNG shows chevrons on all 7 rows; Privacy/Subscription now show none. | **Intentional deviation, kept.** A chevron promises navigation; there is no Privacy screen or paywall yet (matches AI/Accounts ~5.6). Honesty over pixel-match; documented here. Still open: real Privacy screen + subscription flow. |
| 31 | Low | `lib/screens/home/dua_of_the_day_screen.dart:231` | Lantern `Image.asset` has no `fit:` (only `height: 54`). | **Reviewed OK, no change:** box hugs the image at natural aspect — no stretch possible; `fit` would be a no-op. Noted for the record. |

### Dead-handler census (final)
- `() {}` / `() async {}` in `lib/`: **0** (count-test green).
- Unconditional `onPressed:/onTap:/onChanged: null` in `lib/`: **0**, except the single
  documented visibly-dimmed fallback branch in `NoorPlainHeader` (Opacity 0.38,
  tooltip "unavailable") — currently unused (all 8 screens pass real actions).
- Conditional nulls kept deliberately (real disabled states, all visibly
  disabled): share-export `_busy ? null`, hadith-detail prev/next at list
  boundaries, body `_action(..., null)` circles (sand background + muted icon —
  the codebase's honest disabled pattern, e.g. Listen buttons).
- `NoorStubScreen`: defined but **unused** (no screen routes to it). `UnimplementedError`:
  only the documented AI-service no-key guard. "Coming soon" snackbars (qibla tools,
  worship tools): all fire honest feedback — responsive, not dead.

### Image-fit audit (Phase 11b criteria)
- 31 `Image.asset` usages, 0 `DecorationImage`. Fits: 25× `cover`, 5× `contain`,
  3× `scaleDown`; 1 fit-less (row 31, hug-content — correct).
- Rounded-corner clipping: medallions use `ClipOval`, covers/arches use
  `ClipRRect` — verified in the changed screens' goldens; no square corners
  leaking outside rounded cards.
- No pale bands, no stretch observed in any of the 43 recaptured previews.
- No asset was at fault; **no re-crop from the user's PNGs was needed**.
- 3 goldens changed by this audit (dua_day08, profile34, saved33) — each
  re-read against its design PNG: header icons now render live (they do
  something real), profile chevron removal is the documented row-30 deviation.
  All other 40 goldens pixel-identical.

### New-work audit (Jobs 4/6/7)
- Hadith 15/16/17: layouts honour the design; offline banners honest; no
  overflow (long section titles wrap); contrast tokens intact; the new ⋮/menu_book
  actions reuse existing real paths. hadith_detail17 golden: prev/next correctly
  boundary-disabled; Listen visibly disabled.
- Reminder Center 31: rows show live plan times (Job 6); new ⋮ is header-only,
  golden pixel-identical.
- Reader 03 / Audio 05: surah-param wiring (Job 7) intact; audio05 golden
  pixel-identical after the ⋯ wiring (dark header, no pixel delta).

### Verification (executed)
- `flutter analyze`: **No issues found.**
- `flutter test`: **142/142 pass** — includes the strengthened dead-handler
  count-test, 6 new `phase16_audit_test.dart` widget tests (tap → real outcome),
  and all 43 deterministic goldens.
- `flutter build web`: **✓ Built build/web.**

## FINAL VERDICT: GREEN for the final APK build.

No blockers. The full control surface is live-or-honestly-disabled, the suite is
green, and the only intentional design deviation (profile chevrons) is
documented above.

### Still open (not blockers — known programme gaps)
1. Privacy screen + subscription/paywall flow (Profile rows honestly display-only).
2. Real ringing with the app killed / after reboot — provable only on the user's phone (Job 6).
3. Sunnah.com API key — user-owned key needed; documented as future, never faked (Job 4).
4. Full cross-book live keyword search — needs a server-side index; v2 (Job 4).
5. Live AI backend / accounts (~5.6) — unchanged by this audit.
6. Performance 8.8 — needs a real low-end phone profile (unchanged).
