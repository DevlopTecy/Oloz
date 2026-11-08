package com.oloz.oloz.tracking

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class TrackingBridge(
    private val context: Context,
    private val activityProvider: () -> Activity?
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.oloz.app/tracking"
        const val EVENT_CHANNEL = "com.oloz.app/tracking_events"
        private const val PREFS_NAME = "oloz_tracking_prefs"

        private var eventSink: EventChannel.EventSink? = null

        fun notifyUsageUpdated(sessions: List<AppSessionData>) {
            if (sessions.isEmpty()) return
            val sessionMaps = sessions.map { it.toMap() }
            val payload = mapOf(
                "type" to "USAGE_SYNC",
                "sessions" to sessionMaps,
                "timestamp" to System.currentTimeMillis()
            )
            eventSink?.success(payload)
        }

        fun notifyForegroundChanged(packageName: String, label: String, eventType: String) {
            val payload = mapOf(
                "type" to "FOREGROUND_CHANGE",
                "package" to packageName,
                "label" to label,
                "eventType" to eventType,
                "timestamp" to System.currentTimeMillis()
            )
            eventSink?.success(payload)
        }

        fun notifyReelDetected(packageId: String, dwellMs: Long, timestampMs: Long, confidence: String) {
            val payload = mapOf(
                "type" to "REEL_DETECTED",
                "package" to packageId,
                "dwellMs" to dwellMs,
                "timestampMs" to timestampMs,
                "confidence" to confidence
            )
            eventSink?.success(payload)
        }
    }

    private val usageCollector = UsageCollector(context)

    fun register(messenger: BinaryMessenger) {
        val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermissions" -> {
                val hasUsage = usageCollector.hasUsageStatsPermission()
                val hasAccessibility = isAccessibilityServiceEnabled()
                val hasOverlay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Settings.canDrawOverlays(context)
                } else {
                    true
                }
                val hasNotifications = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    NotificationManagerCompat.from(context).areNotificationsEnabled()
                } else {
                    true
                }

                result.success(
                    mapOf(
                        "usageStats" to hasUsage,
                        "accessibility" to hasAccessibility,
                        "overlay" to hasOverlay,
                        "notifications" to hasNotifications
                    )
                )
            }

            "requestUsageAccess" -> {
                val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    data = Uri.fromParts("package", context.packageName, null)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val act = activityProvider()
                if (act != null) {
                    act.startActivity(intent)
                } else {
                    context.startActivity(intent)
                }
                result.success(true)
            }

            "requestAccessibility" -> {
                val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val act = activityProvider()
                if (act != null) {
                    act.startActivity(intent)
                } else {
                    context.startActivity(intent)
                }
                result.success(true)
            }

            "requestOverlayPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:${context.packageName}")
                    ).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    val act = activityProvider()
                    if (act != null) {
                        act.startActivity(intent)
                    } else {
                        context.startActivity(intent)
                    }
                }
                result.success(true)
            }

            "startTrackingService" -> {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean("tracking_enabled", true).apply()

                UsageBackfillWorker.schedulePeriodic(context)

                val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                    action = TrackingForegroundService.ACTION_START
                }
                try {
                    ContextCompat.startForegroundService(context, serviceIntent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SERVICE_START_FAILED", e.message, null)
                }
            }

            "stopTrackingService" -> {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean("tracking_enabled", false).apply()

                UsageBackfillWorker.cancelPeriodic(context)

                val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                    action = TrackingForegroundService.ACTION_STOP
                }
                context.startService(serviceIntent)
                result.success(true)
            }

            "queryUsageForRange" -> {
                val startMs = (call.argument<Number>("startMs"))?.toLong() ?: getStartOfDayMs()
                val endMs = (call.argument<Number>("endMs"))?.toLong() ?: System.currentTimeMillis()

                val sessions = usageCollector.collectSessions(startMs, endMs)
                val appSummaries = usageCollector.summarizeSessions(sessions)

                result.success(
                    mapOf(
                        "sessions" to sessions.map { it.toMap() },
                        "apps" to appSummaries.map { it.toMap() }
                    )
                )
            }

            "getTrackingStatus" -> {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val enabled = prefs.getBoolean("tracking_enabled", true)
                result.success(
                    mapOf(
                        "isTracking" to enabled,
                        "isServiceRunning" to TrackingForegroundService.isRunning,
                        "isAccessibilityRunning" to com.oloz.oloz.reel.OlozAccessibilityService.isRunning
                    )
                )
            }

            "getDebugEvents" -> {
                val events = com.oloz.oloz.reel.OlozAccessibilityService.getDebugEvents()
                result.success(events.map { it.toMap() })
            }

            "clearDebugEvents" -> {
                com.oloz.oloz.reel.OlozAccessibilityService.clearDebugEvents()
                result.success(true)
            }

            "sendToDeviceHome" -> {
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(homeIntent)
                result.success(true)
            }

            "showOverlayCounter" -> {
                val count = (call.argument<Number>("count"))?.toInt() ?: 37
                val minutes = (call.argument<Number>("minutes"))?.toInt() ?: 12
                com.oloz.oloz.overlay.OverlayCounterService.show(context, count, minutes)
                result.success(true)
            }

            "hideOverlayCounter" -> {
                com.oloz.oloz.overlay.OverlayCounterService.hide(context)
                result.success(true)
            }

            "updateOverlayCount" -> {
                val count = (call.argument<Number>("count"))?.toInt() ?: 37
                val minutes = (call.argument<Number>("minutes"))?.toInt() ?: 12
                com.oloz.oloz.overlay.OverlayCounterService.update(context, count, minutes)
                result.success(true)
            }

            "isOverlayShowing" -> {
                result.success(com.oloz.oloz.overlay.OverlayCounterService.isShowing)
            }

            "getAppIcon" -> {
                val pkg = call.argument<String>("package") ?: ""
                val bytes = usageCollector.getAppIcon(pkg)
                result.success(bytes)
            }

            "updateTrackingNotification" -> {
                val reels = (call.argument<Number>("reels"))?.toInt() ?: 0
                val minutes = (call.argument<Number>("minutes"))?.toInt() ?: 0
                TrackingForegroundService.updateStats(context, reels, minutes)
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(context)) {
                    com.oloz.oloz.overlay.OverlayCounterService.show(context, reels, minutes)
                }
                result.success(true)
            }

            "getDeviceInfo" -> {
                result.success(
                    mapOf(
                        "model" to "${Build.MANUFACTURER.replaceFirstChar { it.uppercase() }} ${Build.MODEL}",
                        "androidVersion" to "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
                    )
                )
            }

            else -> result.notImplemented()
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedServiceName = "${context.packageName}/com.oloz.oloz.reel.OlozAccessibilityService"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        return enabledServices.split(":").any {
            it.equals(expectedServiceName, ignoreCase = true) ||
            it.contains(context.packageName)
        }
    }

    private fun getStartOfDayMs(): Long {
        return Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
