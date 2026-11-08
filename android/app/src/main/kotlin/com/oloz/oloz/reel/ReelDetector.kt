package com.oloz.oloz.reel

import kotlin.math.max

class ReelDetector(
    private val config: ReelDetectorsConfig
) {
    companion object {
        const val TYPE_VIEW_SCROLLED = 4096
        const val TYPE_WINDOW_STATE_CHANGED = 32
        const val TYPE_WINDOW_CONTENT_CHANGED = 2048

        private val IGNORED_VIEW_KEYWORDS = listOf(
            "comment",
            "reply",
            "composer",
            "sheet",
            "dialog",
            "drawer",
            "thread",
            "bottom_sheet",
            "reels_tray",
            "story",
            "stories"
        )
    }

    private data class AppState(
        var isSurfaceActive: Boolean = false,
        var currentReelStartTime: Long = 0L,
        var lastCountedReelTime: Long = 0L,
        var lastCountedIndex: Int = -1,
        var lastScrollIndex: Int = -1,
        var lastScrollTime: Long = 0L,
        var pendingSettle: Boolean = false,
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

        // 1. Filter out non-reel views (comments, replies, bottom sheets, stories tray)
        val viewIdLower = (event.viewId ?: "").lowercase()
        if (IGNORED_VIEW_KEYWORDS.any { viewIdLower.contains(it) }) {
            return null
        }

        // 2. Track surface activation based on view markers
        if (event.viewId != null) {
            val isReelMarker = appConfig.surfaceMarkers.any { event.viewId.contains(it, ignoreCase = true) } ||
                    viewIdLower.contains("scrubber") ||
                    viewIdLower.contains("clips") ||
                    viewIdLower.contains("shorts")

            val isNonReelMarker = viewIdLower.contains("feed") ||
                    viewIdLower.contains("search") ||
                    viewIdLower.contains("profile") ||
                    viewIdLower.contains("direct") ||
                    viewIdLower.contains("home")

            if (isNonReelMarker && !isReelMarker) {
                state.isSurfaceActive = false
                state.currentReelStartTime = 0L
                state.pendingSettle = false
            } else if (isReelMarker) {
                state.isSurfaceActive = true
                if (state.currentReelStartTime == 0L) {
                    state.currentReelStartTime = event.timestampMs
                }
            }
        }

        when (event.eventType) {
            TYPE_WINDOW_STATE_CHANGED -> {
                val className = event.className ?: ""
                val matchesMarker = event.viewId != null && (
                    appConfig.surfaceMarkers.any { event.viewId.contains(it, ignoreCase = true) } ||
                    viewIdLower.contains("clips") ||
                    viewIdLower.contains("shorts")
                )
                val matchesClass = className.contains("Reel", ignoreCase = true) ||
                        className.contains("Shorts", ignoreCase = true) ||
                        className.contains("Clips", ignoreCase = true)

                if (matchesMarker || matchesClass) {
                    state.isSurfaceActive = true
                    state.isApproxSurface = false
                    if (state.currentReelStartTime == 0L) {
                        state.currentReelStartTime = event.timestampMs
                    }
                    state.lastScrollTime = event.timestampMs
                } else {
                    // Navigated away from reel surface to main feed, profile, search, etc.
                    state.isSurfaceActive = false
                    state.isApproxSurface = false
                    state.currentReelStartTime = 0L
                    state.pendingSettle = false
                    state.lastCountedIndex = -1
                    state.lastScrollIndex = -1
                }
                return null
            }

            TYPE_WINDOW_CONTENT_CHANGED -> {
                if (state.isSurfaceActive) {
                    val isReelMediaMarker = viewIdLower.contains("scrubber") ||
                            viewIdLower.contains("clips_video_container") ||
                            viewIdLower.contains("reel_player")

                    if (isReelMediaMarker) {
                        val now = event.timestampMs
                        val dwell = now - state.currentReelStartTime

                        if (dwell >= timing.minDwellMs &&
                            (now - state.lastCountedReelTime >= timing.debounceMs)) {
                            state.lastCountedReelTime = now
                            state.currentReelStartTime = now
                            state.pendingSettle = false
                            return ReelDetectedEvent(
                                packageId = event.packageName,
                                dwellMs = dwell,
                                timestampMs = now,
                                confidence = "high"
                            )
                        } else if (dwell < timing.minDwellMs && (now - state.lastScrollTime >= 300L)) {
                            state.currentReelStartTime = now
                        }
                    } else if (state.pendingSettle) {
                        val timeSinceScroll = event.timestampMs - state.lastScrollTime
                        if (timeSinceScroll >= timing.debounceMs) {
                            state.pendingSettle = false
                            val dwell = event.timestampMs - state.currentReelStartTime
                            if (dwell >= timing.minDwellMs &&
                                (event.timestampMs - state.lastCountedReelTime >= timing.debounceMs)) {
                                if (state.lastScrollIndex >= 0 && state.lastScrollIndex == state.lastCountedIndex) {
                                    return null
                                }
                                state.lastCountedReelTime = event.timestampMs
                                state.lastCountedIndex = state.lastScrollIndex
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
                }
                return null
            }

            TYPE_VIEW_SCROLLED -> {
                val now = event.timestampMs

                // Strict surface check: Scrolling outside an active reel surface NEVER counts
                if (!state.isSurfaceActive) {
                    return null
                }

                // If view indicates main feed or search explicitly, deactivate and ignore
                if (viewIdLower.contains("feed") || viewIdLower.contains("main") || viewIdLower.contains("home")) {
                    state.isSurfaceActive = false
                    return null
                }

                // Dedup pull-to-refresh
                if (event.toIndex == 0 && state.lastScrollIndex == 0) {
                    return null
                }

                // If user is jiggling / holding and toIndex is unchanged and equals lastCountedIndex
                if (event.toIndex >= 0 && event.toIndex == state.lastCountedIndex && event.toIndex == state.lastScrollIndex) {
                    state.lastScrollTime = now
                    return null
                }

                // A reel is only watched if the user stayed without scrolling for >= minDwellMs
                val timeSinceLastScroll = now - state.lastScrollTime
                state.lastScrollTime = now
                if (event.toIndex >= 0) {
                    state.lastScrollIndex = event.toIndex
                }

                if (timeSinceLastScroll < timing.minDwellMs) {
                    // Continuous scrolling / spamming / quick flick - not settled on a reel yet
                    state.pendingSettle = true
                    return null
                }

                if (now - state.lastCountedReelTime < timing.debounceMs) {
                    state.pendingSettle = true
                    return null
                }

                // If toIndex is valid and already counted, don't count duplicate
                if (event.toIndex >= 0 && event.toIndex == state.lastCountedIndex) {
                    return null
                }

                // Reel completed
                val dwell = now - state.currentReelStartTime
                state.lastCountedReelTime = now
                state.currentReelStartTime = now
                state.pendingSettle = false
                if (event.fromIndex >= 0) {
                    state.lastCountedIndex = event.fromIndex
                } else if (event.toIndex >= 0) {
                    state.lastCountedIndex = max(0, event.toIndex - 1)
                }

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
