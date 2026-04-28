package com.techlabs.flutter.flutter_techlabs_library.lib.model

/**
 * x.y.z 형식의 버전 문자열을 파싱하여 비교 가능한 모델로 변환한다.
 * 1~3 세그먼트를 지원하며, 부족한 세그먼트는 0으로 채운다.
 */
data class AppVersion(
    val major: Int,
    val minor: Int,
    val patch: Int
) : Comparable<AppVersion> {

    override fun compareTo(other: AppVersion): Int {
        val majorCmp = major.compareTo(other.major)
        if (majorCmp != 0) return majorCmp

        val minorCmp = minor.compareTo(other.minor)
        if (minorCmp != 0) return minorCmp

        return patch.compareTo(other.patch)
    }

    override fun toString(): String = "$major.$minor.$patch"

    companion object {
        /**
         * "x.y.z" 형식의 문자열을 [AppVersion]으로 파싱한다.
         * 빈 문자열이면 0.0.0을 반환한다.
         */
        fun fromString(version: String): AppVersion {
            if (version.isBlank()) return AppVersion(0, 0, 0)

            val parts = version.trim().split(".")
            val major = parts.getOrNull(0)?.toIntOrNull() ?: 0
            val minor = parts.getOrNull(1)?.toIntOrNull() ?: 0
            val patch = parts.getOrNull(2)?.toIntOrNull() ?: 0
            return AppVersion(major, minor, patch)
        }
    }
}
