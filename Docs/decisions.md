# Architectural Decision Records (ADRs)

This document records the architectural and technical design decisions made throughout the engineering of Oloz v1.

---

## ADR 1: Drift Table Naming & Collision Avoidance (`@DataClassName('AppLimit')`)

- **Context:**
  The database schema contains a table named `Limits` (`tables.dart`) for per-app and global time/reel thresholds. By default, Drift generates a data class named `Limit`. However, `Limit` collides with Drift's SQL query clause `drift.Limit(count, offset)`.
- **Decision:**
  Annotate the table with `@DataClassName('AppLimit')`.
- **Consequences:**
  Eliminates name collision in Dart imports, providing unambiguous type references (`AppLimit` for database rows, `drift.Limit` for query limits).

---

## ADR 2: Decoupled Pure Kotlin State Machine for Reel Counting

- **Context:**
  Android Accessibility Services run on the Android main thread and receive high volumes of `AccessibilityEvent` instances. Combining gesture parsing, state tracking, and UI updates inside the service class leads to tight coupling and makes unit testing difficult.
- **Decision:**
  Isolate all detection heuristics into a pure, testable Kotlin class (`ReelDetector.kt`), driven by declarative JSON configuration (`ReelDetectorConfig.kt`). The `OlozAccessibilityService` only forwards filtered event primitives (viewId, eventType, timestamp, deltaY) to the detector.
- **Consequences:**
  1. The detection logic can be verified with millisecond-level precision in unit tests without Android OS dependencies (`ReelDetectorTest.kt`).
  2. Dwell times (700ms), fast flick consolidation, and debouncing (500ms) can be fine-tuned without modifying service lifecycle code.

---

## ADR 3: Pure Win32 FFI with `WindowsSystemApi` Test Abstraction

- **Context:**
  Windows desktop foreground tracking requires querying active window handles (`GetForegroundWindow`), extracting process executables (`QueryFullProcessImageNameW`), and detecting user idle time (`GetLastInputInfo`). Relying on third-party binary plugins introduces build fragility and test failures on non-Windows test runners.
- **Decision:**
  Implement tracking using native `dart:ffi` bindings to `user32.dll` and `kernel32.dll`. Abstract all OS interaction behind a clean `WindowsSystemApi` interface, providing `NativeWin32SystemApi` in production and `FakeWindowsSystemApi` in test suites.
- **Consequences:**
  1. Zero third-party native plugin dependencies for Windows tracking.
  2. 100% of Windows tracking logic (foreground transitions, midnight splitting, idle pauses after 120s) is testable on any operating system during CI/CD.

---

## ADR 4: Strict Privacy Guarantee — Zero Window Titles or URLs

- **Context:**
  Many screen time applications record full window titles, browser tab URLs, or accessibility screen text. This captures highly sensitive user information (e.g. document titles, private search queries, message previews).
- **Decision:**
  Enforce at the architectural level that window titles, browser tab headers, web URLs, and screen text are NEVER read, captured, stored, or synced:
  - On Windows: only the base executable name is captured (e.g. `chrome.exe`, `Code.exe`).
  - On Android: only package names (`com.instagram.android`) and layout node IDs (`clips_viewer_view_pager`) are examined. Text content inspection is disabled in `accessibility_service_config.xml`.
- **Consequences:**
  Total user privacy is guaranteed by design.

---

## ADR 5: Two-Chromatic-Color Design System with Token Centralization

- **Context:**
  The design specification requires a calm, non-shaming aesthetic (Linear/Raycast caliber) with exactly two chromatic accent colors: Indigo (`#5870C2` / `#6B83D6` for time) and Peach (`#F0A98E` for reels). Spreading raw hex literals across UI files leads to design drift.
- **Decision:**
  Centralize 100% of color tokens and typography in `lib/core/theme/oloz_tokens.dart` and `oloz_theme.dart`. Enforce that no raw hex color literals exist outside `oloz_tokens.dart`.
- **Consequences:**
  Guarantees consistent visual hierarchy, dark mode compatibility, and zero visual clutter.

---

## ADR 6: Offline-First SQLite Architecture with Daily Aggregate Cloud Sync

- **Context:**
  A digital wellbeing tracker must function reliably without internet access. Syncing raw real-time sessions to a server incurs heavy battery and bandwidth overhead while exposing granular personal habits.
- **Decision:**
  Store all raw events and sessions in a local SQLite database using Drift. If the user opts into cloud sync, sync only **daily aggregates** (e.g., date, total minutes, total reels, per-app minutes) to Supabase in batches of <= 500 rows. Cloud data is protected by Supabase Row Level Security (`auth.uid() = user_id`).
- **Consequences:**
  1. Oloz functions with 0ms network latency and works 100% offline.
  2. Cloud bandwidth and battery drain are near zero.
  3. Raw second-by-second activity never leaves the device.

---

## ADR 7: Dependency Justification Register

In accordance with §15, every dependency in `pubspec.yaml` is justified below:

| Package | Purpose / Justification |
| :--- | :--- |
| `flutter_riverpod` | Reactive state management, dependency injection, and test mock overrides. |
| `go_router` | Declarative routing supporting nested shell routes, desktop sidebar, and deep links. |
| `drift` & `sqlite3` | Type-safe, reactive, high-performance local SQLite database and DAOs. |
| `path_provider` & `path` | Cross-platform local database directory resolution. |
| `ffi` & `win32` | Native Win32 API access for Windows foreground and idle tracking. |
| `supabase_flutter` | Authentication and cross-device sync engine with Row Level Security. |
| `intl` | Date formatting, locale-aware number formatting, and weekday labels. |
| `very_good_analysis` | Enterprise-grade linting and static analysis rules to enforce code hygiene. |

