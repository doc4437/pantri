//
//  PantryRestockEntry.swift
//  Pantri
//
//  Created by Codex on 4/2/26.
//

import Foundation

struct PantryRestockEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var itemID: UUID
    var addedAt: Date
    var note: String?

    init(id: UUID = UUID(), itemID: UUID, addedAt: Date = .now, note: String? = nil) {
        self.id = id
        self.itemID = itemID
        self.addedAt = addedAt
        self.note = note
    }
}
