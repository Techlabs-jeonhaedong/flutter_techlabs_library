package com.techlabs.flutter.flutter_techlabs_library.lib.model

/**
 * 공지사항 체크 결과를 나타내는 sealed class.
 */
sealed class NoticeCheckResult {
    data class HasNewNotice(val latestIndex: Int) : NoticeCheckResult()
    data object NoNewNotice : NoticeCheckResult()
    data object Error : NoticeCheckResult()
}
