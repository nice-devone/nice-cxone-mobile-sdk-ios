import Foundation

struct ProactiveEventDTO {

    // MARK: - Properties

    let id: UUID
    let name: String
    let type: ActionType
}

// MARK: - Mapper

extension ProactiveEventDTO {
    init(from: ProactiveActionDetails) {
        id = from.id
        name = from.name
        type = from.type
    }
}

// MARK: - Encodable

extension ProactiveEventDTO: Encodable {
    enum CodingKeys: String, CodingKey {
        case id = "actionId"
        case name = "actionName"
        case type = "actionType"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }
}
