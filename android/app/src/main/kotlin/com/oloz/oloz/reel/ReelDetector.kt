package com.oloz.oloz.reel

import kotlin.math.max

class ReelDetector(
    private val config: ReelDetectorsConfig
) {
    // Accessibility event constants
    companion object {
        const val TYPE_VIEW_SCROLLED = 4096
        const val TYPE_WINDOW_STATE_CHANGED = 32
        const val TYPE_WINDOW_CONTENT_CHANGED = 2048
    }

    private data class AppState(
        var isSurfaceActive: Boolean = false,
        var currentReelStartTime: Long = 0L,
        var lastCountedReelTime: Long = 0L,
        var lastScrollTime: Long = 0L,
        var lastScrollIndex: Int = -1,
        var pendingSettle: Boolean = false,
        var hasDwellCompleted: Boolean = false,
        var isApproxSurface: Boolean = false
    )

    private val appStates = mutableMapOf<String, AppState>()

    private fun getAppState(pkg: String): AppState {
        return appStates.getOrPut(pkg) { AppState() }
    }

    /**
     * Processes an accessibility event and returns a [ReelDetectedEvent] if a valid reel page was completed.
     */
    fun processEvent(event: AccessibilityEventModel): ReelDetectedEvent? {
        val appConfig = config.apps[event.packageName] ?: return null
        val state = getAppState(event.packageName)
        val timing = config.timing

        when (event.eventType) {
            TYPE_WINDOW_STATE_CHANGED -> {
                val className = event.className ?: ""
                val matchesMarker = event.viewId != null && appConfig.surfaceMarkers.any {
                    event.viewId.contains(it, ignoreCase = true)
                }
                val matchesClass = className.contains("Reel", ignoreCase = true) ||
                        className.contains("Shorts", ignoreCase = true) ||
                        className.contains("Clips", ignoreCase = true)

                if (matchesMarker || matchesClass || event.isFullScreenScroll) {
                    state.isSurfaceActive = true
                    state.isApproxSurface = false
                    if (state.currentReelStartTime == 0L) {
                        state.currentReelStartTime = event.timestampMs
                    }
                }
                return null
            }

            TYPE_WINDOW_CONTENT_CHANGED -> {
                if (state.pendingSettle) {
                    val timeSinceScroll = event.timestampMs - state.lastScrollTime
                    if (timeSinceScroll >= timing.debounceMs) {
                        state.pendingSettle = false
                        val dwell = event.timestampMs - state.currentReelStartTime
                        if (dwell >= timing.minDwellMs &&
                            (event.timestampMs - state.lastCountedReelTime >= timing.debounceMs)) {
                            state.lastCountedReelTime = event.timestampMs
                            state.currentReelStartTime = event.timestampMs
                            return ReelDetectedEvent(
                                packageId = event.packageName,
                                dwellMs = dwell,
                                timestampMs = event.timestampMs,
                                confidence = if (state.isApproxSurface) "approx" else "high"
                            )
                        }
                    }
                }
                return null
            }

            TYPE_VIEW_SCROLLED -> {
                val now = event.timestampMs

                // In a supported video platform, any scroll in the app is candidate reel activity
                if (!state.isSurfaceActive) {
                    state.isSurfaceActive = true
                    state.isApproxSurface = true
                    state.currentReelStartTime = now
                    state.lastScrollTime = now
                    return null
                }

                // Dedup pull-to-refresh
                if (event.toIndex == 0 && state.lastScrollIndex == 0) {
                    return null
                }

                val dwell = now - state.currentReelStartTime
                state.lastScrollTime = now
                if (event.toIndex >= 0) {
                    state.lastScrollIndex = event.toIndex
                }

                if (dwell < timing.minDwellMs) {
                    state.pendingSettle = true
                    return null
                }

                if (now - state.lastCountedReelTime < timing.debounceMs) {
                    return null
                }

                // Reel completed
                state.lastCountedReelTime = now
                state.currentReelStartTime = now
                state.pendingSettle = false

                return ReelDetectedEvent(
                    packageId = event.packageName,
                    dwellMs = dwell,
                    timestampMs = now,
                    confidence = if (state.isApproxSurface) "approx" else "high"
                )
            }

            else -> return null
        }
    }

    /**
     * Resets state for an app or all apps (e.g. on screen off or leave).
     */
    fun reset(packageName: String? = null) {
        if (packageName != null) {
            appStates.remove(packageName)
        } else {
            appStates.clear()
        }
    }

    fun isSurfaceActive(packageName: String): Boolean {
        return appStates[packageName]?.isSurfaceActive == true
    }
}

