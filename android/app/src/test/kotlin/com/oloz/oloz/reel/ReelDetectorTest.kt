package com.oloz.oloz.reel

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

class ReelDetectorTest {

    private lateinit var detector: ReelDetector

    private val testConfig = ReelDetectorsConfig(
        version = 1,
        apps = mapOf(
            "com.instagram.android" to ReelAppConfig(
                label = "Instagram",
                surfaceMarkers = listOf("clips_viewer", "clips_swipe_refresh_container"),
                pagerClassHints = listOf("ViewPager2", "RecyclerView")
            ),
            "com.google.android.youtube" to ReelAppConfig(
                label = "YouTube Shorts",
                surfaceMarkers = listOf("reel_player_page_container", "shorts"),
                pagerClassHints = listOf("RecyclerView", "ViewPager")
            )
        ),
        timing = ReelDetectorTiming(minDwellMs = 700L, debounceMs = 500L)
    )

    @Before
    fun setUp() {
        detector = ReelDetector(testConfig)
    }

    @Test
    fun testSingleSwipeCountsOneReelWhenDwellExceeded() {
        var time = 10000L

        // 1. Enter surface
        val stateEvent = AccessibilityEventModel(
            packageName = "com.instagram.android",
            eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
            className = "com.instagram.modal.ModalActivity",
            viewId = "clips_viewer",
            timestampMs = time
        )
        val initial = detector.processEvent(stateEvent)
        assertNull("No reel on surface entry", initial)

        // 2. Dwell on reel for 1500 ms (>= 700 ms)
        time += 1500L

        // 3. User swipes to next reel
        val scrollEvent = AccessibilityEventModel(
            packageName = "com.instagram.android",
            eventType = ReelDetector.TYPE_VIEW_SCROLLED,
            className = "androidx.viewpager2.widget.ViewPager2",
            viewId = "clips_viewer",
            timestampMs = time,
            fromIndex = 1,
            toIndex = 2
        )
        val detected = detector.processEvent(scrollEvent)

        assertNotNull("Reel should be detected after 1500ms dwell and scroll", detected)
        assertEquals("com.instagram.android", detected?.packageId)
        assertEquals(1500L, detected?.dwellMs)
        assertEquals("high", detected?.confidence)
    }

    @Test
    fun testRapidTripleFlickCountsOnlyOneSettledReel() {
        var time = 20000L

        // Enter surface
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "com.instagram.modal.ModalActivity",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )

        // Flick 1 after only 200 ms (< 700ms dwell)
        time += 200L
        val flick1 = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.viewpager2.widget.ViewPager2",
                viewId = "clips_viewer",
                timestampMs = time,
                fromIndex = 1,
                toIndex = 2
            )
        )
        assertNull("Rapid flick 1 should not count immediately", flick1)

        // Flick 2 after another 200 ms
        time += 200L
        val flick2 = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.viewpager2.widget.ViewPager2",
                viewId = "clips_viewer",
                timestampMs = time,
                fromIndex = 2,
                toIndex = 3
            )
        )
        assertNull("Rapid flick 2 should not count immediately", flick2)

        // Flick 3 after another 200 ms
        time += 200L
        val flick3 = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.viewpager2.widget.ViewPager2",
                viewId = "clips_viewer",
                timestampMs = time,
                fromIndex = 3,
                toIndex = 4
            )
        )
        assertNull("Rapid flick 3 should not count immediately", flick3)

        // Now user settles on reel 4 for 800 ms (>= 700ms dwell & >= 500ms debounce)
        time += 800L
        val settleContent = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_CONTENT_CHANGED,
                className = "android.view.ViewGroup",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )

        assertNotNull("Settled page after rapid flick should count exactly 1 reel", settleContent)
        assertEquals(1400L, settleContent?.dwellMs)
    }

    @Test
    fun testScrollUpThenDownIsDeduped() {
        var time = 30000L

        // Enter surface
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.google.android.youtube",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "ShortsActivity",
                viewId = "shorts",
                timestampMs = time
            )
        )

        // Dwell 1000ms and scroll down to index 1
        time += 1000L
        val reel1 = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.google.android.youtube",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.recyclerview.widget.RecyclerView",
                viewId = "shorts",
                timestampMs = time,
                fromIndex = 0,
                toIndex = 1
            )
        )
        assertNotNull(reel1)

        // User immediately scrolls back up to index 0 after only 200 ms (< 500ms debounce & < 700ms dwell)
        time += 200L
        val reverseScroll = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.google.android.youtube",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.recyclerview.widget.RecyclerView",
                viewId = "shorts",
                timestampMs = time,
                fromIndex = 1,
                toIndex = 0
            )
        )
        assertNull("Immediate reverse scroll back should be deduped/ignored", reverseScroll)
    }

    @Test
    fun testLeaveAndReturnResetsState() {
        var time = 40000L

        // Enter reel surface
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "ClipsActivity",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )

        // Dwell 1200ms
        time += 1200L

        // User presses Home or switches to Main Feed Activity
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "com.instagram.mainactivity.MainActivity",
                viewId = "main_feed",
                timestampMs = time
            )
        )

        // Surface should be inactive now
        assertEquals(false, detector.isSurfaceActive("com.instagram.android"))

        // Scroll on main feed should NOT count as a reel
        time += 1000L
        val feedScroll = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.recyclerview.widget.RecyclerView",
                viewId = "main_feed_recycler",
                timestampMs = time
            )
        )
        assertNull("Scroll on main feed outside reels surface must not count", feedScroll)
    }

    @Test
    fun testBelowDwellIgnore() {
        var time = 50000L

        // Enter surface
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "ClipsActivity",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )

        // Swipe after only 300ms (< 700ms minDwellMs)
        time += 300L
        val fastScroll = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.viewpager2.widget.ViewPager2",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )
        assertNull("Below-dwell scroll must not count as completed reel", fastScroll)
    }
}

