package com.techlabs.flutter.flutter_techlabs_library.lib.model

import org.json.JSONArray
import org.json.JSONObject

/**
 * S3 서비스 정보 JSON 최상위 모델.
 */
data class ServiceInfo(
    val domain: String,
    val maintenance: String,
    val message: String,
    val title: String,
    val appAction: String,
    val appVerInfo: List<AppVerInfo>
) {
    val isUnderMaintenance: Boolean
        get() = maintenance == "Y"

    val androidAppVerInfo: AppVerInfo?
        get() = appVerInfo.firstOrNull { it.device == "android" }

    val iosAppVerInfo: AppVerInfo?
        get() = appVerInfo.firstOrNull { it.device == "ios" }

    companion object {
        fun fromJsonString(json: String): ServiceInfo {
            val jsonObject = JSONObject(json)
            val appVerInfoArray: JSONArray = jsonObject.optJSONArray("appVerInfo") ?: JSONArray()
            val appVerInfoList = (0 until appVerInfoArray.length()).map { i ->
                AppVerInfo.fromJsonObject(appVerInfoArray.getJSONObject(i))
            }
            return ServiceInfo(
                domain = jsonObject.optString("domain", ""),
                maintenance = jsonObject.optString("maintenance", "N"),
                message = jsonObject.optString("message", ""),
                title = jsonObject.optString("title", ""),
                appAction = jsonObject.optString("appAction", ""),
                appVerInfo = appVerInfoList
            )
        }
    }
}
