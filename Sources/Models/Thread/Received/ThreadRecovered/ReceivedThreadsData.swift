import Foundation

public struct ReceivedThreadsData: Codable {
    let threads: [ReceivedThreadData]?

    enum CodingKeys: String, CodingKey {
        case threads = "threads"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        threads = try values.decodeIfPresent([ReceivedThreadData].self, forKey: .threads)
    }
}
