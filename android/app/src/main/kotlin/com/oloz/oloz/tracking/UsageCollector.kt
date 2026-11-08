package com.oloz.oloz.tracking

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.os.Process
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.math.max
import kotlin.math.min

class UsageCollector(private val context: Context) {

    private val usageStatsManager: UsageStatsManager? =
        context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager

    private val packageManager: PackageManager = context.packageManager
    private val dayFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
        timeZone = TimeZone.getDefault()
    }

    /**
     * Checks if the app has PACKAGE_USAGE_STATS permission granted.
     */
    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * Rebuilds sessions from UsageEvents for a specific time range [startMs, endMs].
     */
    fun collectSessions(startMs: Long, endMs: Long): List<AppSessionData> {
        if (usageStatsManager == null || !hasUsageStatsPermission()) {
            return emptyList()
        }

        val launcherPackages = getLauncherPackages()
        val ignoredPackages = mutableSetOf(
            context.packageName,
            "com.android.systemui",
            "com.google.android.apps.nexuslauncher",
            "com.google.android.launcher",
            "com.android.launcher"
        ).apply { addAll(launcherPackages) }

        val events = usageStatsManager.queryEvents(startMs, endMs) ?: return emptyList()
        val event = UsageEvents.Event()

        val sessions = mutableListOf<AppSessionData>()
        var activePackage: String? = null
        var activeSessionStart: Long = 0L

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            val time = event.timeStamp

            // Filter out system UI, launcher, and Oloz itself
            if (ignoredPackages.contains(pkg)) {
                // If an ignored app comes into foreground, close any previously active app session
                if (activePackage != null) {
                    val finishTime = min(time, endMs)
                    if (finishTime > activeSessionStart) {
                        splitAndAddSessions(activePackage!!, activeSessionStart, finishTime, sessions)
                    }
                    activePackage = null
                }
                continue
            }

            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED, 1 -> { // 1 = MOVE_TO_FOREGROUND / ACTIVITY_RESUMED
                    if (activePackage != null && activePackage != pkg) {
                        // Close previous app session
                        val finishTime = min(time, endMs)
                        if (finishTime > activeSessionStart) {
                            splitAndAddSessions(activePackage!!, activeSessionStart, finishTime, sessions)
                        }
                    }
                    activePackage = pkg
                    activeSessionStart = max(time, startMs)
                }

                UsageEvents.Event.ACTIVITY_PAUSED, 2 -> { // 2 = MOVE_TO_BACKGROUND / ACTIVITY_PAUSED
                    if (activePackage == pkg) {
                        val finishTime = min(time, endMs)
                        if (finishTime > activeSessionStart) {
                            splitAndAddSessions(pkg, activeSessionStart, finishTime, sessions)
                        }
                        activePackage = null
                    }
                }

                UsageEvents.Event.SCREEN_NON_INTERACTIVE,
                UsageEvents.Event.KEYGUARD_SHOWN -> {
                    if (activePackage != null) {
                        val finishTime = min(time, endMs)
                        if (finishTime > activeSessionStart) {
                            splitAndAddSessions(activePackage!!, activeSessionStart, finishTime, sessions)
                        }
                        activePackage = null
                    }
                }
            }
        }

        // If there's an ongoing session at the end of the queried range, cap it at min(now, endMs)
        if (activePackage != null) {
            val now = System.currentTimeMillis()
            val finishTime = min(now, endMs)
            if (finishTime > activeSessionStart) {
                splitAndAddSessions(activePackage!!, activeSessionStart, finishTime, sessions)
            }
        }

        return sessions
    }

    /**
     * Computes app rollups (foreground time, opens, categories) from collected sessions.
     */
    fun summarizeSessions(sessions: List<AppSessionData>): List<AppSummaryData> {
        val appTotals = mutableMapOf<String, Long>()
        val appOpens = mutableMapOf<String, Int>()

        for (session in sessions) {
            val pkg = session.packageId
            val duration = session.durationMs
            appTotals[pkg] = (appTotals[pkg] ?: 0L) + duration
            appOpens[pkg] = (appOpens[pkg] ?: 0) + 1
        }

        return appTotals.map { (pkg, totalMs) ->
            val label = getAppLabel(pkg)
            val category = resolveCategory(pkg)
            val isShortVideo = isShortVideoApp(pkg)
            AppSummaryData(
                packageId = pkg,
                appLabel = label,
                category = category,
                foregroundMs = totalMs,
                opens = appOpens[pkg] ?: 1,
                isShortVideo = isShortVideo
            )
        }.sortedByDescending { it.foregroundMs }
    }

    /**
     * Splits a session spanning midnight into individual daily segments.
     */
    private fun splitAndAddSessions(
        pkg: String,
        startMs: Long,
        endMs: Long,
        out: MutableList<AppSessionData>
    ) {
        if (endMs <= startMs) return

        val appLabel = getAppLabel(pkg)
        var currentStart = startMs

        while (currentStart < endMs) {
            val dayString = dayFormat.format(Date(currentStart))
            val midnightMs = getNextMidnightMs(currentStart)
            val segmentEnd = min(endMs, midnightMs)

            if (segmentEnd > currentStart) {
                out.add(
                    AppSessionData(
                        packageId = pkg,
                        appLabel = appLabel,
                        startMs = currentStart,
                        endMs = segmentEnd,
                        day = dayString
                    )
                )
            }
            currentStart = segmentEnd
        }
    }

    private fun getNextMidnightMs(timeMs: Long): Long {
        val cal = Calendar.getInstance().apply {
            timeInMillis = timeMs
            set(Calendar.HOUR_OF_DAY, 24)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return cal.timeInMillis
    }

    private fun getLauncherPackages(): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
            )
        } else {
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
        }
        return resolveInfos.mapNotNull { it.activityInfo?.packageName }.toSet()
    }

    fun getAppLabel(packageName: String): String {
        return try {
            val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getApplicationInfo(
                    packageName,
                    PackageManager.ApplicationInfoFlags.of(0)
                )
            } else {
                packageManager.getApplicationInfo(packageName, 0)
            }
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (_: Exception) {
            // Fallback: clean package suffix if not found
            packageName.substringAfterLast('.').replaceFirstChar { it.uppercase() }
        }
    }

    fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val drawable = packageManager.getApplicationIcon(packageName)
            val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
                drawable.bitmap
            } else {
                val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (_: Exception) {
            null
        }
    }

    fun resolveCategory(packageName: String): String {
        val lower = packageName.lowercase(Locale.ROOT)
        if (lower.contains("instagram") || lower.contains("tiktok") || lower.contains("facebook") ||
            lower.contains("twitter") || lower.contains("threads") || lower.contains("reddit") ||
            lower.contains("snapchat") || lower.contains("linkedin")) {
            return "social"
        }
        if (lower.contains("youtube") || lower.contains("netflix") || lower.contains("twitch") ||
            lower.contains("disney") || lower.contains("primevideo") || lower.contains("vimeo") ||
            lower.contains("hulu")) {
            return "video"
        }
        if (lower.contains("chrome") || lower.contains("firefox") || lower.contains("browser") ||
            lower.contains("opera") || lower.contains("edge") || lower.contains("brave")) {
            return "browsing"
        }
        if (lower.contains("whatsapp") || lower.contains("telegram") || lower.contains("messenger") ||
            lower.contains("signal") || lower.contains("discord") || lower.contains("slack")) {
            return "messaging"
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                return when (appInfo.category) {
                    ApplicationInfo.CATEGORY_SOCIAL -> "social"
                    ApplicationInfo.CATEGORY_VIDEO -> "video"
                    ApplicationInfo.CATEGORY_NEWS -> "browsing"
                    ApplicationInfo.CATEGORY_PRODUCTIVITY -> "utility"
                    else -> "utility"
                }
            } catch (_: Exception) {
                // fall through
            }
        }
        return "other"
    }

    fun isShortVideoApp(packageName: String): Boolean {
        val lower = packageName.lowercase(Locale.ROOT)
        return lower.contains("instagram") ||
                lower.contains("tiktok") ||
                lower.contains("youtube") ||
                lower.contains("facebook")
    }
}

