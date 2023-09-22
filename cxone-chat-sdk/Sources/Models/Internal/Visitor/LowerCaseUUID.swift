import Foundation

/// Class for operating with UUID values to ensure that they are sent in lowercase format.
///
/// This is required because with Swift, all `UUID` values are uppercase and cannot be
/// changed while keeping the `UUID` type. Currently, the back end doesn't support these
/// uppercase values on certain events (visitor events), so this is done as a workaround.
struct LowerCaseUUID {

    // MARK: - Properties

    let uuid: UUID

    // MARK: - Init

    init(uuid: UUID = UUID()) {
        self.uuid = UUID(uuidString: uuid.uuidString.lowercased()) ?? uuid
    }
}

// MARK: - Codable

extension LowerCaseUUID: Codable {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()

        self.uuid = try values.decode(UUID.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.uuid.uuidString.lowercased())
    }
}
