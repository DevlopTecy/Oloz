package com.oloz.oloz.tracking

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        val prefs = context.getSharedPreferences("oloz_tracking_prefs", Context.MODE_PRIVATE)
        val isTrackingEnabled = prefs.getBoolean("tracking_enabled", true)

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                if (isTrackingEnabled) {
                    // Schedule 15-min periodic backfill
                    UsageBackfillWorker.schedulePeriodic(context)

                    // Start foreground service if usage stats permission granted
                    val collector = UsageCollector(context)
                    if (collector.hasUsageStatsPermission()) {
                        val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                            this.action = TrackingForegroundService.ACTION_START
                        }
                        try {
                            ContextCompat.startForegroundService(context, serviceIntent)
                        } catch (_: Exception) {}
                    }
                }
            }

            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_SET -> {
                // Midnight or timezone rollover: trigger backfill to split sessions at calendar boundary
                if (isTrackingEnabled) {
                    val serviceIntent = Intent(context, TrackingForegroundService::class.java).apply {
                        this.action = TrackingForegroundService.ACTION_COLLECT_NOW
                    }
                    try {
                        ContextCompat.startForegroundService(context, serviceIntent)
                    } catch (_: Exception) {}
                }
            }
        }
    }
}

