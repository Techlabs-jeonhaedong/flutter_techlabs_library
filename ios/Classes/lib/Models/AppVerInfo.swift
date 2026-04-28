import Foundation

/// S3 서비스 JSON의 appVerInfo 배열 항목 모델.
struct AppVerInfo: Decodable {
    let device: String
    let appName: String
    let ver: String
    let type: String
    let appName2: String
    let latestVer: String

    private enum CodingKeys: String, CodingKey {
        case device
        case appName = "app_name"
        case ver
        case type
        case appName2 = "app_name2"
        case latestVer = "latest_ver"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.device = (try? container.decode(String.self, forKey: .device)) ?? ""
        self.appName = (try? container.decode(String.self, forKey: .appName)) ?? ""
        self.ver = (try? container.decode(String.self, forKey: .ver)) ?? ""
        self.type = (try? container.decode(String.self, forKey: .type)) ?? "0"
        self.appName2 = (try? container.decode(String.self, forKey: .appName2)) ?? ""
        self.latestVer = (try? container.decode(String.self, forKey: .latestVer)) ?? ""
    }

    init(device: String, appName: String, ver: String, type: String, appName2: String, latestVer: String) {
        self.device = device
        self.appName = appName
        self.ver = ver
        self.type = type
        self.appName2 = appName2
        self.latestVer = latestVer
    }

    /// AppVerInfo를 VersionCheckInfo로 변환한다.
    func toVersionCheckInfo() -> VersionCheckInfo {
        return VersionCheckInfo(ver: ver, latestVer: latestVer, type: type, appName2: appName2)
    }
}
