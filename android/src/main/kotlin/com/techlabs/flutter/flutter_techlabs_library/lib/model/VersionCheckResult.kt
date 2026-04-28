package com.techlabs.flutter.flutter_techlabs_library.lib.model

/**
 * 버전 체크 결과를 나타내는 sealed class.
 *
 * - [ForceUpdate] → callbackCode 1
 * - [OptionalUpdate] → callbackCode 2
 * - [NoUpdateNeeded] → callbackCode 0
 * - [Error] → callbackCode 3
 */
sealed class VersionCheckResult {
    abstract val callbackCode: Int

    data class ForceUpdate(val storePackage: String) : VersionCheckResult() {
        override val callbackCode: Int = 1
    }

    data class OptionalUpdate(val storePackage: String) : VersionCheckResult() {
        override val callbackCode: Int = 2
    }

    data object NoUpdateNeeded : VersionCheckResult() {
        override val callbackCode: Int = 0
    }

    data object Error : VersionCheckResult() {
        override val callbackCode: Int = 3
    }
}
