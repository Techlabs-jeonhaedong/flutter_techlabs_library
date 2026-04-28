package com.techlabs.flutter.flutter_techlabs_library.lib.model

/**
 * 서버에서 내려온 공지사항 체크 응답 데이터 모델.
 */
data class NoticeCheckInfo(
    val ntcLastIdx: String
) {
    companion object {
        fun fromMap(map: Map<String, Any?>): NoticeCheckInfo {
            return NoticeCheckInfo(
                ntcLastIdx = (map["ntc_last_idx"] as? String) ?: ""
            )
        }

        fun fromJsonString(json: String): NoticeCheckInfo {
            val jsonObject = org.json.JSONObject(json)
            return NoticeCheckInfo(
                ntcLastIdx = jsonObject.optString("ntc_last_idx", "")
            )
        }
    }
}
