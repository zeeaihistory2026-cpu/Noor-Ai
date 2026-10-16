# NOOR AI Companion — Islamic Spiritual & Lifestyle Flutter App

A production-grade, offline-first Islamic spiritual companion Flutter application crafted with high-fidelity Islamic aesthetics (Midnight Emerald palette, gold accents, geometric art) and rigorous architectural integrity.

---

## 🕌 Overview & Features

- **Daily Dashboard & Worship Hub**: Real-time prayer times calculated via the AlAdhan API with local astronomical fallback, Qibla compass bearing, daily Dhikr counters, and dynamic solar dark mode switching.
- **Holy Qur'an Experience**: Complete 114-Surah reader with Uthmani Arabic script, authentic translations (Saheeh International, Fateh Muhammad Jalandhari), audio recitation streaming (Alafasy), and a 16-line Indo-Pak Hifz Mushaf viewer.
- **Kutub al-Sittah Hadith Library**: Offline-first Hadith reader supporting Sahih al-Bukhari, Sahih Muslim, Sunan Abi Dawud, and Jami` at-Tirmidhi with fast local GZip compressed caching, Arabic typography, English/Urdu translations, and search.
- **Hadith Share Card Studio**: Exportable, pixel-perfect social cards with customizable backgrounds (Emerald, Night, Sand, Gold, Pattern), typography scaling, and verified attribution.
- **Offline-First Synchronization**: Outbox-based background sync with Firebase Firestore via REST API, ensuring zero data loss during network disruptions.
- **Accessibility & Robust Layouts**: Full dynamic text scaling compliance up to 200%, WCAG AAA/AA contrast compliance, and global error boundaries.

---

## 🏗️ Architecture & State Management

NOOR AI follows an observable, reactive unidirectional data flow:

```
                  ┌──────────────────────┐
                  │    NoorController    │ (ChangeNotifier singleton)
                  └──────────┬───────────┘
                             │
                      ┌──────▼──────┐
                      │  NoorScope  │ (InheritedNotifier)
                      └──────┬──────┘
                             │
     ┌───────────────────────┼───────────────────────┐
     ▼                       ▼                       ▼
Prayer Screen           Qur'an Screen           Hadith Library
```

- **`NoorScope`**: Root `InheritedNotifier` exposing `NoorController` across the entire widget hierarchy.
- **`NoorTheme`**: Canonical design token provider defining `NoorColors` (emerald dark, midnight emerald, gold accents), `NoorType` (Manrope, Cormorant Garamond, Amiri, Noto Nastaliq Urdu), and `NoorRadius`.
- **`UserDataService` / `LocalAuthService`**: Dual-layer authentication and persistence architecture with secure offline fallback and session management.

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>=3.3.0`
- **Dart SDK**: `>=3.3.0 <4.0.0`
- **Android Studio / Xcode** for physical device deployment

### Setup & Run
```bash
# Clone the repository
git clone https://github.com/your-username/Noor-Ai.git
cd Noor-Ai

# Fetch dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

---

## 🧪 Testing & Verification

Run the comprehensive unit, widget, and architectural test suite:

```bash
# Run all unit and regression tests
flutter test test/phase12_test.dart test/phase12_textscale_test.dart test/phase13_test.dart test/phase14_solar_test.dart test/phase16_all_hadith_books_parsing_test.dart

# Run static code analysis
flutter analyze
```

---

## 📁 Repository Structure

```
├── lib/
│   ├── data/           # Services (Qur'an, Hadith, Prayer, Auth, Cache, Sync)
│   ├── screens/        # Feature screens (Home, Quran, Worship, Library, Onboarding)
│   ├── theme/          # Design tokens (NoorColors, NoorTheme, NoorType)
│   ├── widgets/        # Reusable design system components
│   └── main.dart       # Application entry point & error boundaries
├── test/               # Regression, text-scale, solar-switching, and integrity tests
├── assets/             # Vector icons, book covers, and fonts
└── docs/               # Architecture decision records, roadmaps, and sprint logs
```

For detailed specifications, sprint logs, and technical decisions, refer to the [docs/](file:///docs/) directory.
