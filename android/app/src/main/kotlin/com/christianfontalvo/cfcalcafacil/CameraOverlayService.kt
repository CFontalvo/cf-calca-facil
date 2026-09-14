package com.christianfontalvo.cfcalcafacil

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.TextView
import androidx.camera.core.CameraSelector
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleService

class CameraOverlayService : LifecycleService() {
    companion object {
        const val ACTION_START = "com.christianfontalvo.cfcalcafacil.START_OVERLAY"
        const val ACTION_STOP = "com.christianfontalvo.cfcalcafacil.STOP_OVERLAY"
        const val EXTRA_OPACITY = "opacity"
        private const val CHANNEL_ID = "cf_calca_camera_flotante"
        private const val NOTIFICATION_ID = 4103

        @Volatile
        var isRunning: Boolean = false
            private set
    }

    private lateinit var windowManager: WindowManager
    private var cameraRoot: FrameLayout? = null
    private var controlRoot: LinearLayout? = null
    private var cameraParams: WindowManager.LayoutParams? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var opacity = 0.70f
    private var contentLocked = false
    private var tapCount = 0
    private var lastTapAt = 0L

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // LifecycleService must receive this call so CameraX can move its use
        // cases from CREATED to STARTED and actually open the camera.
        super.onStartCommand(intent, flags, startId)

        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return Service.START_NOT_STICKY
        }

        opacity = intent?.getFloatExtra(EXTRA_OPACITY, 0.70f)?.coerceIn(0.15f, 0.75f) ?: 0.70f
        startForegroundNow()

        if (!Settings.canDrawOverlays(this)) {
            stopSelf()
            return Service.START_NOT_STICKY
        }

        if (!isRunning) {
            isRunning = true
            showCameraOverlay()
            showControls()
        } else {
            updateOpacity(opacity)
        }
        return Service.START_NOT_STICKY
    }

    private fun startForegroundNow() {
        val stopIntent = Intent(this, CameraOverlayService::class.java).apply { action = ACTION_STOP }
        val stopPendingIntent = PendingIntent.getService(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val launchPendingIntent = PendingIntent.getActivity(
            this,
            1,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_cf)
            .setContentTitle("CF Calca Fácil")
            .setContentText("La cámara flotante está activa")
            .setContentIntent(launchPendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(R.drawable.ic_stat_cf, "Detener", stopPendingIntent)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun showCameraOverlay() {
        val previewView = PreviewView(this).apply {
            implementationMode = PreviewView.ImplementationMode.COMPATIBLE
            scaleType = PreviewView.ScaleType.FILL_CENTER
            alpha = 1f
        }
        cameraRoot = FrameLayout(this).apply {
            setBackgroundColor(Color.TRANSPARENT)
            isClickable = true
            setOnTouchListener { _, _ -> true }
            addView(
                previewView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        }

        cameraParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            alpha = opacity
        }
        windowManager.addView(cameraRoot, cameraParams)
        startCamera(previewView)
    }

    private fun startCamera(previewView: PreviewView) {
        val providerFuture = ProcessCameraProvider.getInstance(this)
        providerFuture.addListener({
            try {
                cameraProvider = providerFuture.get()
                val preview = Preview.Builder().build().also {
                    it.surfaceProvider = previewView.surfaceProvider
                }
                cameraProvider?.unbindAll()
                cameraProvider?.bindToLifecycle(
                    this,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview
                )
            } catch (_: Exception) {
                stopSelf()
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun showControls() {
        val panel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(14), dp(12), dp(14), dp(12))
            background = roundedBackground(Color.argb(245, 255, 255, 255), dp(18).toFloat())
            elevation = dp(8).toFloat()
        }

        val title = TextView(this).apply {
            text = "Cámara ${Math.round(opacity * 100)}%"
            setTextColor(Color.rgb(0, 45, 91))
            textSize = 14f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }
        val seekBar = SeekBar(this).apply {
            max = 60
            progress = Math.round((opacity - 0.15f) * 100)
            setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(bar: SeekBar?, progress: Int, fromUser: Boolean) {
                    updateOpacity(0.15f + progress / 100f)
                    title.text = "Cámara ${Math.round(opacity * 100)}%"
                }
                override fun onStartTrackingTouch(bar: SeekBar?) = Unit
                override fun onStopTrackingTouch(bar: SeekBar?) = Unit
            })
        }

        val actions = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.END
        }
        val lockButton = Button(this).apply {
            text = "Bloquear"
            setTextColor(Color.WHITE)
            background = roundedBackground(Color.rgb(0, 45, 91), dp(14).toFloat())
            setOnClickListener {
                panel.visibility = View.GONE
                setContentLocked(true)
            }
        }
        val stopButton = Button(this).apply {
            text = "Detener"
            setTextColor(Color.WHITE)
            background = roundedBackground(Color.rgb(236, 91, 83), dp(14).toFloat())
            setOnClickListener { stopSelf() }
        }
        actions.addView(lockButton, LinearLayout.LayoutParams(0, dp(48), 1f).apply { marginEnd = dp(8) })
        actions.addView(stopButton, LinearLayout.LayoutParams(0, dp(48), 1f))
        panel.addView(title)
        panel.addView(
            seekBar,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(44)
            )
        )
        panel.addView(
            actions,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        )

        val bubble = TextView(this).apply {
            text = "CF\n3×"
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            textSize = 13f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            background = roundedBackground(Color.argb(245, 0, 45, 91), dp(30).toFloat())
            elevation = dp(10).toFloat()
            setOnClickListener {
                val now = System.currentTimeMillis()
                tapCount = if (now - lastTapAt <= 850) tapCount + 1 else 1
                lastTapAt = now
                if (tapCount >= 3) {
                    setContentLocked(false)
                    panel.visibility = View.VISIBLE
                    tapCount = 0
                }
            }
        }

        controlRoot = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.END
            addView(
                panel,
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            )
            addView(
                bubble,
                LinearLayout.LayoutParams(dp(58), dp(58)).apply {
                    gravity = Gravity.END
                    topMargin = dp(8)
                }
            )
        }

        val params = WindowManager.LayoutParams(
            dp(320),
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = dp(12)
            y = dp(72)
        }
        windowManager.addView(controlRoot, params)
    }

    private fun updateOpacity(value: Float) {
        opacity = value.coerceIn(0.15f, 0.75f)
        cameraParams?.let { params ->
            params.alpha = opacity
            cameraRoot?.let { root ->
                runCatching { windowManager.updateViewLayout(root, params) }
            }
        }
    }

    private fun setContentLocked(locked: Boolean) {
        contentLocked = locked
        cameraParams?.let { params ->
            params.flags = if (locked) {
                params.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE.inv()
            } else {
                params.flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
            }
            cameraRoot?.let { root ->
                runCatching { windowManager.updateViewLayout(root, params) }
            }
        }
    }

    private fun roundedBackground(color: Int, radius: Float) = GradientDrawable().apply {
        setColor(color)
        cornerRadius = radius
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Cámara flotante",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Mantiene activa la cámara flotante mientras calcas"
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        cameraProvider?.unbindAll()
        cameraRoot?.let { runCatching { windowManager.removeView(it) } }
        controlRoot?.let { runCatching { windowManager.removeView(it) } }
        cameraRoot = null
        controlRoot = null
        contentLocked = false
        isRunning = false
        @Suppress("DEPRECATION")
        stopForeground(true)
        super.onDestroy()
    }
}
