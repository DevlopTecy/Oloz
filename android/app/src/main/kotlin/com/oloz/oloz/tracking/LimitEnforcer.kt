package com.oloz.oloz.tracking

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.oloz.oloz.MainActivity
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class LimitEnforcer(private val context: Context) {

    companion object {
        const val REMINDERS_CHANNEL_ID = "oloz_reminders_channel"
        const val ALERTS_CHANNEL_ID = "oloz_alerts_channel"

        private const val PREFS_NAME = "oloz_limit_prefs"
        private const val MAX_SNOOZES_PER_DAY = 3
    }

    private val notificationManager = NotificationManagerCompat.from(context)
    private val dayFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
        timeZone = TimeZone.getDefault()
    }

    init {
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(NotificationManager::class.java) ?: return

            // 1. Reminders channel (80% soft notice)
            val remindersChannel = NotificationChannel(
                REMINDERS_CHANNEL_ID,
                "Reminders",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Gentle heads-up when approaching daily limits"
                setShowBadge(false)
            }

            // 2. Alerts channel (100% limit reached)
            val alertsChannel = NotificationChannel(
                ALERTS_CHANNEL_ID,
                "Limit Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Neutral notices when your daily limit is reached"
                setShowBadge(true)
                enableVibration(true)
            }

            manager.createNotificationChannel(remindersChannel)
            manager.createNotificationChannel(alertsChannel)
        }
    }

    /**
     * Checks an app or global reels usage against its limit and triggers 80% reminder or 100% alert.
     */
    fun evaluateAppLimit(
        packageId: String,
        appLabel: String,
        usageMs: Long,
        limitMs: Long,
        isSnoozed: Boolean
    ): String {
        if (limitMs <= 0 || isSnoozed) return "OK"

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val today = dayFormat.format(Date())

        val ratio = usageMs.toDouble() / limitMs.toDouble()

        if (ratio >= 1.0) {
            val alertKey = "alert_100_${packageId}_$today"
            val lastAlertTime = prefs.getLong(alertKey, 0L)
            // Re-alert if 15 minutes elapsed since last 100% alert
            if (System.currentTimeMillis() - lastAlertTime > 15 * 60 * 1000L) {
                sendLimitReachedAlert(packageId, appLabel, limitMs)
                prefs.edit().putLong(alertKey, System.currentTimeMillis()).apply()
                return "100_ALERT"
            }
        } else if (ratio >= 0.8) {
            val softKey = "soft_80_${packageId}_$today"
            val alreadyFired = prefs.getBoolean(softKey, false)
            if (!alreadyFired) {
                sendSoftReminder(packageId, appLabel, usageMs, limitMs)
                prefs.edit().putBoolean(softKey, true).apply()
                return "80_REMINDER"
            }
        }

        return "OK"
    }

    fun evaluateReelsLimit(
        totalReels: Int,
        goalReels: Int,
        isSnoozed: Boolean
    ): String {
        if (goalReels <= 0 || isSnoozed) return "OK"

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val today = dayFormat.format(Date())
        val ratio = totalReels.toDouble() / goalReels.toDouble()

        if (ratio >= 1.0) {
            val alertKey = "alert_reels_100_$today"
            val lastAlertTime = prefs.getLong(alertKey, 0L)
            if (System.currentTimeMillis() - lastAlertTime > 15 * 60 * 1000L) {
                sendReelsLimitAlert(totalReels, goalReels)
                prefs.edit().putLong(alertKey, System.currentTimeMillis()).apply()
                return "100_ALERT"
            }
        } else if (ratio >= 0.8) {
            val softKey = "soft_reels_80_$today"
            val alreadyFired = prefs.getBoolean(softKey, false)
            if (!alreadyFired) {
                sendReelsSoftReminder(totalReels, goalReels)
                prefs.edit().putBoolean(softKey, true).apply()
                return "80_REMINDER"
            }
        }

        return "OK"
    }

    private fun sendSoftReminder(packageId: String, appLabel: String, usageMs: Long, limitMs: Long) {
        val notification = NotificationCompat.Builder(context, REMINDERS_CHANNEL_ID)
            .setContentTitle("Almost at your limit")
            .setContentText("$appLabel · ${formatDuration(usageMs)} of ${formatDuration(limitMs)}")
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .build()

        try {
            notificationManager.notify(packageId.hashCode(), notification)
        } catch (_: SecurityException) {}
    }

    private fun sendReelsSoftReminder(totalReels: Int, goalReels: Int) {
        val remaining = (goalReels - totalReels).coerceAtLeast(0)
        val notification = NotificationCompat.Builder(context, REMINDERS_CHANNEL_ID)
            .setContentTitle("Approaching reels limit")
            .setContentText("$totalReels reels watched · $remaining remaining today")
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .build()

        try {
            notificationManager.notify(9999, notification)
        } catch (_: SecurityException) {}
    }

    private fun sendLimitReachedAlert(packageId: String, appLabel: String, limitMs: Long) {
        val intent = Intent(context, MainActivity::class.java).apply {
            data = Uri.parse("oloz://alert/$packageId")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            packageId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(context, ALERTS_CHANNEL_ID)
            .setContentTitle("Limit reached")
            .setContentText("$appLabel · ${formatDuration(limitMs)} limit completed")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setAutoCancel(true)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Take a break",
                fullScreenPendingIntent
            )
            .build()

        try {
            notificationManager.notify(packageId.hashCode() + 100000, notification)
        } catch (_: SecurityException) {}
    }

    private fun sendReelsLimitAlert(totalReels: Int, goalReels: Int) {
        val intent = Intent(context, MainActivity::class.java).apply {
            data = Uri.parse("oloz://alert/reels_total")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            8888,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(context, ALERTS_CHANNEL_ID)
            .setContentTitle("Reels limit reached")
            .setContentText("You reached your $goalReels reels daily limit")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setAutoCancel(true)
            .build()

        try {
            notificationManager.notify(8888, notification)
        } catch (_: SecurityException) {}
    }

    private fun formatDuration(ms: Long): String {
        val minutes = ms / (60 * 1000)
        val hours = minutes / 60
        val remMin = minutes % 60
        return if (hours > 0) "${hours}h ${remMin}m" else "${remMin}m"
    }
}

