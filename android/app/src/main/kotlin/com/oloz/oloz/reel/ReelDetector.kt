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
                val matchesMarker = event.viewId != null && appConfig.surfaceMarkers.any {
                    event.viewId.contains(it, ignoreCase = true)
                }
                val className = event.className ?: ""
                val matchesClass = className.contains("Reel", ignoreCase = true) ||
                        className.contains("Shorts", ignoreCase = true) ||
                        className.contains("Clips", ignoreCase = true)

                if (matchesMarker || matchesClass) {
                    if (!state.isSurfaceActive) {
                        state.isSurfaceActive = true
                        state.isApproxSurface = false
                        state.currentReelStartTime = event.timestampMs
                        state.lastCountedReelTime = 0L
                        state.pendingSettle = false
                    }
                } else if (className.contains("Activity", ignoreCase = true) && !matchesMarker) {
                    // Leaving reel surface
                    state.isSurfaceActive = false
                    state.pendingSettle = false
                }
                return null
            }

            TYPE_WINDOW_CONTENT_CHANGED -> {
                // If marker appears in content change, activate surface
                if (!state.isSurfaceActive && event.viewId != null) {
                    val matchesMarker = appConfig.surfaceMarkers.any {
                        event.viewId.contains(it, ignoreCase = true)
                    }
                    if (matchesMarker) {
                        state.isSurfaceActive = true
                        state.isApproxSurface = false
                        state.currentReelStartTime = event.timestampMs
                    }
                }

                // If a scroll was pending settle, settle it on content change after debounce
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
                // Fallback heuristic: full screen scroll activates approx surface if inactive
                if (!state.isSurfaceActive && event.isFullScreenScroll) {
                    state.isSurfaceActive = true
                    state.isApproxSurface = true
                    state.currentReelStartTime = event.timestampMs
                }

                if (!state.isSurfaceActive) return null

                // Check pager class hints
                val className = event.className ?: ""
                val isPager = appConfig.pagerClassHints.any { className.contains(it, ignoreCase = true) } ||
                        event.isFullScreenScroll

                if (!isPager) return null

                // Dedup pull-to-refresh (scroll to top index 0 without dwell)
                if (event.toIndex == 0 && state.lastScrollIndex == 0) {
                    return null
                }

                val now = event.timestampMs
                val timeSinceLastScroll = now - state.lastScrollTime
                state.lastScrollTime = now
                if (event.toIndex >= 0) {
                    state.lastScrollIndex = event.toIndex
                }

                // Fast flick handling: if multiple swipes arrive within minDwellMs, keep updating reel start
                val dwell = now - state.currentReelStartTime

                if (dwell < timing.minDwellMs) {
                    // Fast flick; mark pending settle so we count once settled
                    state.pendingSettle = true
                    return null
                }

                // Settle check and debounce from previous counted reel
                if (now - state.lastCountedReelTime < timing.debounceMs) {
                    return null
                }

                // Valid reel completed!
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

