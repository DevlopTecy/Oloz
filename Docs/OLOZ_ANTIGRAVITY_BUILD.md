# Oloz — Antigravity Build Brief

You are building **Oloz** end to end: UI, tracking logic, local database, limits engine, sync backend, tests. Work autonomously through the phases in order. Do not stop after scaffolding. At the end of each phase run the checks listed for it and fix failures before moving on.

---

## 0. Read first
Before writing code, read these (they are in `/docs`):
1. `/docs/stitch/` — exported Stitch project. Each screen folder has `code.html` (layout, spacing, tokens) and `screen.png` (visual truth). `calm_digital_wellbeing/DESIGN.md` is the design system.
2. `/docs/OLOZ_STITCH_FIX_SCRIPT.md` — **the fixes override the Stitch export**. Where the export and the script disagree, follow the script.
3. This file.

If a screen in the export has a known bug (listed in the fix script), implement the fixed version, not the buggy one.

---

## 1. Product
Oloz shows how long you spend in each app and counts how many short-form videos (reels, shorts, TikToks) you scroll.

- **Mobile (primary): Android.** Per-app screen time + live reel counter for Instagram, YouTube (Shorts), TikTok, Facebook.
- **PC: Windows.** Per-app screen time (foreground window tracking). Reel counting on PC is out of scope for v1 (see §14).
- **iOS: not supported in v1.** iOS has no API to count reels. Do not fake it.
- Local-first and private. Data never leaves the device unless the user signs in and turns on sync. Even then only **daily aggregates** sync, never content, never window titles, never URLs.
- Tone: calm, non-shaming. No guilt copy.

---

## 2. Stack (decided — do not substitute)

| Layer | Choice |
|---|---|
| UI (Android + Windows) | **Flutter 3.x**, Dart, Material 3 as base but fully custom theme |
| State | **Riverpod** (`flutter_riverpod`, `riverpod_generator`) |
| Navigation | **go_router** |
| Local DB | **drift** (SQLite) with migrations |
| Charts | **fl_chart** (custom-styled to match design) |
| Android native | **Kotlin**: `UsageStatsManager`, `AccessibilityService`, foreground service, `WorkManager`, boot receiver |
| Windows native | Dart FFI via `win32` package: `GetForegroundWindow`, `GetWindowThreadProcessId`, idle time via `GetLastInputInfo`; tray via `tray_manager`, window via `window_manager` |
| Bridge | Flutter `MethodChannel` + `EventChannel` (Android) |
| Backend (optional sync) | **Supabase**: Auth (email OTP + Google), Postgres with Row Level Security, Edge Function for limit-sync not required |
| Tests | `flutter_test`, `mocktail`, `integration_test`, Kotlin unit tests (JUnit) for detector logic, `golden_toolkit` for goldens |
| Lint | `very_good_analysis` |

Min Android SDK 26, target latest stable. Windows 10 1809+.

---

## 3. Repo layout
```
oloz/
  docs/                      # stitch export, fix script, this file
  lib/
    main.dart
    app/                     # router, theme, app shell
    core/
      theme/                 # tokens, ThemeData light+dark, text styles
      widgets/               # StatCard, AppRow, WeekBars, Ring, SegmentedPill, PrimaryButton, ...
      utils/                 # duration formatting, date helpers
    data/
      db/                    # drift tables, DAOs, migrations
      repositories/          # UsageRepository, ReelRepository, LimitRepository, SettingsRepository, SyncRepository
      platform/              # TrackerService interface + android/windows implementations
      remote/                # supabase client, DTOs
    domain/                  # models, use cases (pure Dart)
    features/
      onboarding/
      home/
      reels/
      apps/
      app_detail/
      limits/                # set limit sheet, over-limit alert
      settings/
  android/app/src/main/kotlin/.../
    tracking/
      UsageCollector.kt
      OlozAccessibilityService.kt
      ReelDetector.kt
      ReelDetectorConfig.kt
      TrackingForegroundService.kt
      BootReceiver.kt
      LimitEnforcer.kt
      OverlayCounterService.kt   # live pill (Phase 7)
    channel/PlatformBridge.kt
  android/app/src/main/assets/reel_detectors.json
  windows/                   # runner + tray
  supabase/
    migrations/0001_init.sql
    seed.sql
  test/ integration_test/ 
```

---

## 4. Design system → code

Implement as `core/theme/oloz_tokens.dart` and `oloz_theme.dart`. Light and dark. Use `ThemeExtension<OlozColors>` so widgets read tokens, never hex literals.

### Light
| Token | Hex |
|---|---|
| bg | `#F6F5F2` |
| surface | `#FFFFFF` |
| surfaceMuted | `#EEEDE9` |
| border | `#E4E2DC` |
| text | `#23262B` |
| textSecondary | `#6E727A` |
| primary (filled buttons, active text) | `#5870C2` |
| chart (bars, rings, progress) | `#6B83D6` |
| primarySoft | `#E3E8F8` |
| reel (peach) | `#F0A98E` |
| reelSoft | `#FBE9E1` |
| onReelSoft (text only) | `#79452F` |
| success / warning / danger | `#7FB69A` / `#E6C27A` / `#D98A8A` |

### Dark
bg `#14161A`, surface `#1C1F25`, surfaceMuted `#262A32`, border `#2E323B`, text `#ECEDEF`, textSecondary `#9AA0AA`, chart/primary `#8FA3E8`, reel `#F2B49B`.

### Rules
- Only two chromatic colors per screen: indigo (time) and peach (reels). **No brown fills.**
- Inter font bundled in assets (do not fetch at runtime — app must work offline).
- Sizes: Display 40/600, Title 22/600, Section 16/600, Body 14/400, Caption 12/500. Tabular figures on all numbers (`FontFeature.tabularFigures()`). Units (h, m, reels) at 55% size in textSecondary.
- Radius: cards 20, buttons/inputs 14, app icon 12, chips full. Spacing scale 4/8/12/16/24/32/48. Screen padding 20 mobile, 32 desktop.
- Shadow: `0 4px 20px rgba(35,38,43,.05)` + 1px border. No heavy shadows.
- Sentence case everywhere. No uppercase labels.
- Motion: 200–250 ms ease-out, numbers count up once, bars grow from zero. Respect `MediaQuery.disableAnimations`.
- Accessibility: text contrast ≥ 4.5:1, touch targets ≥ 48 dp, semantic labels on charts (e.g. "Friday 5 hours 7 minutes").

### Widgets to build once, reuse everywhere
`StatCard`, `DeltaChip`, `SegmentedPill`, `WeekBars` (7 bars, today last), `ThirtyDayBars`, `Ring` (peach or indigo), `AppRow` (icon, name, time, thin progress), `PlatformBar`, `OlozToggle`, `DurationStepper`, `PresetPills`, `BottomSheetScaffold`, `OlozNavBar` (mobile bottom, 4 tabs), `OlozSidebar` (desktop 240 → 72 collapsible), `AppIconTile`, `EmptyState`.

Responsive: `<720 dp` = mobile layout with bottom nav; `≥720 dp` = sidebar layout, content max width 1200.

---

## 5. Screens → routes

| Route | Screen | Source |
|---|---|---|
| `/onboarding/welcome` `/permission` `/goal` | Onboarding 1–3 | stitch `onboarding_*` |
| `/home` | Home | `home`, `desktop_home` |
| `/reels` | Reels | `reels`, `desktop_reels` |
| `/apps` | Apps list | `apps`, `desktop_apps` |
| `/apps/:package` | App detail (desktop: right panel) | `app_detail_instagram` |
| `/apps/:package/limit` | Set limit bottom sheet | `set_limit_instagram` |
| `/alert/:package` | Over-limit alert (full screen, no nav) | `over_limit_alert` |
| `/settings` | Settings | `settings` |
| (new) | Live reel counter pill | fix script §4A |
| (new) | Empty state | fix script §4D |
| (new) | Desktop settings | fix script §4C |

Show onboarding once (`settings.onboarded`). Redirect to permission screen if usage access is revoked.

---

## 6. Data model (drift / SQLite)

All timestamps stored as UTC epoch ms. "Day" = local calendar day, stored as `yyyy-MM-dd` string computed at write time with the device time zone.

```sql
-- Installed/tracked apps
CREATE TABLE apps (
  package TEXT PRIMARY KEY,         -- Android package or Windows exe name
  label TEXT NOT NULL,
  platform TEXT NOT NULL,           -- 'android' | 'windows'
  category TEXT NOT NULL,           -- 'social' | 'video' | 'browsing' | 'messaging' | 'utility' | 'other'
  is_short_video INTEGER NOT NULL DEFAULT 0,
  tracked INTEGER NOT NULL DEFAULT 1
);

-- One row per foreground session
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  package TEXT NOT NULL REFERENCES apps(package),
  device_id TEXT NOT NULL,
  start_ms INTEGER NOT NULL,
  end_ms INTEGER NOT NULL,
  day TEXT NOT NULL
);
CREATE INDEX idx_sessions_day ON sessions(day, package);

-- One row per reel viewed
CREATE TABLE reel_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  package TEXT NOT NULL,
  device_id TEXT NOT NULL,
  at_ms INTEGER NOT NULL,
  dwell_ms INTEGER NOT NULL,        -- time on the previous reel
  day TEXT NOT NULL
);
CREATE INDEX idx_reels_day ON reel_events(day, package);

-- Rollup, rebuilt nightly and incrementally
CREATE TABLE daily_totals (
  day TEXT NOT NULL,
  package TEXT NOT NULL,
  device_id TEXT NOT NULL,
  foreground_ms INTEGER NOT NULL DEFAULT 0,
  opens INTEGER NOT NULL DEFAULT 0,
  reels INTEGER NOT NULL DEFAULT 0,
  synced_at INTEGER,
  PRIMARY KEY (day, package, device_id)
);

CREATE TABLE limits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  scope TEXT NOT NULL,              -- 'app' | 'total' | 'reels_total'
  package TEXT,                     -- null unless scope='app'
  daily_limit_ms INTEGER,           -- for app/total
  daily_limit_reels INTEGER,        -- for reels_total
  remind INTEGER NOT NULL DEFAULT 1,
  snooze_until_ms INTEGER
);

CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- keys: onboarded, theme(light|dark|auto), notifications, reminder_interval_min,
--       device_id, device_label, sync_enabled, last_sync_ms
```

Seed defaults at first launch: total limit 6h, reels goal 350, reminder interval 15 min.

Repositories expose `Stream`s (drift `watch()`), so UI updates live.

**Aggregations needed** (write as DAO queries with tests): total time for day/week/month, per-app time for range, reels per platform for range, last 7 days series ending today, last 30 days series, delta vs previous period, top N apps.

---

## 7. Android tracking logic (the core)

### 7.1 Permissions and onboarding
- `PACKAGE_USAGE_STATS` (special access) → deep link to `Settings.ACTION_USAGE_ACCESS_SETTINGS`.
- Accessibility service enable → deep link to `Settings.ACTION_ACCESSIBILITY_SETTINGS`. Show a **prominent in-app disclosure screen first** explaining exactly what is read (view scroll events in four apps, no text content), required by Play policy.
- `POST_NOTIFICATIONS` (Android 13+), `FOREGROUND_SERVICE`, `RECEIVE_BOOT_COMPLETED`.
- Optional: `SYSTEM_ALERT_WINDOW` only for the live pill (Phase 7), request lazily.
- Re-check permissions on every app resume; update Settings > Permissions row state.

### 7.2 Screen time (UsageCollector)
- Use `UsageStatsManager.queryEvents()` and rebuild sessions from `ACTIVITY_RESUMED` / `ACTIVITY_PAUSED` (or `MOVE_TO_FOREGROUND` / `MOVE_TO_BACKGROUND`) pairs. Do **not** use `queryUsageStats` aggregates (they are bucketed and inaccurate).
- Close a session at screen-off (`ACTION_SCREEN_OFF` receiver) and at device lock.
- Cap an open session at last-known event if the service dies (never extrapolate beyond now).
- Count `opens` = number of foreground transitions into the app.
- Write sessions to `sessions`, update `daily_totals` incrementally.
- Run: `TrackingForegroundService` (persistent low-priority notification "Oloz is running", user can hide channel) + `WorkManager` periodic job (15 min) to backfill from `queryEvents` since `last_collected_ms` so nothing is lost if the service is killed.
- Handle midnight rollover and time zone changes (`ACTION_TIMEZONE_CHANGED`, `ACTION_DATE_CHANGED`): split sessions at local midnight.
- Exclude: Oloz itself, launcher, system UI, and any package the user untracked.

### 7.3 Reel counting (ReelDetector)
`OlozAccessibilityService` listens only to these packages (`android:packageNames` in the service config; do not listen globally):

| App | Package |
|---|---|
| Instagram | `com.instagram.android` |
| YouTube | `com.google.android.youtube` |
| TikTok | `com.zhiliaoapp.musically` and `com.ss.android.ugc.trill` |
| Facebook | `com.facebook.katana` |

Event types: `TYPE_WINDOW_CONTENT_CHANGED`, `TYPE_VIEW_SCROLLED`, `TYPE_WINDOW_STATE_CHANGED`. Flags: `flagReportViewIds`. Never read `event.text` or node text. `canRetrieveWindowContent` true only if needed for view-id inspection.

**Detection is configuration-driven**, because app UIs change often. Put rules in `assets/reel_detectors.json`:
```json
{
  "version": 1,
  "apps": {
    "com.instagram.android": {
      "label": "Instagram",
      "surfaceMarkers": ["clips_viewer", "clips_swipe_refresh_container"],
      "pagerClassHints": ["ViewPager2", "RecyclerView"]
    },
    "com.google.android.youtube": {
      "label": "YouTube Shorts",
      "surfaceMarkers": ["reel_player_page_container", "shorts"],
      "pagerClassHints": ["RecyclerView", "ViewPager"]
    },
    "com.zhiliaoapp.musically": { "label": "TikTok", "surfaceMarkers": ["viewpager"], "pagerClassHints": ["ViewPager"] },
    "com.facebook.katana": { "label": "Facebook Reels", "surfaceMarkers": ["reels", "video_home"], "pagerClassHints": ["RecyclerView"] }
  },
  "timing": { "minDwellMs": 700, "debounceMs": 500 }
}
```
> **Important:** the view IDs and markers above are starting hypotheses, not verified. Build a **debug screen** (`/settings/debug`, debug builds only) that logs live accessibility events (package, class, viewId, event type) so the markers can be verified on a real device, then update the JSON. Do not claim reel counting works until it has been verified on a physical device for each app.

**Algorithm (per app):**
1. A "reel surface" is active when the focused window's node tree (or event source/ancestors) contains a view id matching `surfaceMarkers`, or the window class matches known reel activities. Re-evaluate on `WINDOW_STATE_CHANGED` and every 1 s while events flow.
2. While the surface is active, a **page change** is a `TYPE_VIEW_SCROLLED` on a pager-like class (`pagerClassHints`) followed by content change settling for `debounceMs`.
3. On a page change: if the previous reel was visible ≥ `minDwellMs`, increment the reel counter, record `dwell_ms`, insert into `reel_events`, and emit to Flutter via `EventChannel`.
4. Fast flicks: if multiple pages pass in < `minDwellMs` each, count 1 per settled page, not per event.
5. Leaving the surface (back, home, app switch) ends the current reel; the first reel on entering counts once it has dwelled ≥ `minDwellMs`.
6. Dedup: ignore events within `debounceMs` of the last counted reel; ignore replays caused by orientation or pull-to-refresh (scroll back to index 0 without dwell).
7. A **fallback heuristic** when no marker matches (UI changed): in these four packages, treat a vertical full-screen scroll (node bounds ≥ 90% of screen height) with a settle as a page change, flagged `confidence = low` so the UI can show "approx" in debug only.

Make `ReelDetector` a pure Kotlin class that takes an event model (not Android types) so it can be unit-tested with scripted event sequences. Required tests: single swipe, rapid triple flick, scroll-up-then-down, leave-and-return, pull-to-refresh, below-dwell ignore.

### 7.4 Limits engine (LimitEnforcer)
Runs inside the foreground service on each foreground change and every 30 s while an app is foreground.
- Compute today's app time (+ live session) and reels.
- Thresholds: **80%** → soft notification "Almost at your limit" (once per day per limit); **100%** → launch the full-screen alert `/alert/:package` (use a full-screen intent notification on Android 10+; fall back to a heads-up notification if the overlay/activity launch is blocked).
- Alert actions: "Take a break" → send the user to the device home screen and show a gentle reminder (no re-alert) if they reopen the app within 15 min; "5 more min" → `snooze_until = now + 5 min`, max 3 snoozes per limit per day.
- Reels limit applies across all four platforms (`reels_total`). Same 80% / 100% behavior, evaluated on every counted reel.
- Never hard-lock or block the app. Copy stays neutral ("Limit reached").
- Respect user setting "Notifications = off": no alerts, still track.
- Daily reset at local midnight.

### 7.5 Reliability
- Request ignoring battery optimization after onboarding (explain, one tap).
- Restart service in `BootReceiver` and on app update (`MY_PACKAGE_REPLACED`).
- If the accessibility service is killed by OEM, the WorkManager backfill still fixes screen time; reel counts for the gap are lost — show nothing misleading (no extrapolation).

---

## 8. Windows tracking logic

- Poll every 1 s (timer isolate): `GetForegroundWindow` → `GetWindowThreadProcessId` → `OpenProcess` + `QueryFullProcessImageName` → exe name. Map exe → friendly name and icon (extract with `SHGetFileInfo`, cache as PNG in app data).
- Idle detection: `GetLastInputInfo`; if idle > 120 s, pause the session (screen time = active time).
- Close sessions on lock/sleep (`WTS_SESSION_LOCK`, `WM_POWERBROADCAST` suspend).
- Same `sessions` and `daily_totals` tables, `platform = 'windows'`.
- Run in tray; start with Windows (toggle in settings via registry `Run` key); close button minimizes to tray.
- Do **not** read window titles into the DB. Titles can hold private content; use only exe name.
- Limits: same engine in Dart (shared domain code), shown as a native Windows toast (`flutter_local_notifications` Windows support) and the in-app alert screen.
- Browser reels on PC: out of scope v1.

---

## 9. Sync backend (Supabase), optional

Sync is off until the user signs in and enables it in Settings > Devices.

### Schema (`supabase/migrations/0001_init.sql`)
```sql
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  device_key text not null,            -- the local device_id
  label text not null,                 -- 'This phone', 'Windows PC'
  platform text not null check (platform in ('android','windows')),
  last_seen timestamptz not null default now(),
  unique (user_id, device_key)
);

create table public.daily_totals (
  user_id uuid not null references auth.users on delete cascade,
  device_key text not null,
  day date not null,
  package text not null,
  label text not null,
  category text not null,
  foreground_ms bigint not null default 0,
  opens int not null default 0,
  reels int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, device_key, day, package)
);

create table public.user_settings (
  user_id uuid primary key references auth.users on delete cascade,
  daily_limit_ms bigint,
  reels_goal int,
  per_app_limits jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.devices enable row level security;
alter table public.daily_totals enable row level security;
alter table public.user_settings enable row level security;

create policy "own rows" on public.devices        for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on public.daily_totals   for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on public.user_settings  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

### Sync rules
- Upload: every 15 min and on app background, only `daily_totals` rows with `synced_at IS NULL OR updated since synced_at`. Upsert by primary key. Batch ≤ 500 rows.
- Download: pull other devices' rows for the last 35 days, store in a local `remote_daily_totals` table (read-only), merged in repositories so the Home/Apps screens can show "All / Phone / PC" views.
- Settings (limits, goal): last-write-wins on `updated_at`.
- Offline-safe: queue and retry with exponential backoff. Never block the UI on network.
- "Delete my cloud data" button (Settings) calls delete on all three tables for the user and signs out.
- Keys: read `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `--dart-define` / `.env` (gitignored). Never commit keys. Provide `.env.example`.

---

## 10. State and data flow
```
Platform trackers → drift tables → repositories (Streams) → Riverpod providers → widgets
                                        ↑
                          LimitEnforcer reads same repositories
```
- `TrackerService` interface: `start()`, `stop()`, `Stream<ReelEvent> reelEvents`, `permissionState`, implemented by `AndroidTracker` (channels) and `WindowsTracker` (FFI).
- Providers: `rangeProvider` (Day/Week/Month), `totalTimeProvider(range)`, `reelsProvider(range)`, `appsProvider(range, deviceFilter)`, `weekSeriesProvider`, `platformSplitProvider`, `limitsProvider`, `settingsProvider`.
- All domain logic in pure Dart under `domain/` (aggregation, delta, limit evaluation, formatting) with unit tests.

Formatting rules: `5h 07m`, `45m`, `0m`; reels `286`; delta chips `−14%` (down is shown green/calm, up is neutral, never red).

---

## 11. Build phases and acceptance criteria

Complete one phase fully before the next. After each phase run `flutter analyze`, `flutter test`, and the phase checks.

**Phase 1 — Foundation**
- Project scaffold, lints, CI-ready scripts, Inter font, tokens, light/dark theme, responsive shell (bottom nav / sidebar), router.
- All reusable widgets with a `/gallery` debug route and golden tests for each (light + dark).
- ✅ Done when: gallery renders every widget; goldens pass; no hex literals outside `oloz_tokens.dart`.

**Phase 2 — Database and domain**
- drift schema, migrations, DAOs, repositories, aggregation use cases, seed defaults.
- Fake data generator (debug only) producing 35 days of plausible sessions and reels.
- ✅ Done when: unit tests cover every aggregation in §6 including midnight splits and week boundaries; fake data flag fills the DB.

**Phase 3 — Screens on fake data**
- Build every screen in §5 from the Stitch export + fix script, wired to repositories. Mobile and desktop layouts. Light + dark. Empty state. Onboarding flow.
- ✅ Done when: each screen visually matches its `screen.png` (with fixes) at 390×844 and 1440×900; goldens for every screen in light + dark; no overflow errors at 320 dp width; Day/Week/Month switching updates all numbers.

**Phase 4 — Android tracking**
- Permissions flow, UsageCollector, foreground service, WorkManager backfill, boot receiver, bridge to Flutter.
- ✅ Done when (on a physical device or emulator with usage access granted): opening 3 apps for known durations produces totals within ±5 s of reality; killing the service and relaunching backfills; midnight split verified with a manual clock change.

**Phase 5 — Reel counting**
- Accessibility service, ReelDetector, config JSON, debug event logger screen, EventChannel to UI.
- ✅ Done when: Kotlin unit tests for all scripted sequences pass; **manually verified on a physical device** for each of the four apps by scrolling 20 reels and comparing the count (±2 accepted); results recorded in `docs/reel-verification.md` with app versions. Update JSON markers accordingly. If an app cannot be made reliable, mark it "experimental" in code and docs rather than hiding the problem.

**Phase 6 — Limits and alerts**
- LimitEnforcer, notifications, alert screen, snooze logic, Set limit sheet persistence, goal persistence from onboarding.
- ✅ Done when: setting a 2-minute test limit triggers the 80% and 100% behaviors once each; snooze works up to 3 times; nothing triggers when notifications are off; reels limit triggers on the Nth reel.

**Phase 7 — Live reel counter pill (Android)**
- `OverlayCounterService` with `TYPE_APPLICATION_OVERLAY`: collapsed pill (dot + count), tap to expand (count + session time + pause). Only visible while a reel surface is active. Toggle in Settings.
- ✅ Done when: pill appears/disappears with the reel surface, never blocks touches outside its bounds, survives rotation, and can be dragged vertically.

**Phase 8 — Windows tracker**
- Foreground polling, idle pause, tray, autostart, notifications, icon extraction.
- ✅ Done when: a 10-minute manual session across 3 apps matches within ±5 s; idle for 3 minutes is excluded; app minimizes to tray and keeps tracking; startup toggle works.

**Phase 9 — Sync**
- Supabase migrations, auth, upload/download, device list in Settings, "All / Phone / PC" filters, delete cloud data.
- ✅ Done when: two devices (or two emulated device ids) show merged totals; RLS verified (second user cannot read first user's rows — write an SQL test); offline edits sync after reconnect.

**Phase 10 — Polish and release**
- Performance (no jank on lists with 100+ apps, DB queries off the UI thread), accessibility pass (TalkBack labels, font scale 1.3), animations, app icon + adaptive icon, splash, Play-store-ready privacy policy page text, release builds (`appbundle`, `windows` MSIX).
- ✅ Done when: see §13.

---

## 12. Testing requirements
- Unit tests: aggregations, formatting, limit evaluation, sync merge, ReelDetector sequences.
- Widget/golden tests: every shared widget and every screen, light + dark, mobile + desktop.
- Integration test: onboarding → grant (mocked) → home shows data → set limit → alert appears.
- No test may depend on wall-clock time; inject a `Clock`.
- Keep `flutter analyze` at zero issues. Add a `make check` (or `scripts/check.sh`) that runs analyze + tests.

---

## 13. Definition of done
- [ ] Every screen in §5 implemented, matches Stitch export with the fix script applied, light + dark, mobile + desktop where specified.
- [ ] Numbers on every screen come from the DB, no hardcoded demo data outside the debug generator.
- [ ] Android: screen time accurate, reels counted for Instagram, YouTube, TikTok, Facebook (or marked experimental with notes), limits and alerts working.
- [ ] Windows: screen time accurate with idle pause, tray, autostart.
- [ ] Sync works end to end and is off by default; RLS tested.
- [ ] Works fully offline; no network calls unless sync is on.
- [ ] No window titles, URLs, message text or video content ever stored or sent.
- [ ] `flutter analyze` clean; all tests pass; goldens updated.
- [ ] README with setup, env, build, and permission instructions; `docs/reel-verification.md` filled in.

---

## 14. Known limits (be honest in the UI and docs)
- iOS cannot count reels; iOS support is out of scope.
- Reel counting depends on each app's internal UI and can break when Instagram, YouTube, TikTok or Facebook update. Detectors are config-driven so markers can be updated without a code rewrite. Consider shipping `reel_detectors.json` updates through a signed remote config later (not in v1).
- Google Play restricts AccessibilityService use. Requires the prominent disclosure (§7.1), a Play Console declaration, and a demo video. If review is a concern, offer a "sideload / direct APK" distribution path alongside Play.
- OEM battery managers (Xiaomi, Oppo, Vivo, Samsung) may kill the service; the onboarding battery step and the backfill job mitigate this.
- Windows reel counting would need a browser extension; leave a documented extension point (`ReelSource` interface) but do not build it in v1.

---

## 15. Working rules for you (the agent)
- Prefer small, reviewable commits per phase; message format `phase-N: summary`.
- Do not invent verified claims. If a step needs a physical device you do not have, implement it, write the manual test steps in `docs/manual-tests.md`, and mark that item as "needs device verification" in your final report.
- Do not add dependencies beyond §2 without a one-line justification in `docs/decisions.md`.
- Never hardcode secrets. Never log personal data.
- When the Stitch export and these rules conflict, these rules and the fix script win.
- At the end, produce `docs/FINAL_REPORT.md`: what is done, what is verified on-device, what is not, and known issues.
