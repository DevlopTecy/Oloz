# Privacy Policy for Oloz

**Last Updated:** November 2026

Oloz ("we", "our", or "the app") is a calm, privacy-first digital wellbeing application designed to help individuals monitor their screen time and short-form video consumption (such as reels, shorts, and TikToks). 

We believe that your digital wellbeing data is personal. Our core principle is simple: **we collect only the minimum aggregated metrics necessary to help you understand your habits, and we never collect, read, or transmit your private content.**

---

## 1. What We Track

### A. Screen Time & App Usage
- **Application Identifiers**: We monitor which application is currently in the foreground (e.g., package names on Android like `com.instagram.android`, or process executable names on Windows like `chrome.exe`).
- **Session Duration**: We record session start time, end time, and active duration.
- **Device Platform**: We tag records with the device type ("Phone" or "PC") to present unified or separated views.

### B. Short-Form Video (Reels) Counting
- On Android, using an optional Accessibility Service, Oloz detects scroll events within short-form video feeds (specifically Instagram Reels, YouTube Shorts, TikTok, and Facebook Reels) to calculate how many short-form clips you scroll through.

---

## 2. What We NEVER Track, Read, or Store

To ensure total privacy:
- ❌ **No Window Titles**: We never read or record browser tab titles or document titles on Windows or Android.
- ❌ **No URLs or Web Content**: We never inspect which websites you visit or what content you view.
- ❌ **No Text, Messages, or Keystrokes**: Our accessibility detector strictly inspects non-content layout container view IDs and scroll gestures. It does not inspect text fields, input, comments, or direct messages.
- ❌ **No Video or Media Content**: We never capture screenshots, video frames, camera inputs, or audio.
- ❌ **No Location Data**: We do not access GPS, Wi-Fi location, or cell tower data.
- ❌ **No Advertising IDs or Tracking Across Apps**: We do not sell data to data brokers or advertising networks.

---

## 3. How Android Permissions Are Used

### A. Usage Access (`PACKAGE_USAGE_STATS`)
- **Purpose**: Required on Android to identify which app is currently open and calculate active screen time duration.
- **Handling**: Queried locally on your device by `UsageStatsManager`. Data is processed in local database tables and never leaves your device unless you enable cloud sync.

### B. Accessibility Service (`AccessibilityService`)
- **Purpose**: Required to detect scroll events in short-form video surfaces (Instagram, YouTube Shorts, TikTok, Facebook Reels) so you can track how many reels you watch.
- **Prominent Disclosure**: 
  > *"Oloz uses the Android Accessibility Service strictly to count short-form video scrolls (Reels, Shorts, TikToks). We detect scroll gestures and surface layout IDs only. We NEVER inspect, read, log, or transmit personal text, keystrokes, messages, passwords, payment info, screen contents, or web URLs."*
- **Handling**: Events are processed purely in real-time in memory to increment a local scroll count. The accessibility service is strictly scoped to the 4 supported apps and does not run globally across your device.

### C. Display Over Other Apps (`SYSTEM_ALERT_WINDOW`)
- **Purpose**: Used for the optional floating reel counter pill, which shows your live count while scrolling, and for the full-screen limit alert when your daily limit is reached.
- **Handling**: Strictly used to render UI overlays.

---

## 4. Offline First & Cloud Synchronization

- **Offline Default**: Oloz operates 100% offline by default. All data is stored in a local SQLite/Drift database on your device.
- **Optional Cloud Sync**: If you choose to enable cross-device sync with Supabase:
  - Only **daily aggregates** (e.g. date, total minutes, total reels, per-app daily duration, device type) are uploaded.
  - Raw second-by-second sessions and individual reel timestamps are **never** uploaded to the cloud.
  - All data is protected with Row Level Security (RLS) tied to your private authenticated account (`auth.uid()`).
  - You can permanently purge all cloud data at any time via **Settings → Delete my cloud data**.

---

## 5. Data Retention & Deletion

- **Local Data**: Stored on your device until you clear app data, uninstall the app, or tap **Clear data** in Settings.
- **Cloud Data**: Automatically purged when you trigger "Delete cloud data" or delete your account.

---

## 6. Children's Privacy

Oloz does not knowingly collect personally identifiable information from children under the age of 13.

---

## 7. Contact & Inquiries

For questions or feedback regarding this Privacy Policy:
- **Email**: privacy@oloz.app
- **Repository**: https://github.com/oloz/oloz
