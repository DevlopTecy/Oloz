package com.oloz.oloz.tracking

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.util.Calendar
import java.util.concurrent.TimeUnit
import kotlin.math.max

class UsageBackfillWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    companion object {
        const val WORK_NAME = "OlozUsageBackfillWork"
        private const val PREFS_NAME = "oloz_tracking_prefs"
        private const val KEY_LAST_COLLECTED = "last_collected_ms"

        fun schedulePeriodic(context: Context) {
            val request = PeriodicWorkRequestBuilder<UsageBackfillWorker>(
                15, TimeUnit.MINUTES,
                5, TimeUnit.MINUTES // 5 min flex interval
            ).build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request
            )
        }

        fun cancelPeriodic(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        }
    }

    override fun doWork(): Result {
        val collector = UsageCollector(applicationContext)
        if (!collector.hasUsageStatsPermission()) {
            return Result.success()
        }

        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()

        // Default to beginning of local today
        val startOfToday = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

        val lastCollected = prefs.getLong(KEY_LAST_COLLECTED, startOfToday)
        val queryStart = max(startOfToday, lastCollected)

        if (now > queryStart) {
            val sessions = collector.collectSessions(queryStart, now)
            TrackingBridge.notifyUsageUpdated(sessions)

            prefs.edit().putLong(KEY_LAST_COLLECTED, now).apply()
        }

        return Result.success()
    }
}

