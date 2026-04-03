import Foundation

struct PantryItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isSelected: Bool
    var sortOrder: Int
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        isSelected: Bool = false,
        sortOrder: Int = 0,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
        self.sortOrder = sortOrder
        self.isArchived = isArchived
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isSelected
        case sortOrder
        case isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isSelected = try container.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(isArchived, forKey: .isArchived)
    }
}
