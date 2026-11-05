package com.oloz.oloz.reel

import org.json.JSONObject

data class ReelAppConfig(
    val label: String,
    val surfaceMarkers: List<String>,
    val pagerClassHints: List<String>
)

data class ReelDetectorTiming(
    val minDwellMs: Long = 700L,
    val debounceMs: Long = 500L
)

data class ReelDetectorsConfig(
    val version: Int,
    val apps: Map<String, ReelAppConfig>,
    val timing: ReelDetectorTiming
) {
    companion object {
        fun fromJson(jsonString: String): ReelDetectorsConfig {
            val root = JSONObject(jsonString)
            val version = root.optInt("version", 1)

            val timingObj = root.optJSONObject("timing")
            val timing = ReelDetectorTiming(
                minDwellMs = timingObj?.optLong("minDwellMs", 700L) ?: 700L,
                debounceMs = timingObj?.optLong("debounceMs", 500L) ?: 500L
            )

            val appsMap = mutableMapOf<String, ReelAppConfig>()
            val appsObj = root.optJSONObject("apps")
            if (appsObj != null) {
                val keys = appsObj.keys()
                while (keys.hasNext()) {
                    val pkg = keys.next()
                    val appObj = appsObj.getJSONObject(pkg)
                    val label = appObj.optString("label", pkg)

                    val markersArr = appObj.optJSONArray("surfaceMarkers")
                    val markers = mutableListOf<String>()
                    if (markersArr != null) {
                        for (i in 0 until markersArr.length()) {
                            markers.add(markersArr.getString(i))
                        }
                    }

                    val hintsArr = appObj.optJSONArray("pagerClassHints")
                    val hints = mutableListOf<String>()
                    if (hintsArr != null) {
                        for (i in 0 until hintsArr.length()) {
                            hints.add(hintsArr.getString(i))
                        }
                    }

                    appsMap[pkg] = ReelAppConfig(
                        label = label,
                        surfaceMarkers = markers,
                        pagerClassHints = hints
                    )
                }
            }

            return ReelDetectorsConfig(version, appsMap, timing)
        }
    }
}

