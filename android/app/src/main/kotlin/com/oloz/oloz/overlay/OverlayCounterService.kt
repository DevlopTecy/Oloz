package com.oloz.oloz.overlay

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.abs

class OverlayCounterService : Service() {

    companion object {
        const val ACTION_SHOW = "com.oloz.oloz.overlay.SHOW"
        const val ACTION_HIDE = "com.oloz.oloz.overlay.HIDE"
        const val ACTION_UPDATE = "com.oloz.oloz.overlay.UPDATE"
        const val EXTRA_COUNT = "extra_count"
        const val EXTRA_MINUTES = "extra_minutes"

        var isShowing: Boolean = false
            private set

        fun show(context: Context, count: Int = 37, minutes: Int = 12) {
            val intent = Intent(context, OverlayCounterService::class.java).apply {
                action = ACTION_SHOW
                putExtra(EXTRA_COUNT, count)
                putExtra(EXTRA_MINUTES, minutes)
            }
            context.startService(intent)
        }

        fun hide(context: Context) {
            val intent = Intent(context, OverlayCounterService::class.java).apply {
                action = ACTION_HIDE
            }
            context.startService(intent)
        }

        fun update(context: Context, count: Int, minutes: Int) {
            val intent = Intent(context, OverlayCounterService::class.java).apply {
                action = ACTION_UPDATE
                putExtra(EXTRA_COUNT, count)
                putExtra(EXTRA_MINUTES, minutes)
            }
            context.startService(intent)
        }
    }

    private var windowManager: WindowManager? = null
    private var overlayView: LinearLayout? = null
    private var windowParams: WindowManager.LayoutParams? = null

    private var countTextView: TextView? = null
    private var labelTextView: TextView? = null
    private var pauseIconView: ImageView? = null

    private var currentCount: Int = 37
    private var currentMinutes: Int = 12
    private var isExpanded: Boolean = false

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as? WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: ACTION_SHOW

        when (action) {
            ACTION_SHOW -> {
                currentCount = intent?.getIntExtra(EXTRA_COUNT, currentCount) ?: currentCount
                currentMinutes = intent?.getIntExtra(EXTRA_MINUTES, currentMinutes) ?: currentMinutes
                createAndShowOverlay()
            }
            ACTION_UPDATE -> {
                currentCount = intent?.getIntExtra(EXTRA_COUNT, currentCount) ?: currentCount
                currentMinutes = intent?.getIntExtra(EXTRA_MINUTES, currentMinutes) ?: currentMinutes
                updateViews()
            }
            ACTION_HIDE -> {
                removeOverlay()
                stopSelf()
            }
        }

        return START_NOT_STICKY
    }

    private fun createAndShowOverlay() {
        if (overlayView != null) {
            updateViews()
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            return
        }

        val wm = windowManager ?: return

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            dpToPx(44),
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = dpToPx(16)
            y = dpToPx(80)
        }
        windowParams = params

        // Build the pill layout
        val pill = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dpToPx(12), dpToPx(6), dpToPx(12), dpToPx(6))

            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(22).toFloat()
                setColor(Color.parseColor("#E6FFFFFF")) // 90% white glassmorphism
                setStroke(dpToPx(1), Color.parseColor("#E4E2DC")) // 1px hairline border
            }
            elevation = dpToPx(8).toFloat()
        }

        // 1. Peach Dot
        val dotView = View(this).apply {
            val dotSize = dpToPx(8)
            val lp = LinearLayout.LayoutParams(dotSize, dotSize).apply {
                marginEnd = dpToPx(8)
            }
            layoutParams = lp
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#F0A98E")) // Brand Peach
            }
        }
        pill.addView(dotView)

        // 2. Count text
        countTextView = TextView(this).apply {
            text = currentCount.toString()
            setTextColor(Color.parseColor("#23262B"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            paint.isFakeBoldText = true
            val lp = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = dpToPx(5)
            }
            layoutParams = lp
        }
        pill.addView(countTextView)

        // 3. Label text
        labelTextView = TextView(this).apply {
            text = "reels"
            setTextColor(Color.parseColor("#6E727A"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        }
        pill.addView(labelTextView)

        // 4. Pause icon (visible when expanded)
        pauseIconView = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_media_pause)
            setColorFilter(Color.parseColor("#6E727A"))
            val iconSize = dpToPx(16)
            val lp = LinearLayout.LayoutParams(iconSize, iconSize).apply {
                marginStart = dpToPx(8)
            }
            layoutParams = lp
            visibility = View.GONE
        }
        pill.addView(pauseIconView)

        setupTouchListener(pill, params)

        overlayView = pill
        try {
            wm.addView(pill, params)
            isShowing = true
        } catch (_: Exception) {}
    }

    private fun setupTouchListener(pill: View, params: WindowManager.LayoutParams) {
        pill.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private val touchSlop = dpToPx(6)

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()

                        // End gravity: moving left increases params.x
                        params.x = initialX - dx
                        params.y = initialY + dy
                        windowManager?.updateViewLayout(pill, params)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        val dx = abs(event.rawX - initialTouchX)
                        val dy = abs(event.rawY - initialTouchY)
                        if (dx < touchSlop && dy < touchSlop) {
                            // Tap toggle
                            toggleExpanded()
                        }
                        return true
                    }
                }
                return false
            }
        })
    }

    private fun toggleExpanded() {
        isExpanded = !isExpanded
        updateViews()
    }

    private fun updateViews() {
        countTextView?.text = currentCount.toString()

        if (isExpanded) {
            labelTextView?.text = "reels · ${currentMinutes}m"
            pauseIconView?.visibility = View.VISIBLE
        } else {
            labelTextView?.text = "reels"
            pauseIconView?.visibility = View.GONE
        }

        overlayView?.let { pill ->
            windowParams?.let { params ->
                windowManager?.updateViewLayout(pill, params)
            }
        }
    }

    private fun removeOverlay() {
        if (overlayView != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (_: Exception) {}
            overlayView = null
        }
        isShowing = false
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    override fun onDestroy() {
        removeOverlay()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

