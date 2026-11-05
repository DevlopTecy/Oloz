package com.oloz.oloz.reel

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.oloz.oloz.tracking.TrackingBridge
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.concurrent.ConcurrentLinkedQueue

class OlozAccessibilityService : AccessibilityService() {

    companion object {
        var isRunning: Boolean = false
            private set

        private const val MAX_DEBUG_EVENTS = 100
        private val debugEventsQueue = ConcurrentLinkedQueue<AccessibilityEventModel>()

        fun getDebugEvents(): List<AccessibilityEventModel> {
            return debugEventsQueue.toList()
        }

        fun clearDebugEvents() {
            debugEventsQueue.clear()
        }
    }

    private var reelDetector: ReelDetector? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        isRunning = true

        try {
            val jsonString = assets.open("reel_detectors.json").use { inputStream ->
                BufferedReader(InputStreamReader(inputStream)).readText()
            }
            val config = ReelDetectorsConfig.fromJson(jsonString)
            reelDetector = ReelDetector(config)
        } catch (_: Exception) {
            // Fallback default config
            val defaultConfig = ReelDetectorsConfig(
                version = 1,
                apps = mapOf(
                    "com.instagram.android" to ReelAppConfig("Instagram", listOf("clips_viewer"), listOf("ViewPager2", "RecyclerView")),
                    "com.google.android.youtube" to ReelAppConfig("YouTube Shorts", listOf("shorts"), listOf("RecyclerView")),
                    "com.zhiliaoapp.musically" to ReelAppConfig("TikTok", listOf("viewpager"), listOf("ViewPager")),
                    "com.facebook.katana" to ReelAppConfig("Facebook Reels", listOf("reels"), listOf("RecyclerView"))
                ),
                timing = ReelDetectorTiming(700L, 500L)
            )
            reelDetector = ReelDetector(defaultConfig)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val pkg = event.packageName?.toString() ?: return
        val detector = reelDetector ?: return

        // Extract viewId and check full-screen height bounds without reading text
        var viewId: String? = null
        var isFullScreen = false

        val source: AccessibilityNodeInfo? = try {
            event.source
        } catch (_: Exception) {
            null
        }

        if (source != null) {
            try {
                viewId = source.viewIdResourceName
                val rect = Rect()
                source.getBoundsInScreen(rect)
                val displayHeight = resources.displayMetrics.heightPixels
                if (rect.height() >= (displayHeight * 0.85)) {
                    isFullScreen = true
                }
            } catch (_: Exception) {
            } finally {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                    @Suppress("DEPRECATION")
                    source.recycle()
                }
            }
        }

        val eventModel = AccessibilityEventModel(
            packageName = pkg,
            eventType = event.eventType,
            className = event.className?.toString(),
            viewId = viewId,
            timestampMs = System.currentTimeMillis(),
            isFullScreenScroll = isFullScreen,
            fromIndex = event.fromIndex,
            toIndex = event.toIndex,
            itemCount = event.itemCount
        )

        // Store in debug circular buffer
        debugEventsQueue.offer(eventModel)
        while (debugEventsQueue.size > MAX_DEBUG_EVENTS) {
            debugEventsQueue.poll()
        }

        // Process through ReelDetector
        val detected = detector.processEvent(eventModel)
        if (detected != null) {
            TrackingBridge.notifyReelDetected(
                packageId = detected.packageId,
                dwellMs = detected.dwellMs,
                timestampMs = detected.timestampMs,
                confidence = detected.confidence
            )
        }
    }

    override fun onInterrupt() {
        reelDetector?.reset()
    }

    override fun onDestroy() {
        isRunning = false
        reelDetector?.reset()
        super.onDestroy()
    }
}

