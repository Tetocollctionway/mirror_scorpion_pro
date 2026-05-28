package dev.moaz.dash_bubble.src

import android.animation.Animator
import android.animation.ObjectAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.core.content.ContextCompat
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.sqrt

class BubbleService(
    private val context: Context,
    private val bubbleIcon: String,
    private val distanceToClose: Int,
    private val enableAnimateToEdge: Boolean,
    private val enableClose: Boolean,
    private val bubbleSize: Float,
    private val opacity: Float
) {
    private var windowManager: WindowManager? = null
    private var bubbleView: FrameLayout? = null
    private var isShowing = false
    private var lastX = 0f
    private var lastY = 0f
    private var initialX = 0f
    private var initialY = 0f

    fun show() {
        if (isShowing) return

        try {
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            
            // Create bubble view
            bubbleView = FrameLayout(context).apply {
                layoutParams = FrameLayout.LayoutParams(
                    bubbleSize.toInt(),
                    bubbleSize.toInt()
                )
                
                // Add image view for the bubble
                val imageView = ImageView(context).apply {
                    layoutParams = FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    
                    // Try to load the bubble icon
                    try {
                        val resourceId = context.resources.getIdentifier(
                            bubbleIcon,
                            "drawable",
                            context.packageName
                        )
                        if (resourceId != 0) {
                            setImageDrawable(ContextCompat.getDrawable(context, resourceId))
                        } else {
                            // Fallback: create a simple colored circle
                            setBackgroundColor(0xFF2196F3.toInt())
                        }
                    } catch (e: Exception) {
                        setBackgroundColor(0xFF2196F3.toInt())
                    }
                    
                    alpha = opacity
                }
                
                addView(imageView)
                
                // Set touch listener for dragging
                setOnTouchListener { _, event ->
                    when (event.action) {
                        MotionEvent.ACTION_DOWN -> {
                            initialX = event.rawX
                            initialY = event.rawY
                            lastX = event.rawX
                            lastY = event.rawY
                            true
                        }
                        MotionEvent.ACTION_MOVE -> {
                            val deltaX = event.rawX - lastX
                            val deltaY = event.rawY - lastY
                            
                            val params = layoutParams as WindowManager.LayoutParams
                            params.x += deltaX.toInt()
                            params.y += deltaY.toInt()
                            
                            windowManager?.updateViewLayout(this, params)
                            
                            lastX = event.rawX
                            lastY = event.rawY
                            true
                        }
                        MotionEvent.ACTION_UP -> {
                            val distance = sqrt(
                                (event.rawX - initialX).pow(2) + (event.rawY - initialY).pow(2)
                            )
                            
                            if (distance < 10) {
                                // It's a tap, not a drag
                                // Handle tap if needed
                            } else if (enableAnimateToEdge) {
                                // Animate to edge
                                animateToEdge()
                            }
                            
                            if (enableClose && distance > distanceToClose) {
                                hide()
                            }
                            true
                        }
                        else -> false
                    }
                }
            }
            
            // Add bubble to window
            val params = WindowManager.LayoutParams().apply {
                type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                }
                format = PixelFormat.TRANSLUCENT
                flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                width = bubbleSize.toInt()
                height = bubbleSize.toInt()
                x = 100
                y = 100
                gravity = Gravity.TOP or Gravity.START
            }
            
            windowManager?.addView(bubbleView, params)
            isShowing = true
        } catch (e: Exception) {
            android.util.Log.e("BubbleService", "Error showing bubble: ${e.message}")
        }
    }

    fun hide() {
        try {
            if (isShowing && bubbleView != null && windowManager != null) {
                windowManager?.removeView(bubbleView)
                isShowing = false
            }
        } catch (e: Exception) {
            android.util.Log.e("BubbleService", "Error hiding bubble: ${e.message}")
        }
    }

    private fun animateToEdge() {
        try {
            val params = bubbleView?.layoutParams as? WindowManager.LayoutParams ?: return
            val screenWidth = context.resources.displayMetrics.widthPixels
            
            val targetX = if (params.x < screenWidth / 2) 0 else screenWidth - bubbleSize.toInt()
            
            ObjectAnimator.ofInt(params, "x", params.x, targetX).apply {
                duration = 300
                addListener(object : Animator.AnimatorListener {
                    override fun onAnimationStart(animation: Animator) {}
                    override fun onAnimationEnd(animation: Animator) {
                        windowManager?.updateViewLayout(bubbleView, params)
                    }
                    override fun onAnimationCancel(animation: Animator) {}
                    override fun onAnimationRepeat(animation: Animator) {}
                })
                start()
            }
        } catch (e: Exception) {
            android.util.Log.e("BubbleService", "Error animating to edge: ${e.message}")
        }
    }
}
