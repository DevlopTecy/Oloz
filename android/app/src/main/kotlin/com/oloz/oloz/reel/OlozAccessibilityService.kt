package com.oloz.oloz.reel

import android.accessibilityservice.AccessibilityService
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.graphics.Rect
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.oloz.oloz.tracking.TrackingBridge
import com.oloz.oloz.tracking.TrackingForegroundService
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
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

        // Filter out non-target apps and reset state if left video apps
        val trackedApps = setOf(
            "com.instagram.android",
            "com.google.android.youtube",
            "com.zhiliaoapp.musically",
            "com.ss.android.ugc.trill",
            "com.facebook.katana"
        )
        if (!trackedApps.contains(pkg)) {
            detector.reset(pkg)
            return
        }

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
                if (rect.height() >= (displayHeight * 0.80)) {
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

        // Early reject comment sheets, dialogs, drawers
        val lowerId = (viewId ?: "").lowercase()
        if (lowerId.contains("comment") ||
            lowerId.contains("reply") ||
            lowerId.contains("composer") ||
            lowerId.contains("sheet") ||
            lowerId.contains("dialog") ||
            lowerId.contains("thread") ||
            lowerId.contains("bottom_sheet") ||
            lowerId.contains("tray")) {
            return
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
            Log.d("OlozReel", "Detected reel in ${detected.packageId} (dwell: ${detected.dwellMs}ms)")
            recordReelInDb(detected.packageId, detected.dwellMs, detected.timestampMs)

            Handler(Looper.getMainLooper()).post {
                TrackingBridge.notifyReelDetected(
                    packageId = detected.packageId,
                    dwellMs = detected.dwellMs,
                    timestampMs = detected.timestampMs,
                    confidence = detected.confidence
                )
            }
        }
    }

    private fun recordReelInDb(packageId: String, dwellMs: Long, timestampMs: Long) {
        try {
            val dbFile = File(filesDir.parentFile, "app_flutter/oloz.sqlite")
            if (dbFile.exists()) {
                val db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
                val day = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date(timestampMs))

                // De-duplicate: ignore if another reel was recorded for this package within 1000ms
                val checkCursor = db.rawQuery(
                    "SELECT at_ms FROM reel_events WHERE package = ? ORDER BY id DESC LIMIT 1",
                    arrayOf(packageId)
                )
                var isDuplicate = false
                if (checkCursor.moveToFirst()) {
                    val lastAtMs = checkCursor.getLong(0)
                    if (timestampMs - lastAtMs < 1000L) {
                        isDuplicate = true
                    }
                }
                checkCursor.close()

                if (isDuplicate) {
                    db.close()
                    return
                }

                val cv = ContentValues().apply {
                    put("package", packageId)
                    put("device_id", "local_device")
                    put("at_ms", timestampMs)
                    put("dwell_ms", dwellMs)
                    put("day", day)
                }
                db.insert("reel_events", null, cv)

                // Query today's total reels
                val cursor = db.rawQuery("SELECT COUNT(*) FROM reel_events WHERE day = ?", arrayOf(day))
                var todayReels = 0
                if (cursor.moveToFirst()) {
                    todayReels = cursor.getInt(0)
                }
                cursor.close()
                db.close()

                Log.d("OlozReel", "Saved reel to SQLite. Today's total reels: $todayReels")

                // Update persistent background notification
                TrackingForegroundService.updateStats(
                    this,
                    todayReels,
                    TrackingForegroundService.currentMinutes
                )
            }
        } catch (e: Exception) {
            Log.e("OlozReel", "Failed to record reel into SQLite", e)
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

