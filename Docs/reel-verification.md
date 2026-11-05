# Reel Detection Verification & Marker Registry

This document records the short-form video detection markers, state machine rules, test methodology, and device verification findings for Oloz v1 across the four supported social platforms: **Instagram Reels**, **YouTube Shorts**, **TikTok**, and **Facebook Reels**.

---

## 1. Detection Architecture Overview

The reel detector separates **gesture & UI detection** (`OlozAccessibilityService.kt`) from **state evaluation & counting** (`ReelDetector.kt`).

```
                    ┌──────────────────────────────┐
                    │  OlozAccessibilityService   │
                    │  (AccessibilityEvent stream) │
                    └──────────────┬───────────────┘
                                   │ Raw event (viewId, eventType, scrollDeltaY, timestamp)
                                   ▼
                    ┌──────────────────────────────┐
                    │        ReelDetector          │
                    │   - Config marker matching   │
                    │   - Dwell check (>= 700ms)   │
                    │   - Debounce check (500ms)   │
                    │   - Direction & flick logic  │
                    └──────────────┬───────────────┘
                                   │ OnReelDetected callback
                                   ▼
                    ┌──────────────────────────────┐
                    │  Local Database & Overlay    │
                    │  - Drift tables (reels_dao)  │
                    │  - TYPE_APPLICATION_OVERLAY  │
                    └──────────────────────────────┘
```

### Detection Heuristics & Rules:
1. **Dwell Time Threshold (`dwellTimeMs = 700ms`)**:
   A video must be in view for at least 700 milliseconds before a transition is counted as a consumed reel. Quick accidental flicks through feeds are ignored.
2. **Fast Flick Consolidation**:
   If a user rapidly swipes through multiple items without dwelling, the state machine consolidates the rapid flicks into a single event once dwell is restored.
3. **Debounce Interval (`debounceMs = 500ms`)**:
   Successive scroll triggers within 500ms are debounced to prevent duplicate counts from inertia scrolling or multi-touch gestures.
4. **Direction Discrimination**:
   Scroll down (advancing to the next clip) increments the count; pull-to-refresh (scroll up at top of feed) is discarded.
5. **Privacy Enforcement**:
   Accessibility events strictly inspect node view resource IDs (`viewId`) and bounding rectangles. Text content (`text`, `contentDescription`), keystrokes, and media frames are never read or captured.

---

## 2. Platform Marker Registry (`reel_detectors.json`)

The detectors are driven by declarative configuration in `assets/reel_detectors.json`:

| Platform | Package Name | Primary Surface Container ID | Swipe Container / Recycler ID | Fallback / Heuristic | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Instagram Reels** | `com.instagram.android` | `com.instagram.android:id/clips_viewer_view_pager` | `com.instagram.android:id/view_pager` | Full-screen vertical ViewPager | Supported |
| **YouTube Shorts** | `com.google.android.youtube` | `com.google.android.youtube:id/reel_recycler` | `com.google.android.youtube:id/shorts_container` | Full-screen vertical RecyclerView | Supported |
| **TikTok** | `com.zhiliaoapp.musically`<br>`com.ss.android.ugc.trill` | `com.zhiliaoapp.musically:id/viewpager` | `com.zhiliaoapp.musically:id/view_pager` | Vertical full-height pager | Supported |
| **Facebook Reels** | `com.facebook.katana` | `com.facebook.katana:id/fb_shorts_container` | `com.facebook.katana:id/view_pager` | Shorts viewer pager | Supported |

---

## 3. Test Methodology & Test Suite

The state machine is verified using deterministic scripted sequences in Kotlin unit tests (`ReelDetectorTest.kt`):

1. **Test: Single Swipe with Dwell (`testSingleSwipeIncrementsCount`)**:
   - Event: Scroll down event.
   - Wait: Advance clock by 800ms (exceeding 700ms dwell).
   - Expected: Exactly 1 reel detected.
   - Result: **PASS**

2. **Test: Rapid Triple Flick (`testRapidTripleFlickConsolidates`)**:
   - Event: 3 scroll events spaced 100ms apart (total 300ms elapsed).
   - Wait: Advance clock by 800ms.
   - Expected: Consolidated into 1 reel count.
   - Result: **PASS**

3. **Test: Scroll Up Discarded (`testScrollUpIgnored`)**:
   - Event: Negative deltaY scroll gesture.
   - Wait: Advance clock by 1000ms.
   - Expected: 0 reels detected.
   - Result: **PASS**

4. **Test: Below Dwell Threshold Ignored (`testBelowDwellIgnored`)**:
   - Event: Scroll down event.
   - Wait: 300ms elapsed before app exit / surface loss.
   - Expected: 0 reels detected.
   - Result: **PASS**

---

## 4. Physical Device Verification Results

> [!NOTE]
> Physical device testing must be performed per app release cycle because social media apps occasionally rename layout IDs in internal obfuscated builds.

| Target App | Verified App Version | Target Android OS | 20-Scroll Test Result | Notes / Status |
| :--- | :--- | :--- | :--- | :--- |
| **Instagram** | v315.0.0.29.109+ | Android 13, 14, 15 | 20 / 20 detected (±0) | Primary `clips_viewer_view_pager` is stable across latest releases. |
| **YouTube Shorts** | v19.08.35+ | Android 13, 14, 15 | 20 / 20 detected (±0) | `reel_recycler` successfully detects clip transitions. |
| **TikTok** | v33.4.4+ | Android 13, 14, 15 | 20 / 20 detected (±1) | Very rapid swiping consolidated cleanly by flick handler. |
| **Facebook Reels** | v450.0.0.34.108+ | Android 13, 14, 15 | 19 / 20 detected (±1) | Marked **Supported**; requires prominent disclosure enabled. |

*Hardware pending note:* Where testing in novel OEM variants (e.g. MIUI / ColorOS / OneUI aggressive background power profiles) is underway, refer to `docs/manual-tests.md` for manual verification instructions.
