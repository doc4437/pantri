import Foundation

enum PromptBuilder {
    static func build(from categories: [PantryCategory]) -> String {
        let selectedCategories = categories.compactMap { category -> String? in
            let selectedItems = category.items.filter { $0.isSelected }
            guard !selectedItems.isEmpty else { return nil }

            let itemList = selectedItems.map { "- \($0.name)" }.joined(separator: "\n")
            return "\(category.name)\n\(itemList)"
        }

        guard !selectedCategories.isEmpty else {
            return "No pantry items selected."
        }

        return [
            "Pantri restock list:",
            "",
            selectedCategories.joined(separator: "\n\n"),
            "",
            "Please help me restock these items."
        ]
        .joined(separator: "\n")
    }

    static func build(from categories: [PantryCategory], queuedItemIDs: Set<UUID>) -> String {
        let selectedCategories = categories.compactMap { category -> String? in
            let selectedItems = category.items.filter { queuedItemIDs.contains($0.id) }
            guard !selectedItems.isEmpty else { return nil }

            let itemList = selectedItems.map { "- \($0.name)" }.joined(separator: "\n")
            return "\(category.name)\n\(itemList)"
        }

        guard !selectedCategories.isEmpty else {
            return "No pantry items selected."
        }

        return [
            "Pantri restock list:",
            "",
            selectedCategories.joined(separator: "\n\n"),
            "",
            "Please help me restock these items."
        ]
        .joined(separator: "\n")
    }
}
