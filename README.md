# Oloz — Calm, Non-Shaming Digital Wellbeing

Oloz is a cross-platform digital wellbeing application for **Android** (primary mobile) and **Windows** (desktop) that monitors screen time and counts short-form video consumption (Instagram Reels, YouTube Shorts, TikTok, and Facebook Reels) with a calm, non-judgmental aesthetic.

---

## Key Highlights

- **Two Chromatic Colors**: Built strictly around calm **Indigo** (`#5870C2` / `#6B83D6` for screen time) and warm **Peach** (`#F0A98E` for short-form video). No alarmist red warning bars.
- **Accurate Reel Counting**: Accessibility-based scroll detection with dwell verification (>= 700ms), fast flick consolidation, and direction discrimination.
- **Win32 Desktop Tracking**: Pure `dart:ffi` foreground process monitoring and user idle pause (> 120s inactivity).
- **Zero Privacy Invasions**: No window titles, no URLs, no text messages, and no screen frames are ever captured or stored.
- **Offline First**: Runs 100% offline using a local Drift SQLite database. Optional Supabase cloud sync uploads only daily aggregates protected by Row Level Security (RLS).
- **Responsive Layout**: Adapts between a mobile 4-tab bottom navigation bar (`<720dp`) and a desktop sidebar split-view (`>=720dp`, optimized for 1440px displays).

---

## Architecture Overview

```
                      ┌────────────────────────────┐
                      │    Flutter UI Layer        │
                      │  (Riverpod + GoRouter)     │
                      └──────────────┬─────────────┘
                                     │ Streams / Queries
                                     ▼
                      ┌────────────────────────────┐
                      │    Domain Repositories     │
                      │  (Usage, Reel, Limit, Sync)│
                      └──────────────┬─────────────┘
                                     │ Type-safe DAOs
                                     ▼
                      ┌────────────────────────────┐
                      │     Local Drift SQLite     │
                      │   (Tables & Aggregations)  │
                      └──────────────▲─────────────┘
                                     │ Background Ingestion
           ┌─────────────────────────┴────────────────────────┐
           ▼                                                  ▼
┌─────────────────────────────┐                    ┌────────────────────────────┐
│      Android Tracker        │                    │      Windows Tracker       │
│ - UsageCollector (Stats)    │                    │ - Win32 FFI Polling        │
│ - OlozAccessibilityService  │                    │ - Idle Pause (> 120s)      │
│ - LimitEnforcer (Overlay)   │                    │ - Friendly App Mapping     │
└─────────────────────────────┘                    └────────────────────────────┘
```

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `>=3.19.0` (Dart `>=3.3.0`)
- **Android SDK**: API level 26+ (minSdkVersion 26, targetSdkVersion 34)
- **Windows**: Windows 10/11 64-bit with Visual Studio C++ build tools

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/oloz/oloz.git
   cd oloz
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. (Optional) Configure environment variables for cloud sync:
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase URL and Anon Key
   ```
4. Run code generation (Drift):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## Running and Building

### Android
```bash
# Debug mode on connected physical device or emulator
flutter run -d android

# Production release APK
flutter build apk --release

# Production App Bundle for Google Play
flutter build appbundle --release
```

### Windows Desktop
```bash
# Run in debug mode
flutter run -d windows

# Build release binary
flutter build windows --release
```

---

## Verification & Testing

Run the full verification suite (static analysis + 61 automated tests):

### On Windows
```cmd
scripts\check.bat
```

### On macOS / Linux
```bash
chmod +x scripts/check.sh
./scripts/check.sh
```

Or run directly via Flutter:
```bash
flutter analyze
flutter test
```

---

## Documentation

- **[Architectural Decisions](docs/decisions.md)**: Rationale behind Drift entity naming, pure Kotlin state machines, pure Win32 FFI, and tokens.
- **[Reel Detection Verification](docs/reel-verification.md)**: Detection markers, dwell heuristics, and multi-app verification results.
- **[Manual Testing Guide](docs/manual-tests.md)**: Step-by-step procedures for physical Android and Windows test scenarios.
- **[Privacy Policy](docs/PRIVACY_POLICY.md)**: Play-Store-compliant privacy disclosure.
- **[Final Report](docs/FINAL_REPORT.md)**: Comprehensive phase-by-phase completion report and verification metrics.

---

