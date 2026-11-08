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

    @Test
    fun testScrollingOnMainFeedNeverActivatesOrCountsReels() {
        var time = 60000L

        // User starts Instagram on Home feed
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "com.instagram.mainactivity.MainActivity",
                viewId = "feed_tab",
                timestampMs = time
            )
        )
        assertEquals(false, detector.isSurfaceActive("com.instagram.android"))

        // User scrolls 5 times on the main feed to see photo posts
        for (i in 1..5) {
            time += 1500L
            val result = detector.processEvent(
                AccessibilityEventModel(
                    packageName = "com.instagram.android",
                    eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                    className = "androidx.recyclerview.widget.RecyclerView",
                    viewId = "android:id/list",
                    timestampMs = time,
                    fromIndex = i * 2,
                    toIndex = i * 2 + 1
                )
            )
            assertNull("Scroll $i on main feed must not count as a reel", result)
        }
        assertEquals(false, detector.isSurfaceActive("com.instagram.android"))
    }

    @Test
    fun testHoldingAndSpammingBetweenReelsDoesNotSpamCount() {
        var time = 70000L

        // 1. Enter reels surface
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "com.instagram.modal.ModalActivity",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )

        // 2. User watches Reel 0 for 2000 ms
        time += 2000L

        // 3. User swipes to Reel 1
        val firstSwipe = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                className = "androidx.viewpager2.widget.ViewPager2",
                viewId = "clips_viewer",
                timestampMs = time,
                fromIndex = 0,
                toIndex = 1
            )
        )
        assertNotNull("First completed reel should be detected", firstSwipe)

        // 4. Now user holds finger between Reel 1 and 2, spamming small drags back and forth every 100ms
        for (i in 1..10) {
            time += 100L
            val spamResult = detector.processEvent(
                AccessibilityEventModel(
                    packageName = "com.instagram.android",
                    eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                    className = "androidx.viewpager2.widget.ViewPager2",
                    viewId = "clips_viewer",
                    timestampMs = time,
                    fromIndex = 1,
                    toIndex = if (i % 2 == 0) 1 else 2
                )
            )
            assertNull("Spam drag $i must not trigger a reel count", spamResult)
        }

        // 5. User settles on Reel 2 and watches for 1000 ms
        time += 1000L
        val settleEvent = detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_CONTENT_CHANGED,
                className = "android.view.ViewGroup",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )
        assertNotNull("Settled reel after spam should be counted exactly once", settleEvent)
    }

    @Test
    fun testCommentSectionScrollingIgnored() {
        var time = 80000L

        // 1. Enter reels surface
        detector.processEvent(
            AccessibilityEventModel(
                packageName = "com.instagram.android",
                eventType = ReelDetector.TYPE_WINDOW_STATE_CHANGED,
                className = "com.instagram.modal.ModalActivity",
                viewId = "clips_viewer",
                timestampMs = time
            )
        )

        // 2. Open comments sheet and scroll comments 4 times
        for (i in 1..4) {
            time += 1000L
            val commentScroll = detector.processEvent(
                AccessibilityEventModel(
                    packageName = "com.instagram.android",
                    eventType = ReelDetector.TYPE_VIEW_SCROLLED,
                    className = "androidx.recyclerview.widget.RecyclerView",
                    viewId = "com.instagram.android:id/layout_comment_thread",
                    timestampMs = time,
                    fromIndex = i,
                    toIndex = i + 1
                )
            )
            assertNull("Comment scroll $i must be ignored", commentScroll)
        }
    }
}
