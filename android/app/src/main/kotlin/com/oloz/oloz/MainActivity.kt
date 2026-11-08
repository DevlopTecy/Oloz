package com.oloz.oloz

import com.oloz.oloz.tracking.TrackingBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val bridge = TrackingBridge(applicationContext) { activity }
        bridge.register(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onResume() {
        super.onResume()
        com.oloz.oloz.overlay.OverlayCounterService.hide(applicationContext)
    }
}
