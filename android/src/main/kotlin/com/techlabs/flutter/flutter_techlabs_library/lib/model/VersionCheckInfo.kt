package com.techlabs.flutter.flutter_techlabs_library.lib.model

/**
 * 서버에서 내려온 버전 체크 응답 데이터 모델.
 */
data class VersionCheckInfo(
    val ver: String,
    val latestVer: String,
    val type: String,
    val appName2: String
) {
    companion object {
        fun fromMap(map: Map<String, Any?>): VersionCheckInfo {
            return VersionCheckInfo(
                ver = (map["ver"] as? String) ?: "",
                latestVer = (map["latest_ver"] as? String) ?: "",
                type = (map["type"] as? String) ?: "",
                appName2 = (map["app_name2"] as? String) ?: ""
            )
        }

        fun fromJsonString(json: String): VersionCheckInfo {
            val jsonObject = org.json.JSONObject(json)
            return VersionCheckInfo(
                ver = jsonObject.optString("ver", ""),
                latestVer = jsonObject.optString("latest_ver", ""),
                type = jsonObject.optString("type", ""),
                appName2 = jsonObject.optString("app_name2", "")
            )
        }
    }
}
