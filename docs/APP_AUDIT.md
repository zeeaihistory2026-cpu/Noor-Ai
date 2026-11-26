# MuslimGo Android audit — 4–5 November 2026

Version: **1.0.4 (19)**. Standard package: `com.noorai.com`.
The separate handset test package is `com.noorai.com.audit`, labelled
**MuslimGo Test**, so it can coexist with the existing signed app.

This is a sideloadable test release. A successful build and automated tests do
not establish reliable alarm delivery, audio decoding, compass accuracy or real
account recovery on a physical phone. Those checks remain explicitly pending.

## Corrective design pass — 4–5 November

The owner selected **Signature (profile option 4)** after reviewing four actual
Flutter previews. That design is implemented in Profile and carried into Home.

- Bright/light is the fresh-install default. Explicit dark mode remains selectable.
  Shared text tokens inherit the current theme, and card surfaces adapt to it.
- Home follows the selected **Option 1 / Compact Daily** design: smaller practice
  tiles, one Ayat preview and concise Hadith/Dua rows. A useful Continue Quran
  card above the bottom navigation restores the actual saved surah/ayah.
- The prayer hero reserves a separate area for mosque artwork. Bounded touch
  parallax does not claim scroll gestures, stops on release/cancel and respects
  reduced motion. Large text wraps without crossing into the image area.
- Salah Tracker groups five actual prayer times and saved checks into a compact
  timetable, with real completion counts and recent activity.
- Profile's top settings gear remains. **Reading language** opens a dedicated
  three-language picker instead of another profile/settings screen. Settings
  no longer duplicates the profile header or draws a false bottom navigation.
- Reader Quick Tools have equal widths and consistent alignment, remain near
  the top of the surah, and open actual listen/save/share/copy/16-line actions.
  The 16-line action resolves the selected verse's real page.
- Lower Ayat reflection/actions and Dua recommendation/share sections wrap at
  large text sizes. Dua recommendations open the selected real item rather than
  sending every card to the same library. Layout regressions scroll to each
  screen’s end at 320px / 200% text.
- Text-size preferences now persist and apply throughout the app alongside
  the operating system's accessibility text scale.
- Profile uses actual saved-item counts, worship streaks, account state and saved
  preferences. Goals persist and return to Profile instead of restarting onboarding.
- Prayer countdowns update every second and on resume. Tomorrow's Fajr comes from
  the next date's timetable. A duplicate Home request can no longer overwrite a
  newer location/settings refresh. Home and Worship begin with astronomical times
  rather than static design samples. Salah rows show actual times clearly.
- Android's explicit **Use device location** action requests foreground GPS/network
  location permission; manual city selection remains available. Legacy IP locations
  retain their approximate-source classification. No startup location prompt is used.
- Quran audio headers change immediately with the selected surah in both Arabic and
  English. Stale metadata responses are ignored. The stats show surah number and
  actual Juz instead of the old static Al-Kahf page number. Metadata no longer waits
  for a whole recitation to finish.
- All 30 daily Ayat now use the complete cited Arabic verse(s), English and
  Urdu translations from the bundled Quran editions. This fixes longer Arabic
  passages paired with short English excerpts; partial transliterations were
  removed. A regression compares every daily entry against its cited source.
- Ayat uses recorded Alafasy recitation. Hadith/Dua speech selects an explicitly male
  voice, or requires a preview and user confirmation when Android omits gender.
  Explicitly female voices are excluded and the confirmed choice is persisted.
- Worship/Zikr no longer display fixed sample progress, streaks, duration or completion
  percentages. The Zikr counter fits narrow screens; completed Adhkar do not inflate
  totals when tapped again. Non-working social-app circles were replaced with a real
  Share Studio action, and recommended Hadith cards open actual selected items.

## Changes made

| Area | Fault found | Result |
| --- | --- | --- |
| Icon | Missing adaptive icon handling and inconsistent branding | Uses the supplied green/gold PNG for app branding and launcher artwork. Outer PNG corners remain transparent; Android adaptive background is emerald, with no white surround. |
| Splash | Saved display name could bypass authentication; inconsistent launch background | Cached secure session or explicit guest entry controls routing. Short accessible animation, emerald native launch screen and Android 12 splash. |
| Signup/login | Duplicate requests and navigation during requests; unclear errors; profile failure could look like failed signup | Validated accessible forms, autofill, password visibility, disabled competing actions, bounded network requests, real Firebase reset request and privacy-preserving reset response. Ancillary profile failure does not undo successful account creation. |
| Session storage | Obfuscated tokens lived in ordinary preferences | Platform secure storage with legacy migration and logout cleanup. Android backup disabled to avoid restoring encrypted values without their key. |
| Prayer calculation | Karachi was mapped to the wrong method; school was ignored; stale location/day caches | Correct method, Hanafi/standard Asr setting, location/method/school-specific caching, city timezone handling and astronomical offline calculation. Settings apply to the timetable and reminders. |
| Reminders | Limited day horizon and incomplete renewal; permission and exact-alarm failures | Seven-day prayer/content plan, 15-minute leads plus prayer-time alarms, serial foreground scheduling, inexact fallback, daily background renewal and tap navigation. An explicit notification action can request exact alarms even after silent startup initialization. Startup does not prompt for notification permission. |
| Azan | No bundled azan notification sound | Bundled 42-second recorded azan on a dedicated Android channel; normal sound for lead/content reminders. Test control uses that same azan channel. This is recorded audio, not a live mosque broadcast. |
| Daily content | Save/copy/share could use a different item or fail to persist | Selected Ayah/Dua/Hadith and its reference carry into bookmarks and share cards. Copy respects the selected day/item. Quran listening uses recorded recitation; Dua/Hadith read-aloud uses labelled device TTS. |
| Quran reading | Network dependence and incorrect use of a 604-page layout for the 16-line mode | Full Arabic, English and Urdu text ships offline: 114 surahs and 6,236 ayahs per edition. True 548-page IndoPak 16-line word positions, validated for complete verse coverage. |
| Mushaf rendering | Decorative headers could replace words; duplicate opening banners; verse-end font mismatch | Preserves every supplied word and all sixteen line slots. Banners occupy empty slots only. Uses matching IndoPak font for the supplied script and end markers. Introductory pages retain their source's intentionally sparse layout. |
| Quran navigation | Home preview rows opened the same surah; Juz tab did not select a Juz; progress was hardcoded | Correct surah navigation, actual Juz selection into the 16-line layout, persisted last-opened surah/ayah on both Home and Quran cards. No invented 76% progress. |
| Quran audio | Optimistic playing state, nonfunctional repetition/range controls, broken reciter bitrate URLs | Actual player state and error/retry UI; selected-ayah start, finite repetitions, ayah range, pauses, seek, speed and surah navigation. Corrected bitrate choices and replaced an unavailable reciter option. |
| Qibla | Tapping a compass invented alignment; fake calibration and AR sensor readings | Android magnetic rotation-vector stream with local magnetic-declination correction, display orientation handling, accuracy/tilt checks and circular angle comparison. Alignment requires a real acceptable reading within five degrees. Unavailable hardware retains the numeric true-north bearing. Removed simulated AR/calibration controls. |
| Share cards | Long text could be cropped; image export rounding and fragile busy state | Fits complete card text, disposes image resources, waits for painting, exports exact stated dimensions, handles cancellation/errors and shares through the system sheet. Android 10+ saves to Pictures/MuslimGo; older Android uses a document picker. |
| Progress | New installs showed fabricated prayer checks, tasbih totals and streaks | Empty defaults, persisted actual prayer checks/counts, activity-date streaks and Journey cards. Tasbih starts another lap after its target. |
| Notification list | Sample delivered history looked real | Shows the calculated upcoming plan; does not claim to be a delivery receipt/history. Test notification feedback checks whether the request succeeded. |

## Evidence and scope

- `assets/quran/manifest.json` records source URLs and SHA-256 hashes for all
  bundled content. The bundling script checks all 548 pages, line numbers, unique
  word records and coverage of all 6,236 verse keys.
- Automated regressions cover authentication failure paths, secure migration and
  logout, guest routing, pending form state, small-screen/200% text layout,
  selected daily content, prayer methods/school/timezones, notification channel
  payloads and exact-alarm fallback, complete offline Quran data, range/repeat
  playback planning, reading-position persistence, compass angle logic, and all
  four PNG export dimensions.
- Live network checks returned full English editions for Bukhari, Muslim,
  Abu Dawud, Tirmidhi, Nasai and Ibn Majah, plus Arabic and Urdu Bukhari. These
  confirm endpoint accessibility, not a scholarly verification of every text or
  successful browsing on the target phone. Hadith editions cache after download;
  they are not all preloaded into the APK.
- The Firebase authentication endpoint responded with the expected invalid-login
  error for an intentionally invalid account. Real registration, verification,
  reset-email receipt and multi-device profile synchronization require an owned
  test account and physical-device testing. No real account was created during
  this check.
- Visual captures in `previews/` show the actual supplied icon, signup, login,
  splash, Quran audio, Qibla and the bundled Mushaf content. They are Flutter
  rendering checks, not screenshots from a connected phone.
- The final source passes **226 functional tests**, **36 focused layout/data
  regressions** (overlapping the full suite), **64 Flutter screen renders**, and
  static analysis with no issues. The layout tests scroll to the end at 320px
  width and 200% text.
- Current final results are recorded in `docs/BUILD_VALIDATION.json`. Older 191-test
  and eight-render logs predate this corrective design pass and are not its evidence.
- Final build, test totals, signature and APK digest are recorded in
  `docs/BUILD_VALIDATION.json` when packaging is complete.

## Remaining limitations and flaws

1. **Physical acceptance checks remain separate from automated tests.** A Realme
   RMX3867 running Android 16 was connected during packaging. Check the final
   device record for completed handset smoke checks. Test sound, cold-start notification navigation,
   permissions, reboot, locked-screen delivery, battery restrictions, timezone
   changes, real reciter playback, Arabic TTS availability, compass direction,
   gallery saving and sharing on the user's handset. Background work cannot
   override Android force-stop, channel mute or manufacturer restrictions.
2. **AI and voice features are unfinished.** The live AI service has no backend
   contract or deployed endpoint; current answers are labelled offline samples.
   Voice AI does not capture speech. Hifz recitation analysis is not connected;
   practice/results screens are clearly labelled self-practice/example results.
   Hifz planner/heatmap examples are not a measured memorization history. They
   must not be marketed as working AI assessment.
3. **Some Quran audio tools remain unavailable.** The non-working download, sleep
   timer and audio-sharing controls were removed from the player. Streams need connectivity; there
   is no complete offline recitation pack. The Mushaf Listen action begins at
   the first ayah on the page and then follows that surah; it does not assemble
   a page-bounded playlist spanning multiple surahs.
4. **Search and commentary are partial.** Quran keyword search still uses a
   network endpoint. Hadith full-text search works within a selected section;
   cross-book topic search uses a curated index. Tafsir needs a connected,
   verified dataset. Quran Notes/Highlights links currently lead to the saved
   library rather than a dedicated annotation editor.
5. **Account separation needs another pass.** Local progress/preferences remain
   device-wide rather than fully namespaced by account. Pending sync data from
   a different UID is not replayed under the current UID, but session-switch and
   token-refresh races need device/backend integration tests. Firestore rules,
   server authorization and production password-recovery delivery were not
   audited from the client repository alone.
6. **Location needs physical acceptance.** Device location is available through an
   explicit foreground-only Android permission request. Older IP-based locations
   remain approximate; users can refresh with device location or select a city. The
   compass uses the selected coordinates and magnetic sensors; nearby metal and
   poor calibration affect direction. At the Kaaba itself the bearing is
   geometrically undefined. Verify against a trusted local reference.
7. **Video export is unfinished.** Animated card preview is a UI preview; export
   currently produces still PNG cards, not rendered MP4 reels.
8. **Distribution needs owner setup.** With no owner release keystore supplied,
   this release-mode APK is signed with the local Android debug certificate for
   sideload testing. Production signing, store configuration, current target-SDK
   requirements and content/font licensing review remain release-owner work.
   The handset's existing 1.0.1 app uses build code 2016 and a different owner
   signing certificate. The owner confirmed the original keystore is unavailable.
   Do not uninstall it or clear its data to install this audit. Use MuslimGo Test
   alongside it. A future in-place production update needs the original signing
   identity and a build code greater than 2016.
9. **Interface localization is partial.** Quran/Hadith translation choices are
   supported, but the application interface still contains English strings and
   does not provide a complete Urdu/Arabic locale. A language preference must not
   be presented as proof that every screen is translated.

## Physical-phone acceptance checks

The authorized Realme Android 16 handset reconnected. Version 1.0.3 Test was
installed with `adb install -r` and cold-launched successfully; the existing
owner-signed app was preserved. The Test app contains a signed-in account;
checks must preserve its session and data. Final 1.0.4 installation and each
observed smoke check are recorded in `docs/BUILD_VALIDATION.json` after packaging.
Automated results are separate from sound delivery and locked/reboot alarm tests.


1. Enable USB debugging, connect by data-capable USB cable, unlock the phone and
   accept its debugging prompt. Install without uninstalling or clearing data.
2. Inspect the launcher under light/dark themes and available launcher shapes:
   no white box; open app and check native-to-Flutter splash transition.
3. With an owned test account: signup, relaunch, logout, wrong password, login,
   reset request and email receipt. Repeat offline and after a network timeout.
4. Select the correct city/method/Asr setting; compare the next day's timetable
   against a trusted local timetable with those same calculation choices.
5. Grant notifications and exact alarms when offered. Use Test azan and each
   content test, then schedule a near-term prayer/reminder on the test device.
   Repeat locked, after reboot, with denied exact alarms, and muted channel.
   Verify tapping each type opens the intended screen from a terminated app.
6. Enable airplane mode and read beginning/middle/end surahs in all three
   editions; navigate all Juz boundaries and the final Mushaf page. Reopen to
   check reading position and bookmarks.
7. Stream each available reciter; verify selected ayah, pause/resume, seeking,
   range, repeats, silence gaps and next-surah behavior. Test interruptions and
   reconnection. Check TTS availability and honest failure feedback.
8. Download and browse Hadith editions in each offered language, reopen offline,
   search a section, save and remove an item, and test read-aloud.
9. Share a non-default Ayah/Dua/Hadith card, verify reference/content and PNG
   size, save it to gallery and open it in an external app.
10. Rotate the flat phone away from metal and compare Qibla to a trusted compass.
    Alignment must follow sensor movement, never a tap; missing hardware must
    show the numeric bearing and unavailable state.

## Suggested next features, in priority order

1. **Offline recitation downloads** with selectable reciter, storage estimates,
   pause/resume downloads, checksums and deletion controls.
2. **Per-account progress and optional backup** with explicit guest-to-account
   migration, conflict handling and a transparent data/export/delete flow.
3. **Useful Hifz practice**: adjustable ranges, persisted self-assessment,
   spaced-repetition reminders and teacher review before attempting AI scoring.
4. **Verified tafsir and annotations**: source/edition citations, per-ayah notes,
   highlights, bookmarks and offline search.
5. **Notification diagnostics** showing permission, channel sound, exact-alarm
   availability, next scheduled times and device-specific battery guidance.
6. **Source-grounded AI** only after a secured backend exists, with inspectable
   citations, uncertainty handling and no fabricated religious rulings.

## Sources

- [Quran Foundation page-layout documentation](https://api-docs.quran.com/docs/tutorials/fonts/page-layout/)
  — distinguishes the 548-page IndoPak 16-line Mushaf from 604-page Madani layouts.
- [AlQuran Cloud API](https://alquran.cloud/api) — Quran edition data.
- [Quran Foundation IndoPak font](https://verses.quran.foundation/fonts/quran/hafs/nastaleeq/indopak/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf)
  — matching Nastaleeq script resource; see `assets/quran/README.md`.
- [AlAdhan prayer API](https://aladhan.com/prayer-times-api) — method and school
  parameters; reproducible public-city fixtures in `test/fixtures/` were fetched
  for 4 November 2026. Karachi Hanafi and Lahore Hanafi/standard calculations are
  compared to these API responses with a three-minute offline tolerance.
- [Android LocationManager](https://developer.android.com/reference/android/location/LocationManager)
  — foreground location acquisition and enabled-provider handling.
- [Android SensorManager](https://developer.android.com/reference/android/hardware/SensorManager)
  and [GeomagneticField](https://developer.android.com/reference/android/hardware/GeomagneticField)
  — native compass orientation and magnetic-declination correction.
- [Azan source and CC0 attribution](AUDIO_CREDITS.md).

## Reproducing checks

```powershell
flutter pub get
dart analyze lib test/app_release_test.dart test/content_and_notifications_test.dart test/reading_compass_export_test.dart
$testFiles = Get-ChildItem test -Filter '*_test.dart' | Where-Object { $_.Name -notmatch 'preview|concept' } | ForEach-Object { $_.FullName }
flutter test --no-pub --concurrency=1 @testFiles
flutter test --no-pub test/previews_test.dart --update-goldens --concurrency=1
flutter build apk --release --no-pub
# Separate QA install; leaves the existing owner-signed package alone.
$env:NOOR_AUDIT_INSTALL = '1'
flutter build apk --release --no-pub --target-platform android-arm64
Remove-Item Env:NOOR_AUDIT_INSTALL
```
