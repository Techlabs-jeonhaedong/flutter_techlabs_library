import Foundation

/// 버전 체크 결과를 나타내는 enum.
enum VersionCheckResult: Equatable {
    /// 강제 업데이트 필요 (type="0")
    case forceUpdate(storePackage: String)
    /// 선택 업데이트 가능 (type="1")
    case optionalUpdate(storePackage: String)
    /// 업데이트 불필요
    case noUpdateNeeded
    /// 에러 (info가 nil인 경우 등)
    case error

    var callbackCode: Int {
        switch self {
        case .noUpdateNeeded: return 0
        case .forceUpdate: return 1
        case .optionalUpdate: return 2
        case .error: return 3
        }
    }
}
