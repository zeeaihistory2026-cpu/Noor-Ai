# NOOR AI Companion — Screen Design Review
**Date:** 2026-10-16
**Version:** v10
**Total Screens:** 43

> Read-only review. No code was changed.

---

## Design System
- **Colors:** Emerald `#0F5132` / `#0B3D2E`, Gold `#D4AF37`, Cream `#F7F4EA`, Ink (dark text), White cards
- **Typography:** Manrope (Google Fonts) via `NoorType` scale
- **Cards:** White, rounded corners (`NoorRadius.card`), subtle shadow (`NoorShadows.card`)
- **Buttons:** Dark emerald with white text (`NoorPrimaryButton`)
- **Navigation:** 5-tab bottom `NavigationBar` — Home / Quran / AI / Worship / Library

---

## 1. ONBOARDING & AUTH

### 1.1 Splash Screen (`splash_screen.dart`)
- Full-screen emerald gradient with centered NOOR logo
- Auto-advances after ~2s
- Checks Firebase session → logged in goes to `NoorTabShell`, else `OnboardingScreen`
- **Note:** Logo + tagline "Faith • Guidance • Growth"

### 1.2 Onboarding Screen (`onboarding_screen.dart`)
- PageView with 3 slides (illustration + headline + subtext)
- Dots indicator, Skip / Next buttons
- Final slide → Goal Selection

### 1.3 Goal Selection (`goal_selection_screen.dart`)
- "What's your goal?" — selectable goal chips/cards (e.g. Read Quran daily, Pray 5x, Learn Arabic)
- Continue button → Language Selection

### 1.4 Language Selection (`language_selection_screen.dart`)
- English / اردو / العربية options
- Continue → Madhhab Preference

### 1.5 Madhhab Preference (`madhhab_preference_screen.dart`)
- Hanafi / Maliki / Shafi'i / Hanbali cards
- Continue → Create Account

### 1.6 Create Account (`create_account_screen.dart`)
- Name, Email, Password fields with validation
- Dark emerald "Create Account" button (white text)
- Link to Login
- On success → Firebase Auth register → `NoorTabShell`

### 1.7 Login (`login_screen.dart`)
- Email, Password fields
- Dark emerald "Login" button (white text)
- "Forgot password" (shows snackbar — backend not connected)
- Link to Create Account
- On success → Firebase Auth login → `NoorTabShell`

---

## 2. HOME TAB

### 2.1 Home Dashboard (`home_dashboard_screen.dart`)
- **Header:** "Assalamu Alaikum," + user name (from Firebase) + Hijri date; bell icon (→ Notifications) + avatar circle with user initials (tappable → Profile)
- **Next Prayer hero card:** Mosque artwork, prayer name (e.g. ASR), time, countdown
- **Streak cards (3):** Salah / Dhikr / Quran — each with day count + flame icon
- **Dua of the Day card:** Arabic + transliteration + translation + Listen/Save/Share
- **Hadith of the Day card:** Arabic + translation + reference + Listen/Save/Share
- **Continue Quran card:** Surah Al-Kahf, Ayah 18, 76% progress bar, "Continue Reading" button
- **Ask AI input:** Rounded text field "Ask anything about Islam..." + mic button

### 2.2 Dua of the Day (`dua_of_the_day_screen.dart`)
- Full dua detail: Arabic (RTL), transliteration, translation, reference
- Listen / Save / Share actions

### 2.3 Hadith of the Day (`hadith_of_the_day_screen.dart`)
- Full hadith detail: Arabic + English, collection reference
- Listen / Save / Share actions

### 2.4 My Journey (`my_journey_screen.dart`)
- Progress overview: streaks, completed goals, stats
- Links to detailed trackers

### 2.5 Notifications (`notifications_screen.dart`)
- List of notification cards (prayer reminders, daily ayah, etc.)
- Bell icon with gold dot indicator on home

### 2.6 Profile (`profile_screen.dart`)
- Avatar with initials, name + email (from Firebase)
- Stats row, menu list (Edit profile, etc.)
- Logout button

### 2.7 Settings (`settings_screen.dart`)
- Profile card (name/email from Firebase)
- Sections: Preferences, Notifications, Appearance, About
- Toggle rows with icons

---

## 3. QURAN TAB

### 3.1 Quran Home (`quran_home_screen.dart`)
- Search bar, "Continue Reading" card
- Quick links: Surah List, Audio, Hifz, Bookmarks

### 3.2 Surah List (`surah_list_screen.dart`)
- Scrollable list of 114 surahs: number badge, Arabic name, English name, ayah count, revelation type
- Tap → Reader

### 3.3 Quran Reader (`quran_reader_screen.dart`)
- Surah header with **white circular audio-play button**
- **Full-surah scrollable view** — each ayah as a separate card (Arabic + English + Urdu from AlQuran Cloud API)
- Ayah number badges, bookmark per ayah
- **Note:** Long surahs (Al-Baqarah 286 ayahs) build all cards at once — needs device performance testing

### 3.4 Quran Audio Player (`quran_audio_player_screen.dart`)
- Cream arch card with mosque artwork (aspect 417:255)
- Surah title + meaning + "Ayah X" indicator
- Stats row: Ayah range / Juz / Page
- Reciter row: avatar + name (Mishary Alafasy) — **currently fixed, no selector UI**
- Seek slider, play/pause/skip, Speed / Timer / Sleep buttons
- **Missing per user request:** Surah selector, Ayah selector, Reciter selector

### 3.5 Hifz Mushaf (`hifz_mushaf_screen.dart`)
- 16-line Mushaf page prototype with ruled slots
- **Not yet:** full 16-line layout with 10 Urdu translation lines per page (user-requested)

### 3.6 Hifz AI Test (`hifz_ai_test_screen.dart`)
- AI listening test UI: prompt ayah, record, feedback

### 3.7 Hifz Test Results (`hifz_test_results_screen.dart`)
- Score breakdown, mistakes highlighted

### 3.8 Hifz Heatmap (`hifz_heatmap_screen.dart`)
- Weak-page heatmap grid (green→red)

### 3.9 Hifz Revision Planner (`hifz_revision_planner_screen.dart`)
- Revision schedule list

---

## 4. AI TAB

### 4.1 AI Assistant Home (`ai_assistant_home_screen.dart`)
- Suggestion chips, chat entry, voice button
- Links to Chat / Voice / Madhhab Compare

### 4.2 AI Chat (`ai_chat_screen.dart`)
- Message bubbles (user right / AI left), input bar
- Source citations below AI answers

### 4.3 AI Answer Sources (`ai_answer_sources_screen.dart`)
- Referenced Quran/Hadith sources list

### 4.4 Voice AI (`voice_ai_screen.dart`)
- Mic visualizer, transcript, response

### 4.5 Madhhab Compare (`madhhab_compare_screen.dart`)
- Side-by-side rulings across 4 madhhabs

---

## 5. WORSHIP TAB

### 5.1 Worship Dashboard (`worship_dashboard_screen.dart`)
- Grid of tools: Salah Tracker, Zikr, Qibla, Reminders
- **Missing per user request:** Islamic Calendar, Zakat Calculator

### 5.2 Salah Tracker (`salah_tracker_screen.dart`)
- Emerald header with mosque skyline crop
- **Today's Prayers:** 5 tappable prayer columns (Fajr–Isha) with check circles
- "Mark all as prayed" / reset quick actions
- **Salah Streak card (dark):** flame icon, "12 Days", week row (M–S) with check circles — **week row now in its own row to prevent overflow**
- Monthly Overview: 91% ring, stats
- Insights card with lantern artwork
- Quick Actions + Learn Salah (prostration artwork)
- **Firebase:** prayer checkmarks sync to `users/{uid}/prayerLogs/{date}`

### 5.3 Zikr & Tasbih (`zikr_tasbih_screen.dart`)
- Tabs: Tasbih / Daily Adhkar / My Zikr
- Dhikr selector (Arabic + meaning)
- **Big emerald counter circle** (208px, gold border): count / target
- **Dynamic beads:** dots around the circle — gold filled = counted, outlined = remaining; count grows/shrinks with taps
- Undo (-) / Add (+) round buttons
- Target chips: 33 / 66 / 99 / 100 / Custom — **now horizontally scrollable, fixed 72px width**
- Other Dhikr cards, Today's Progress (Sessions / Duration / Completion), Daily Tip
- **Text scaling:** all Text widgets locked to `TextScaler.linear(1.0)` to prevent huge rendering on large system font settings

### 5.4 Qibla Finder (`qibla_finder_screen.dart`)
- Compass dial with Kaaba direction
- "Update Location" button (white text on emerald)
- Tool tiles: AR View / Sun Position / Map View — **still "Coming soon", not functional**
- **Missing:** real GPS + device compass plugin

### 5.5 Reminder Center (`reminder_center_screen.dart`)
- Prayer reminder toggles, custom reminder list
- Add reminder form

---

## 6. LIBRARY TAB

### 6.1 Library Home (`library_home_screen.dart`)
- Grid: Hadith, Dua, Share Studio, Saved, etc.

### 6.2 Hadith Library (`hadith_library_screen.dart`)
- **Language selector:** English / اردو / العربية chips
- Featured Collections (4 covers)
- **Browse by Category: 3 cards per row** (was 4)
- Popular Books list
- "Build Your Knowledge" banner with white-text "Continue Reading →" button

### 6.3 Hadith Chapters (`hadith_chapters_screen.dart`)
- Chapter list for selected book + language

### 6.4 Hadith Detail (`hadith_detail_screen.dart`)
- Arabic + selected language text, narrator chain, reference
- Bookmark / Share

### 6.5 Dua Library (`dua_library_screen.dart`)
- Category rows with text overflow protection
- Dua cards: Arabic + translation

### 6.6 Share Card Studio (`share_card_studio_screen.dart`)
- Card preview, Edit / Animate / Export buttons (white text on emerald)
- **Open:** preview fit and export framing not verified against design

### 6.7 Card Editor (`card_editor_screen.dart`)
- Text / background / style editors

### 6.8 Share Export (`share_export_screen.dart`)
- Platform share options

### 6.9 Reel Creator (`reel_creator_screen.dart`)
- Animated reel builder

### 6.10 Saved Content (`saved_content_screen.dart`)
- Bookmarked ayahs / hadiths / duas

---

## 7. BACKEND (Firebase — project `noor-ai-916ed`)

- **Auth:** Email/password via Firebase Auth REST API (no native SDK)
  - Token auto-refresh on 401 (ID tokens expire after 1h)
  - Session in SharedPreferences (`fb.idToken`, `fb.uid`, `fb.refreshToken`)
- **Firestore structure:**
  - `users/{uid}` — name, email, createdAt, language, madhhab, goal, streaks, preferences
  - `users/{uid}/prayerLogs/{yyyy-MM-dd}` — fajr/dhuhr/asr/maghrib/isha booleans
  - `users/{uid}/zikrLogs/{date}`, `quranProgress/{surah}`, `bookmarks/`, `reminders/`
- **Security rules:** each user can read/write only their own `/users/{uid}` subtree (user confirmed rules pasted)

---

## 8. BUILD & RELEASE

- **Package:** `com.noorai.com` (matches Firebase config)
- **Version:** `0.1.0+10` (version code increments per build → updates install over, no uninstall needed)
- **APK:** `NOOR-v10.apk` (22.6 MB, arm64)
- **Signing:** same key across builds (required for update-over-install)
- **Permissions:** `INTERNET` declared (Quran/Hadith/Audio load at runtime)
- **Dark mode:** forced light (`themeMode: ThemeMode.light` + `forceDarkAllowed=false` + explicit Scaffold cream / NavBar white backgrounds)
- **Repo:** https://github.com/zeeaihistory2026-cpu/Noor-Ai (branch `main`, v10 pushed)

---

## 9. KNOWN OPEN ITEMS (not changed in this review)

1. **Quran Audio:** no Surah/Ayah/Reciter selectors (user requested)
2. **16-line Mushaf** with 10 Urdu translation lines per page (user requested; current screen is a prototype)
3. **Qibla:** AR View / Sun Position / Map View are "Coming soon"; no real GPS/compass plugin
4. **Worship Dashboard:** Islamic Calendar + Zakat Calculator missing (user reported)
5. **Share Card Studio:** preview fit / export framing not verified vs design
6. **Quran Reader:** full-surah list builds all ayah cards at once — long surahs need device performance testing
7. **Crash diagnosis:** home-screen black-background reports unresolved without a device logcat; USB logcat was abandoned by user ("ok leave it")
8. **AI backend:** no live AI service connected (chat/voice are UI shells)
