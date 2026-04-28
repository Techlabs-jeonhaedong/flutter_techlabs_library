import Foundation

/// S3 서비스 JSON 최상위 응답 모델.
struct ServiceInfo: Decodable {
    let domain: String
    let maintenance: String
    let message: String
    let title: String
    let appAction: String
    let appVerInfo: [AppVerInfo]

    private enum CodingKeys: String, CodingKey {
        case domain
        case maintenance
        case message
        case title
        case appAction
        case appVerInfo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domain = (try? container.decode(String.self, forKey: .domain)) ?? ""
        self.maintenance = (try? container.decode(String.self, forKey: .maintenance)) ?? "N"
        self.message = (try? container.decode(String.self, forKey: .message)) ?? ""
        self.title = (try? container.decode(String.self, forKey: .title)) ?? ""
        self.appAction = (try? container.decode(String.self, forKey: .appAction)) ?? ""
        self.appVerInfo = (try? container.decode([AppVerInfo].self, forKey: .appVerInfo)) ?? []
    }

    init(
        domain: String,
        maintenance: String,
        message: String,
        title: String,
        appAction: String,
        appVerInfo: [AppVerInfo]
    ) {
        self.domain = domain
        self.maintenance = maintenance
        self.message = message
        self.title = title
        self.appAction = appAction
        self.appVerInfo = appVerInfo
    }

    var isUnderMaintenance: Bool {
        return maintenance == "Y"
    }

    var iosAppVerInfo: AppVerInfo? {
        return appVerInfo.first { $0.device == "ios" }
    }

    var androidAppVerInfo: AppVerInfo? {
        return appVerInfo.first { $0.device == "android" }
    }
}
