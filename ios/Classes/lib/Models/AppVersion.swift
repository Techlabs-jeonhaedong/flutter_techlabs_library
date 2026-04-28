import Foundation

/// x.y.z 형식의 버전 문자열을 파싱하여 비교 가능한 모델로 변환한다.
/// 1~3 세그먼트를 지원하며, 부족한 세그먼트는 0으로 채운다.
struct AppVersion: Comparable, Equatable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int

    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// "x.y.z" 형식의 문자열로부터 AppVersion을 생성한다.
    /// 빈 문자열이면 0.0.0을 반환한다.
    init(string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            self.major = 0
            self.minor = 0
            self.patch = 0
            return
        }

        let parts = trimmed.split(separator: ".").map { String($0) }
        self.major = Int(parts[safe: 0] ?? "0") ?? 0
        self.minor = Int(parts[safe: 1] ?? "0") ?? 0
        self.patch = Int(parts[safe: 2] ?? "0") ?? 0
    }

    var description: String {
        "\(major).\(minor).\(patch)"
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

// MARK: - Array Safe Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
