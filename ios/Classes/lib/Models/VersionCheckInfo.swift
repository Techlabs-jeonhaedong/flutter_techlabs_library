import Foundation

/// 서버에서 내려온 버전 체크 응답 데이터 모델.
struct VersionCheckInfo: Decodable {
    let ver: String
    let latestVer: String
    let type: String
    let appName2: String

    private enum CodingKeys: String, CodingKey {
        case ver
        case latestVer = "latest_ver"
        case type
        case appName2 = "app_name2"
    }

    init(ver: String, latestVer: String, type: String, appName2: String) {
        self.ver = ver
        self.latestVer = latestVer
        self.type = type
        self.appName2 = appName2
    }

    init(dictionary: [String: Any]) {
        self.ver = (dictionary["ver"] as? String) ?? ""
        self.latestVer = (dictionary["latest_ver"] as? String) ?? ""
        self.type = (dictionary["type"] as? String) ?? ""
        self.appName2 = (dictionary["app_name2"] as? String) ?? ""
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ver = (try? container.decode(String.self, forKey: .ver)) ?? ""
        self.latestVer = (try? container.decode(String.self, forKey: .latestVer)) ?? ""
        self.type = (try? container.decode(String.self, forKey: .type)) ?? ""
        self.appName2 = (try? container.decode(String.self, forKey: .appName2)) ?? ""
    }
}
