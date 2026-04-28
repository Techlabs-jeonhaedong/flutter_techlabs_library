import Foundation

/// 서버 환경을 구분하는 열거형.
enum ServerEnvironment {
    case development
    case production
}

/// `fetchServiceInfo` 관련 에러.
enum ServiceFetcherError: Error {
    case missingServiceURL
}

/// 라이브러리 전역 진입점.
final class TechLabsLibrary {

    static let shared = TechLabsLibrary()

    private let queue = DispatchQueue(label: "com.techlabs.library.identifier")
    private var _appIdentifier: String?
    private var _environment: ServerEnvironment = .production
    private var _lastServiceInfo: ServiceInfo?

    private static let updateTypeForce = "0"
    private static let updateTypeOptional = "1"

    var appIdentifier: String? {
        queue.sync { _appIdentifier }
    }

    var lastServiceInfo: ServiceInfo? { queue.sync { _lastServiceInfo } }

    var serviceURL: URL? {
        queue.sync {
            guard let identifier = _appIdentifier else { return nil }
            return Self.resolveServiceURL(appIdentifier: identifier, environment: _environment)
        }
    }

    private init() {}

    func configure(appIdentifier: String, environment: ServerEnvironment) {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-_"))
        guard !appIdentifier.isEmpty,
              appIdentifier.unicodeScalars.allSatisfy({ allowed.contains($0) }),
              !appIdentifier.contains("..") else {
            return
        }
        queue.sync {
            _appIdentifier = appIdentifier
            _environment = environment
            _lastServiceInfo = nil
        }
    }

    func clearCache() {
        queue.sync {
            _lastServiceInfo = nil
        }
    }

    private static func resolveServiceURL(appIdentifier: String, environment: ServerEnvironment) -> URL? {
        let urlMap: [String: (dev: String, prod: String)] = [
            "techlabs.global.yeppo": (
                dev: "https://status.yeppo.net/dev-yeppo-service.json",
                prod: "https://status.yeppo.net/www-yeppo-service.json"
            )
        ]
        guard let urls = urlMap[appIdentifier] else { return nil }
        let rawURL = environment == .development ? urls.dev : urls.prod
        return URL(string: rawURL)
    }

    // MARK: - 버전 체크

    func checkVersion(info: VersionCheckInfo?, currentVersion: String) -> VersionCheckResult {
        guard let info = info else { return .error }
        guard !info.ver.isEmpty else { return .noUpdateNeeded }
        let isUpdateRequired = VersionComparator.isUpdateRequired(
            serverVersion: info.ver,
            currentVersion: currentVersion
        )
        return resolveResult(isUpdateRequired: isUpdateRequired, info: info)
    }

    func checkVersion(dictionary: [String: Any]?, currentVersion: String) -> VersionCheckResult {
        guard let dictionary = dictionary else { return .error }
        let info = VersionCheckInfo(dictionary: dictionary)
        return checkVersion(info: info, currentVersion: currentVersion)
    }

    private func resolveResult(isUpdateRequired: Bool, info: VersionCheckInfo) -> VersionCheckResult {
        guard isUpdateRequired else { return .noUpdateNeeded }
        switch info.type {
        case Self.updateTypeForce:
            return .forceUpdate(storePackage: info.appName2)
        case Self.updateTypeOptional:
            return .optionalUpdate(storePackage: info.appName2)
        default:
            return .error
        }
    }

    // MARK: - 서비스 정보 fetch

    @available(iOS 15.0, *)
    func fetchServiceInfo(url: URL) async throws -> ServiceInfo {
        let (data, _) = try await URLSession.shared.data(from: url)
        let serviceInfo = try JSONDecoder().decode(ServiceInfo.self, from: data)
        queue.sync {
            _lastServiceInfo = serviceInfo
        }
        return serviceInfo
    }

    @available(iOS 15.0, *)
    func fetchServiceInfo() async throws -> ServiceInfo {
        guard let url = serviceURL else {
            throw ServiceFetcherError.missingServiceURL
        }
        return try await fetchServiceInfo(url: url)
    }

    // MARK: - 공지사항 체크

    func checkNotice(info: NoticeCheckInfo?, lastSeenIndex: Int) -> NoticeCheckResult {
        guard let info = info else { return .error }
        guard !info.ntcLastIdx.isEmpty, let serverIndex = Int(info.ntcLastIdx) else {
            return .noNewNotice
        }
        if serverIndex > lastSeenIndex {
            return .hasNewNotice(latestIndex: serverIndex)
        }
        return .noNewNotice
    }

    func checkNotice(dictionary: [String: Any]?, lastSeenIndex: Int) -> NoticeCheckResult {
        guard let dictionary = dictionary else { return .error }
        let info = NoticeCheckInfo(dictionary: dictionary)
        return checkNotice(info: info, lastSeenIndex: lastSeenIndex)
    }

    // MARK: - 버전 비교

    func isUpdateRequired(serverVersion: String, currentVersion: String) -> Bool {
        return VersionComparator.isUpdateRequired(serverVersion: serverVersion, currentVersion: currentVersion)
    }
}
