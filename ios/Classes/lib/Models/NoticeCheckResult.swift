import Foundation

/// 공지사항 체크 결과를 나타내는 enum.
enum NoticeCheckResult: Equatable {
    /// 새 공지사항이 있음
    case hasNewNotice(latestIndex: Int)
    /// 새 공지사항 없음
    case noNewNotice
    /// 에러 (info가 nil인 경우 등)
    case error
}
