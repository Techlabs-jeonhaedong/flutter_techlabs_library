import Foundation

/// 서버에서 내려온 공지사항 체크 응답 데이터 모델.
struct NoticeCheckInfo: Decodable {
    let ntcLastIdx: String

    private enum CodingKeys: String, CodingKey {
        case ntcLastIdx = "ntc_last_idx"
    }

    init(ntcLastIdx: String) {
        self.ntcLastIdx = ntcLastIdx
    }

    init(dictionary: [String: Any]) {
        self.ntcLastIdx = (dictionary["ntc_last_idx"] as? String) ?? ""
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ntcLastIdx = (try? container.decode(String.self, forKey: .ntcLastIdx)) ?? ""
    }
}
