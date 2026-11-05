package com.oloz.oloz.tracking

data class AppSessionData(
    val packageId: String,
    val appLabel: String,
    val startMs: Long,
    val endMs: Long,
    val day: String
) {
    val durationMs: Long get() = (endMs - startMs).coerceAtLeast(0)

    fun toMap(): Map<String, Any> = mapOf(
        "package" to packageId,
        "label" to appLabel,
        "startMs" to startMs,
        "endMs" to endMs,
        "day" to day,
        "durationMs" to durationMs
    )
}

data class AppSummaryData(
    val packageId: String,
    val appLabel: String,
    val category: String,
    val foregroundMs: Long,
    val opens: Int,
    val isShortVideo: Boolean
) {
    fun toMap(): Map<String, Any> = mapOf(
        "package" to packageId,
        "label" to appLabel,
        "category" to category,
        "foregroundMs" to foregroundMs,
        "opens" to opens,
        "isShortVideo" to isShortVideo
    )
}

data class TrackingEventData(
    val packageId: String,
    val eventType: String,
    val timestampMs: Long
) {
    fun toMap(): Map<String, Any> = mapOf(
        "package" to packageId,
        "eventType" to eventType,
        "timestampMs" to timestampMs
    )
}

