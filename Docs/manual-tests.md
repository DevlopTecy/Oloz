# Manual Test Guide for Physical Devices & Desktops

This guide provides step-by-step verification procedures for manual on-device testing of Oloz on physical Android smartphones and Windows PCs.

---

## Part 1: Android Physical Device Testing

### Prerequisites
- Physical Android smartphone running Android 10+ (Android 13, 14, or 15 recommended).
- USB debugging enabled (`adb devices` confirms connected).
- Target apps installed: Instagram, YouTube, TikTok, Facebook.
- Build and install: `flutter run -d <device_id> --release` (or `flutter install`).

---

### Test Case A1: Permissions Flow & Prominent Disclosure
1. Launch Oloz on the device.
2. Verify the Welcome screen displays: "Know your scroll." with "Get started".
3. Tap **Get started** to advance to the Permission screen.
4. Verify the prominent disclosure clearly states:
   - What is collected (app foreground time, scroll gestures on reels).
   - What is NEVER collected (window titles, URLs, personal text, keystrokes, messages, passwords, screen content).
5. Tap **Allow access**. System settings for **Usage Access** should open. Toggle Oloz to **Permitted**.
6. Return to Oloz. Advance to **Accessibility settings**. Select **Oloz Reel Counter** and toggle **On**.
7. Confirm the system accessibility warning dialog.

**Expected Outcome:**
- Oloz detects permissions granted, advances to the Daily Goal screen, and then opens the Home screen.

---

### Test Case A2: 20-Reel Scroll Count Verification
1. Note the current reels count on Oloz Home screen (or reset via Settings -> Diagnostics -> Clear data).
2. Open **Instagram** and navigate to the Reels tab.
3. If overlay is enabled in Settings, verify the **Floating Counter Pill** appears on screen (44px glassmorphic pill with peach dot).
4. Watch 20 reels sequentially:
   - Dwell on each video for at least 1-2 seconds.
   - Swipe vertically to the next reel.
   - Intentionally perform one rapid double-swipe (flick) to verify consolidation.
5. Exit Instagram and return to Oloz.
6. Check the reels count on Oloz Home screen and Reels tab.

**Expected Outcome:**
- Count increments by 20 (acceptable variance: ±1 due to rapid flick consolidation).
- Instagram detail screen shows the 20 reels recorded today.

---

### Test Case A3: Limit Enforcement (80% Soft Notice & 100% Full-Screen Alert)
1. Open Oloz -> **Apps** -> **Instagram** -> tap **Set daily limit**.
2. Set a short test limit (e.g., 2 minutes).
3. Tap **Save limit**.
4. Open Instagram and keep it in the foreground:
   - At 1m 36s (80% elapsed): verify a silent, non-intrusive reminder notification arrives in the `oloz_reminders_channel` ("You've used 80% of your Instagram limit today").
   - At 2m 00s (100% elapsed): verify the high-priority full-screen alert triggers (`oloz://alert/com.instagram.android`).
5. On the Alert Screen, verify two action buttons:
   - **Take a break**: Tap this button. Verify Oloz sends the device to the launcher Home screen (`ACTION_MAIN` with `CATEGORY_HOME`).
   - **5 more min**: Re-trigger the alert, tap "5 more min". Verify the limit is snoozed by 5 minutes, allowing continued usage without immediate re-alerting (max 3 times/day).

---

### Test Case A4: Floating Reel Counter Pill Overlay
1. Ensure **Display over other apps** permission is granted.
2. In Oloz Settings, ensure "Floating reel counter" toggle is ON.
3. Open YouTube Shorts.
4. Verify the counter pill appears:
   - In collapsed state: peach dot + bold tabular count.
5. Tap the pill:
   - Expands smoothly to show session time (`12m`) and pause icon.
6. Touch and drag the pill along the screen edge:
   - Pill drags fluidly and snaps cleanly within safe screen bounds.
7. Switch away from YouTube Shorts to the home screen or Settings:
   - Pill automatically hides.

---

## Part 2: Windows PC Testing

### Prerequisites
- PC running Windows 10 or 11 (64-bit).
- Built via `flutter run -d windows` or `flutter build windows`.

---

### Test Case W1: Win32 Foreground Tracking Accuracy
1. Launch Oloz on Windows.
2. Note the initial screen time displayed on Home or Desktop Split View.
3. Open **Google Chrome** (`chrome.exe`) and browse actively for 3 minutes.
4. Switch to **Visual Studio Code** (`Code.exe`) and code actively for 2 minutes.
5. Return to Oloz.

**Expected Outcome:**
- Oloz accurately reflects ~3 minutes for Google Chrome (categorized under Browsing) and ~2 minutes for Visual Studio Code (categorized under Utility).
- Window titles and URLs are strictly NOT stored anywhere in the local database.

---

### Test Case W2: Idle Detection (> 120s Input Silence)
1. Open any application (e.g. Notepad or Chrome).
2. Leave mouse and keyboard completely untouched for 3 full minutes (180 seconds).
3. Resume typing or moving the mouse.
4. Check Oloz screen time for the period.

**Expected Outcome:**
- The 3-minute idle duration is NOT counted toward active screen time. The tracker pauses duration accumulation after 120 seconds of user input inactivity (`GetLastInputInfo`).

---

### Test Case W3: Minimize to System Tray
1. In Oloz Windows Settings -> Startup: toggle **Show in tray** ON.
2. Click the window minimize or close button.
3. Verify Oloz minimizes to the Windows taskbar system notification tray with the Oloz icon.
4. Verify tracking continues seamlessly in the background while minimized.
5. Double-click the tray icon to restore the window.

---

## Part 3: Offline & Sync Resilience Testing

1. Disconnect Wi-Fi / Ethernet on the device or PC.
2. Use the device for 5 minutes across multiple apps.
3. Verify Oloz records all local sessions and reel events in the local SQLite/Drift database with zero crashes, lag, or dropped frames.
4. Re-enable network connectivity.
5. In Settings -> Accounts, tap **Sync now**.
6. Verify daily totals upload cleanly in a single batch (<= 500 rows) with zero data loss.
