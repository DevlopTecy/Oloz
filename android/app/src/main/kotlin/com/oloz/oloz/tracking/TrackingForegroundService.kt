package com.oloz.oloz.tracking

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.oloz.oloz.MainActivity

class TrackingForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "oloz_tracking_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START = "com.oloz.oloz.action.START_TRACKING"
        const val ACTION_STOP = "com.oloz.oloz.action.STOP_TRACKING"
        const val ACTION_COLLECT_NOW = "com.oloz.oloz.action.COLLECT_NOW"

        var isRunning: Boolean = false
            private set
    }

    private var screenReceiver: BroadcastReceiver? = null
    private lateinit var usageCollector: UsageCollector

    override fun onCreate() {
        super.onCreate()
        usageCollector = UsageCollector(this)
        createNotificationChannel()
        registerScreenStateReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: ACTION_START

        when (action) {
            ACTION_STOP -> {
                stopForegroundTracking()
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_COLLECT_NOW -> {
                performQuickCollect()
            }
            ACTION_START -> {
                startForegroundTracking()
            }
        }

        return START_STICKY
    }

    private fun startForegroundTracking() {
        val notification = buildForegroundNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        isRunning = true
    }

    private fun stopForegroundTracking() {
        isRunning = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    private fun buildForegroundNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Oloz is active")
            .setContentText("Calmly tracking screen time in the background")
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Screen Time Tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows persistent non-intrusive status when Oloz is actively tracking foreground sessions"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun registerScreenStateReceiver() {
        if (screenReceiver != null) return

        screenReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    Intent.ACTION_SCREEN_OFF -> {
                        // Screen turned off: close open session cleanly
                        performQuickCollect()
                    }
                    Intent.ACTION_USER_PRESENT -> {
                        // User unlocked device: resume tracking session
                        performQuickCollect()
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
            addAction(Intent.ACTION_SCREEN_ON)
        }

        registerReceiver(screenReceiver, filter)
    }

    private fun performQuickCollect() {
        val now = System.currentTimeMillis()
        val oneHourAgo = now - 60 * 60 * 1000L
        val sessions = usageCollector.collectSessions(oneHourAgo, now)
        TrackingBridge.notifyUsageUpdated(sessions)
    }

    override fun onDestroy() {
        screenReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: Exception) {}
            screenReceiver = null
        }
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

