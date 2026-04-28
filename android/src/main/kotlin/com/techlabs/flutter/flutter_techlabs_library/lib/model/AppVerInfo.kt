package com.techlabs.flutter.flutter_techlabs_library.lib.model

import org.json.JSONObject

/**
 * S3 서비스 정보 JSON의 appVerInfo 배열 항목 모델.
 */
data class AppVerInfo(
    val device: String,
    val appName: String,
    val ver: String,
    val type: String,
    val appName2: String,
    val latestVer: String
) {
    companion object {
        fun fromJsonObject(jsonObject: JSONObject): AppVerInfo {
            return AppVerInfo(
                device = jsonObject.optString("device", ""),
                appName = jsonObject.optString("app_name", ""),
                ver = jsonObject.optString("ver", ""),
                type = jsonObject.optString("type", ""),
                appName2 = jsonObject.optString("app_name2", ""),
                latestVer = jsonObject.optString("latest_ver", "")
            )
        }
    }

    fun toVersionCheckInfo(): VersionCheckInfo {
        return VersionCheckInfo(
            ver = ver,
            latestVer = latestVer,
            type = type,
            appName2 = appName2
        )
    }
}
