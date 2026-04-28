import Foundation

/// 버전 비교 유틸리티.
enum VersionComparator {

    /// x.y.z 문자열 버전 비교.
    /// 서버 버전이 현재 버전보다 크면 true를 반환한다.
    static func isUpdateRequired(serverVersion: String, currentVersion: String) -> Bool {
        guard !serverVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }

        let server = AppVersion(string: serverVersion)
        let current = AppVersion(string: currentVersion)
        return server > current
    }
}
