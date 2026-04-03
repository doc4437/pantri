import Foundation
import Combine

@MainActor
final class PantryStore: ObservableObject {
    @Published private(set) var categories: [PantryCategory]
    @Published private(set) var restockEntries: [PantryRestockEntry]

    private let defaults: UserDefaults
    private let snapshotStorageKey = "Pantri.PantryStore.snapshot.v2"
    private let legacyCategoriesStorageKey = "Pantri.PantryStore.categories"

    var selectedCount: Int {
        restockEntries.count
    }

    var sortedCategories: [PantryCategory] {
        categories
    }

    var restockCount: Int {
        selectedCount
    }

    var hasRestockItems: Bool {
        restockEntries.isEmpty == false
    }

    var queuedItemIDs: Set<UUID> {
        Set(restockEntries.map(\.itemID))
    }

    var selectedItemsByCategory: [PantryCategory] {
        categories.compactMap { category in
            let selectedItems = category.items.filter { queuedItemIDs.contains($0.id) }
            guard !selectedItems.isEmpty else { return nil }
            return PantryCategory(
                id: category.id,
                name: category.name,
                sortOrder: category.sortOrder,
                isArchived: category.isArchived,
                items: selectedItems
            )
        }
    }

    var promptText: String {
        PromptBuilder.build(from: categories, queuedItemIDs: queuedItemIDs)
    }

    var restockPrompt: String {
        promptText
    }

    var items: [PantryItem] {
        categories.flatMap(\.items)
    }

    var restockSections: [RestockSection] {
        categories.compactMap { category in
            let queuedItems = category.items.filter { queuedItemIDs.contains($0.id) }
            guard queuedItems.isEmpty == false else {
                return nil
            }
            return RestockSection(category: category, items: queuedItems)
        }
    }

    func generatedPrompt() -> String {
        promptText
    }

    func items(for categoryID: PantryCategory.ID) -> [PantryItem] {
        categories.first(where: { $0.id == categoryID })?.items ?? []
    }

    init(
        categories: [PantryCategory]? = nil,
        restockEntries: [PantryRestockEntry]? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults

        if let snapshot = Self.loadSnapshot(from: defaults, key: snapshotStorageKey) {
            self.categories = snapshot.categories
            self.restockEntries = snapshot.restockEntries
            normalizeAndSyncSelectionState()
            save()
            return
        }

        if let legacyCategories = Self.loadCategories(from: defaults, key: legacyCategoriesStorageKey) {
            self.categories = legacyCategories
            self.restockEntries = Self.makeRestockEntries(from: legacyCategories)
            normalizeAndSyncSelectionState()
            save()
            return
        }

        self.categories = categories ?? PantrySeed.categories
        self.restockEntries = restockEntries ?? []
        normalizeAndSyncSelectionState()
        save()
    }

    func toggleItem(categoryID: PantryCategory.ID, itemID: PantryItem.ID) {
        if queuedItemIDs.contains(itemID) {
            removeFromRestock(itemID: itemID)
        } else {
            addToRestock(categoryID: categoryID, itemID: itemID)
        }
    }

    func setSelection(categoryID: PantryCategory.ID, itemID: PantryItem.ID, isSelected: Bool) {
        if isSelected {
            addToRestock(categoryID: categoryID, itemID: itemID)
        } else {
            removeFromRestock(itemID: itemID)
        }
    }

    func clearSelection() {
        clearRestockQueue()
    }

    func selectedItems() -> [PantryItem] {
        categories.flatMap { $0.items.filter { queuedItemIDs.contains($0.id) } }
    }

    func addCategory(name: String) {
        let nextSortOrder = nextCategorySortOrder()
        categories.append(
            PantryCategory(
                name: name,
                sortOrder: nextSortOrder,
                items: []
            )
        )
        normalizeAndSyncSelectionState()
        save()
    }

    func renameCategory(id: PantryCategory.ID, name: String) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == id }) else { return }
        categories[categoryIndex].name = name
        save()
    }

    func renameCategory(categoryID: PantryCategory.ID, name: String) {
        renameCategory(id: categoryID, name: name)
    }

    @discardableResult
    func deleteCategory(id: PantryCategory.ID) -> Bool {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == id }) else { return false }
        guard categories[categoryIndex].items.isEmpty else { return false }
        let removedItemIDs = Set(categories[categoryIndex].items.map(\.id))
        categories.remove(at: categoryIndex)
        restockEntries.removeAll { removedItemIDs.contains($0.itemID) }
        normalizeAndSyncSelectionState()
        save()
        return true
    }

    @discardableResult
    func deleteCategory(categoryID: PantryCategory.ID) -> Bool {
        deleteCategory(id: categoryID)
    }

    func addItem(name: String, categoryID: PantryCategory.ID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        let nextSortOrder = nextItemSortOrder(in: categories[categoryIndex].items)
        categories[categoryIndex].items.append(
            PantryItem(
                name: name,
                sortOrder: nextSortOrder
            )
        )
        normalizeAndSyncSelectionState()
        save()
    }

    func renameItem(id: PantryItem.ID, name: String) {
        guard let location = locateItem(id: id) else { return }
        categories[location.categoryIndex].items[location.itemIndex].name = name
        save()
    }

    func updateItem(itemID: PantryItem.ID, name: String, categoryID: PantryCategory.ID) {
        guard locateItem(id: itemID) != nil else { return }
        renameItem(id: itemID, name: name)
        moveItem(id: itemID, toCategoryID: categoryID)
    }

    func deleteItem(id: PantryItem.ID) {
        guard let location = locateItem(id: id) else { return }
        categories[location.categoryIndex].items.remove(at: location.itemIndex)
        restockEntries.removeAll { $0.itemID == id }
        normalizeAndSyncSelectionState()
        save()
    }

    func deleteItem(itemID: PantryItem.ID) {
        deleteItem(id: itemID)
    }

    func moveItem(id: PantryItem.ID, toCategoryID: PantryCategory.ID) {
        guard let sourceLocation = locateItem(id: id),
              let destinationCategoryIndex = categories.firstIndex(where: { $0.id == toCategoryID }) else { return }

        let item = categories[sourceLocation.categoryIndex].items.remove(at: sourceLocation.itemIndex)
        let nextSortOrder = nextItemSortOrder(in: categories[destinationCategoryIndex].items)

        categories[destinationCategoryIndex].items.append(
            PantryItem(
                id: item.id,
                name: item.name,
                isSelected: item.isSelected,
                sortOrder: nextSortOrder,
                isArchived: item.isArchived
            )
        )

        normalizeAndSyncSelectionState()
        save()
    }

    func removeFromRestock(itemID: PantryItem.ID) {
        restockEntries.removeAll { $0.itemID == itemID }
        normalizeAndSyncSelectionState()
        save()
    }

    func toggleRestock(itemID: PantryItem.ID) {
        guard let location = locateItem(id: itemID) else { return }
        toggleItem(categoryID: categories[location.categoryIndex].id, itemID: itemID)
    }

    func clearRestockQueue() {
        restockEntries.removeAll()
        normalizeAndSyncSelectionState()
        save()
    }

    func resetToStarterPantry() {
        categories = PantrySeed.categories
        restockEntries.removeAll()
        normalizeAndSyncSelectionState()
        save()
    }

    private func addToRestock(categoryID: PantryCategory.ID, itemID: PantryItem.ID) {
        guard locateItem(categoryID: categoryID, itemID: itemID) != nil else { return }
        guard queuedItemIDs.contains(itemID) == false else { return }

        restockEntries.append(
            PantryRestockEntry(
                itemID: itemID,
                addedAt: .now
            )
        )
        normalizeAndSyncSelectionState()
        save()
    }

    private func normalizeAndSyncSelectionState() {
        categories.sort { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.sortOrder < rhs.sortOrder
        }

        for categoryIndex in categories.indices {
            categories[categoryIndex].items.sort { lhs, rhs in
                if lhs.sortOrder == rhs.sortOrder {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhs.sortOrder < rhs.sortOrder
            }
        }

        restockEntries = deduplicatedRestockEntries(restockEntries)
            .sorted { $0.addedAt < $1.addedAt }

        let queuedIDs = queuedItemIDs
        for categoryIndex in categories.indices {
            for itemIndex in categories[categoryIndex].items.indices {
                categories[categoryIndex].items[itemIndex].isSelected = queuedIDs.contains(categories[categoryIndex].items[itemIndex].id)
            }
        }

        renumberSortOrders()
    }

    private func renumberSortOrders() {
        for categoryIndex in categories.indices {
            categories[categoryIndex].sortOrder = categoryIndex
            for itemIndex in categories[categoryIndex].items.indices {
                categories[categoryIndex].items[itemIndex].sortOrder = itemIndex
            }
        }
    }

    private func save() {
        let snapshot = PantryStoreSnapshot(categories: categories, restockEntries: restockEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotStorageKey)
    }

    private func locateItem(categoryID: PantryCategory.ID, itemID: PantryItem.ID) -> (categoryIndex: Int, itemIndex: Int)? {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }),
              let itemIndex = categories[categoryIndex].items.firstIndex(where: { $0.id == itemID }) else {
            return nil
        }

        return (categoryIndex, itemIndex)
    }

    private func locateItem(id: PantryItem.ID) -> (categoryIndex: Int, itemIndex: Int)? {
        for categoryIndex in categories.indices {
            if let itemIndex = categories[categoryIndex].items.firstIndex(where: { $0.id == id }) {
                return (categoryIndex, itemIndex)
            }
        }

        return nil
    }

    private func nextCategorySortOrder() -> Int {
        (categories.map(\.sortOrder).max() ?? -1) + 1
    }

    private func nextItemSortOrder(in items: [PantryItem]) -> Int {
        (items.map(\.sortOrder).max() ?? -1) + 1
    }

    private func deduplicatedRestockEntries(_ entries: [PantryRestockEntry]) -> [PantryRestockEntry] {
        var latestByItemID: [UUID: PantryRestockEntry] = [:]

        for entry in entries {
            if let existing = latestByItemID[entry.itemID] {
                if entry.addedAt > existing.addedAt {
                    latestByItemID[entry.itemID] = entry
                }
            } else {
                latestByItemID[entry.itemID] = entry
            }
        }

        return latestByItemID.values.sorted { $0.addedAt < $1.addedAt }
    }

    private static func makeRestockEntries(from categories: [PantryCategory]) -> [PantryRestockEntry] {
        categories.flatMap { category in
            category.items.compactMap { item in
                item.isSelected ? PantryRestockEntry(itemID: item.id) : nil
            }
        }
    }

    private struct PantryStoreSnapshot: Codable {
        var categories: [PantryCategory]
        var restockEntries: [PantryRestockEntry]
    }

    private static func loadSnapshot(from defaults: UserDefaults, key: String) -> PantryStoreSnapshot? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PantryStoreSnapshot.self, from: data)
    }

    private static func loadCategories(from defaults: UserDefaults, key: String) -> [PantryCategory]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([PantryCategory].self, from: data)
    }
}

struct RestockSection: Identifiable, Hashable {
    var id: UUID { category.id }
    let category: PantryCategory
    let items: [PantryItem]
}
