package com.oloz.oloz.reel

data class AccessibilityEventModel(
    val packageName: String,
    val eventType: Int,
    val className: String?,
    val viewId: String?,
    val timestampMs: Long,
    val isFullScreenScroll: Boolean = false,
    val fromIndex: Int = -1,
    val toIndex: Int = -1,
    val itemCount: Int = -1
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "packageName" to packageName,
        "eventType" to eventType,
        "className" to className,
        "viewId" to viewId,
        "timestampMs" to timestampMs,
        "isFullScreenScroll" to isFullScreenScroll,
        "fromIndex" to fromIndex,
        "toIndex" to toIndex,
        "itemCount" to itemCount
    )
}

data class ReelDetectedEvent(
    val packageId: String,
    val dwellMs: Long,
    val timestampMs: Long,
    val confidence: String = "high" // "high" | "approx"
) {
    fun toMap(): Map<String, Any> = mapOf(
        "type" to "REEL_DETECTED",
        "package" to packageId,
        "dwellMs" to dwellMs,
        "timestampMs" to timestampMs,
        "confidence" to confidence
    )
}

