package dev.moaz.dash_bubble

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.widget.FrameLayout
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class DashBubblePlugin : FlutterPlugin, ActivityAware {
    companion object {
        private const val CHANNEL = "dev.moaz.dash_bubble/bubble"
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    private var bubbleView: BubbleService? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "startBubble" -> {
                    val bubbleIcon = call.argument<String>("bubbleIcon") ?: "launcher_icon"
                    val distanceToClose = call.argument<Int>("distanceToClose") ?: 100
                    val enableAnimateToEdge = call.argument<Boolean>("enableAnimateToEdge") ?: true
                    val enableClose = call.argument<Boolean>("enableClose") ?: true
                    val bubbleSize = call.argument<Double>("bubbleSize") ?: 120.0
                    val opacity = call.argument<Double>("opacity") ?: 0.8
                    
                    startBubble(bubbleIcon, distanceToClose, enableAnimateToEdge, enableClose, bubbleSize.toFloat(), opacity.toFloat())
                    result.success(true)
                }
                "stopBubble" -> {
                    stopBubble()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(context)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${context?.packageName}")
                )
                activity?.startActivity(intent)
            }
        }
    }

    private fun startBubble(
        bubbleIcon: String,
        distanceToClose: Int,
        enableAnimateToEdge: Boolean,
        enableClose: Boolean,
        bubbleSize: Float,
        opacity: Float
    ) {
        try {
            if (bubbleView == null) {
                bubbleView = BubbleService(
                    context!!,
                    bubbleIcon,
                    distanceToClose,
                    enableAnimateToEdge,
                    enableClose,
                    bubbleSize,
                    opacity
                )
            }
            bubbleView?.show()
        } catch (e: Exception) {
            android.util.Log.e("DashBubble", "Error starting bubble: ${e.message}")
        }
    }

    private fun stopBubble() {
        try {
            bubbleView?.hide()
            bubbleView = null
        } catch (e: Exception) {
            android.util.Log.e("DashBubble", "Error stopping bubble: ${e.message}")
        }
    }
}
