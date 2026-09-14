package com.christianfontalvo.cfcalcafacil

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.christianfontalvo.cfcalcafacil/native"
    private val cameraRequestCode = 4102
    private var cameraPermissionResult: MethodChannel.Result? = null
    private var originalBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        originalBrightness = window.attributes.screenBrightness
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setTracingActive" -> {
                        val active = call.argument<Boolean>("active") ?: false
                        setTracingActive(active)
                        result.success(null)
                    }

                    "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))

                    "requestOverlayPermission" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(null)
                    }

                    "hasCameraPermission" -> result.success(hasCameraPermission())

                    "requestCameraPermission" -> requestCameraPermission(result)

                    "startCameraOverlay" -> {
                        if (!Settings.canDrawOverlays(this)) {
                            result.error("overlay_permission", "Falta el permiso para mostrar sobre otras aplicaciones.", null)
                            return@setMethodCallHandler
                        }
                        if (!hasCameraPermission()) {
                            result.error("camera_permission", "Falta el permiso para utilizar la cámara.", null)
                            return@setMethodCallHandler
                        }
                        val opacity = (call.argument<Double>("opacity") ?: 0.70).toFloat()
                        val intent = Intent(this, CameraOverlayService::class.java).apply {
                            action = CameraOverlayService.ACTION_START
                            putExtra(CameraOverlayService.EXTRA_OPACITY, opacity)
                        }
                        ContextCompat.startForegroundService(this, intent)
                        result.success(null)
                        Handler(Looper.getMainLooper()).postDelayed({ moveTaskToBack(true) }, 650)
                    }

                    "stopCameraOverlay" -> {
                        stopService(Intent(this, CameraOverlayService::class.java))
                        result.success(null)
                    }

                    "isCameraOverlayRunning" -> result.success(CameraOverlayService.isRunning)

                    else -> result.notImplemented()
                }
            }
    }

    private fun hasCameraPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun requestCameraPermission(result: MethodChannel.Result) {
        if (hasCameraPermission()) {
            result.success(true)
            return
        }
        cameraPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.CAMERA),
            cameraRequestCode
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == cameraRequestCode) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            cameraPermissionResult?.success(granted)
            cameraPermissionResult = null
        }
    }

    private fun setTracingActive(active: Boolean) {
        if (active) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            val params = window.attributes
            params.screenBrightness = 1f
            window.attributes = params
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            val params = window.attributes
            params.screenBrightness = originalBrightness
            window.attributes = params
        }
    }
}
