import Foundation

struct PantryCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var sortOrder: Int
    var isArchived: Bool
    var items: [PantryItem]

    init(
        id: UUID = UUID(),
        name: String,
        sortOrder: Int = 0,
        isArchived: Bool = false,
        items: [PantryItem]
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.isArchived = isArchived
        self.items = items
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sortOrder
        case isArchived
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        items = try container.decode([PantryItem].self, forKey: .items)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(isArchived, forKey: .isArchived)
        try container.encode(items, forKey: .items)
    }
}
