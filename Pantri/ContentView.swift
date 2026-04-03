//
//  ContentView.swift
//  Pantri
//
//  Created by Enso Direct Care on 4/2/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = PantryStore()
    @State private var isShowingRestockList = false
    @State private var isShowingManagePantry = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                pantriBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        ForEach(store.sortedCategories) { category in
                            PantryCategorySection(
                                title: category.name,
                                items: store.items(for: category.id),
                                onToggle: { itemID in
                                    store.toggleRestock(itemID: itemID)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 176)
                }

                footerBar
            }
            .toolbar {
                ToolbarItem(placement: pantriPrimaryToolbarPlacement) {
                    Button("Manage") {
                        isShowingManagePantry = true
                    }
                    .foregroundStyle(pantriInk)
                }
            }
            .sheet(isPresented: $isShowingRestockList) {
                RestockListView(store: store)
            }
            .sheet(isPresented: $isShowingManagePantry) {
                ManagePantryView(store: store)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pantri")
                        .font(.system(size: 42, weight: .regular, design: .serif))
                        .foregroundStyle(pantriInk)

                    Text("Tap once to keep anything on your running restock list until you are ready to order.")
                        .font(.subheadline)
                        .foregroundStyle(pantriMutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                CountBadge(count: store.restockCount)
            }

            HStack {
                Text("Pantry for Saturday")
                    .font(.caption)
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(pantriSoftInk)

                Spacer()

                Text(store.hasRestockItems ? "Restock list building" : "Tap items as they run out")
                    .font(.caption)
                    .foregroundStyle(pantriSoftInk)
            }
        }
    }

    private var footerBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your restock queue persists over time. Add milk today, garlic later, then send one combined list.")
                .font(.footnote)
                .foregroundStyle(pantriMutedInk)

            Button {
                isShowingRestockList = true
            } label: {
                Text("Restock List (\(store.restockCount))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(store.hasRestockItems == false)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(.clear)
                .background(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.35), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}

private struct PantryCategorySection: View {
    let title: String
    let items: [PantryItem]
    let onToggle: (PantryItem.ID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(pantriSoftInk)
                .padding(.bottom, 10)

            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                PantryItemRow(
                    title: item.name,
                    isQueued: item.isSelected,
                    isLast: index == items.count - 1
                ) {
                    onToggle(item.id)
                }
            }
        }
    }
}

private struct PantryItemRow: View {
    let title: String
    let isQueued: Bool
    let isLast: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(pantriInk)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isQueued ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(isQueued ? pantriCheck : pantriDivider)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                if isLast == false {
                    Rectangle()
                        .fill(pantriDivider.opacity(0.6))
                        .frame(height: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct CountBadge: View {
    let count: Int

    var body: some View {
        Text("\(count) queued")
            .font(.footnote.weight(.medium))
            .foregroundStyle(pantriBadgeInk)
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(
                Capsule(style: .continuous)
                    .fill(pantriBadgeFill)
            )
    }
}

private struct RestockListView: View {
    @ObservedObject var store: PantryStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Restock List")
                            .font(.system(size: 38, weight: .regular, design: .serif))
                            .foregroundStyle(pantriInk)

                        Text("This queue stays intact until you remove items or clear it after ordering.")
                            .font(.subheadline)
                            .foregroundStyle(pantriMutedInk)
                    }

                    if store.restockSections.isEmpty {
                        EmptyStateCard(
                            title: "Nothing queued yet",
                            message: "Go back to the pantry and tap ingredients as they run out."
                        )
                    } else {
                        ForEach(store.restockSections) { section in
                            VStack(alignment: .leading, spacing: 0) {
                                Text(section.category.name)
                                    .font(.caption)
                                    .tracking(2)
                                    .textCase(.uppercase)
                                    .foregroundStyle(pantriSoftInk)
                                    .padding(.bottom, 10)

                                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                                    HStack(spacing: 14) {
                                        Text(item.name)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundStyle(pantriInk)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Button {
                                            store.removeFromRestock(itemID: item.id)
                                        } label: {
                                            Image(systemName: "minus.circle")
                                                .font(.system(size: 22))
                                                .foregroundStyle(pantriMutedInk)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 14)
                                    .overlay(alignment: .bottom) {
                                        if index != section.items.count - 1 {
                                            Rectangle()
                                                .fill(pantriDivider.opacity(0.6))
                                                .frame(height: 1)
                                        }
                                    }
                                }
                            }
                        }

                        Text(store.restockPrompt)
                            .font(.body)
                            .foregroundStyle(pantriInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.white.opacity(0.55))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(pantriDivider.opacity(0.7))
                            )
                    }
                }
                .padding(24)
                .padding(.bottom, 140)
            }
            .background(pantriBackground)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    ShareLink(
                        item: store.restockPrompt,
                        preview: SharePreview("Pantri Restock List")
                    ) {
                        Text("Share Restock Text")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(store.hasRestockItems == false)

                    Button("Clear Restock List") {
                        store.clearRestockQueue()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(store.hasRestockItems == false)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(.ultraThinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: pantriPrimaryToolbarPlacement) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(pantriInk)
                }
            }
        }
    }
}

private struct ManagePantryView: View {
    @ObservedObject var store: PantryStore
    @Environment(\.dismiss) private var dismiss

    @State private var categoryDraft = ""
    @State private var editingCategory: PantryCategory?
    @State private var editingItem: ItemEditorState?
    @State private var categoryPendingDeleteError = false
    @State private var showingResetStarterPantry = false
    @FocusState private var isCategoryFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                pantriBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Manage Pantry")
                                .font(.system(size: 38, weight: .regular, design: .serif))
                                .foregroundStyle(pantriInk)

                            Text("Add categories, edit item names, and keep your starter pantry close by when you need a reset.")
                                .font(.subheadline)
                                .foregroundStyle(pantriMutedInk)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Starter Pantry")
                                .font(.caption)
                                .tracking(2)
                                .textCase(.uppercase)
                                .foregroundStyle(pantriSoftInk)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Restores the built-in pantry categories and items, and clears the current restock queue.")
                                    .font(.footnote)
                                    .foregroundStyle(pantriMutedInk)

                                Button(role: .destructive) {
                                    showingResetStarterPantry = true
                                } label: {
                                    Text("Reset to Starter Pantry")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                            .padding(18)
                            .background(cardBackground)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Category")
                                .font(.caption)
                                .tracking(2)
                                .textCase(.uppercase)
                                .foregroundStyle(pantriSoftInk)

                            VStack(spacing: 12) {
                                TextField("New category", text: $categoryDraft)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color.white.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .strokeBorder(pantriDivider.opacity(0.75))
                                            )
                                    )
                                    .focused($isCategoryFieldFocused)

                                Button {
                                    store.addCategory(name: categoryDraft)
                                    categoryDraft = ""
                                    isCategoryFieldFocused = false
                                } label: {
                                    Text("Add Category")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(categoryDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(18)
                            .background(cardBackground)
                        }

                        ForEach(store.sortedCategories) { category in
                            ManageCategoryCard(
                                category: category,
                                items: store.items(for: category.id),
                                onEditCategory: {
                                    editingCategory = category
                                },
                                onDeleteCategory: {
                                    if store.deleteCategory(categoryID: category.id) == false {
                                        categoryPendingDeleteError = true
                                    }
                                },
                                onEditItem: { item in
                                    editingItem = ItemEditorState(
                                        itemID: item.id,
                                        initialName: item.name,
                                        selectedCategoryID: category.id
                                    )
                                },
                                onDeleteItem: { item in
                                    store.deleteItem(itemID: item.id)
                                },
                                onAddItem: {
                                    editingItem = ItemEditorState(itemID: nil, initialName: "", selectedCategoryID: category.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 32)
                }
            }
            .pantriInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: pantriPrimaryToolbarPlacement) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(category: category) { updatedName in
                    store.renameCategory(categoryID: category.id, name: updatedName)
                }
            }
            .sheet(item: $editingItem) { item in
                EditItemView(
                    editorState: item,
                    categories: store.sortedCategories
                ) { name, categoryID in
                    if let itemID = item.itemID {
                        store.updateItem(itemID: itemID, name: name, categoryID: categoryID)
                    } else {
                        store.addItem(name: name, categoryID: categoryID)
                    }
                }
            }
            .alert("Category must be empty before deleting.", isPresented: $categoryPendingDeleteError) {
                Button("OK", role: .cancel) {}
            }
            .alert("Reset to starter pantry?", isPresented: $showingResetStarterPantry) {
                Button("Reset", role: .destructive) {
                    store.resetToStarterPantry()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will replace your current pantry categories and items with the built-in starter pantry and clear any queued restock items.")
            }
        }
    }
}

private struct ManageCategoryCard: View {
    let category: PantryCategory
    let items: [PantryItem]
    let onEditCategory: () -> Void
    let onDeleteCategory: () -> Void
    let onEditItem: (PantryItem) -> Void
    let onDeleteItem: (PantryItem) -> Void
    let onAddItem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(pantriInk)

                    Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(pantriSoftInk)
                }

                Spacer()

                Button("Edit") {
                    onEditCategory()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(pantriMutedInk)
            }

            if items.isEmpty {
                Text("No items here yet.")
                    .font(.subheadline)
                    .foregroundStyle(pantriMutedInk)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.name)
                                    .font(.body)
                                    .foregroundStyle(pantriInk)

                                if item.isSelected {
                                    Text("Queued for restock")
                                        .font(.caption)
                                        .foregroundStyle(pantriSoftInk)
                                }
                            }

                            Spacer()

                            Button("Edit") {
                                onEditItem(item)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(pantriMutedInk)

                            Button("Delete") {
                                onDeleteItem(item)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red.opacity(0.8))
                        }
                        .padding(.vertical, 12)

                        if index != items.count - 1 {
                            Rectangle()
                                .fill(pantriDivider.opacity(0.55))
                                .frame(height: 1)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    onAddItem()
                } label: {
                    Text("Add Item")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())

                if items.isEmpty {
                    Button(role: .destructive) {
                        onDeleteCategory()
                    } label: {
                        Text("Delete Category")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(18)
        .background(cardBackground)
    }
}

private struct EditCategoryView: View {
    let category: PantryCategory
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    init(category: PantryCategory, onSave: @escaping (String) -> Void) {
        self.category = category
        self.onSave = onSave
        _name = State(initialValue: category.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Category name", text: $name)
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct EditItemView: View {
    let editorState: ItemEditorState
    let categories: [PantryCategory]
    let onSave: (String, PantryCategory.ID) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var selectedCategoryID: PantryCategory.ID

    init(editorState: ItemEditorState, categories: [PantryCategory], onSave: @escaping (String, PantryCategory.ID) -> Void) {
        self.editorState = editorState
        self.categories = categories
        self.onSave = onSave
        _name = State(initialValue: editorState.initialName)
        _selectedCategoryID = State(initialValue: editorState.selectedCategoryID)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)

                Picker("Category", selection: $selectedCategoryID) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
            }
            .navigationTitle(editorState.itemID == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, selectedCategoryID)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct ItemEditorState: Identifiable {
    let id = UUID()
    let itemID: PantryItem.ID?
    let initialName: String
    let selectedCategoryID: PantryCategory.ID
}

private struct EmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(pantriInk)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(pantriMutedInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(pantriDivider.opacity(0.7))
        )
    }
}

private var cardBackground: some View {
    RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(Color.white.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(pantriDivider.opacity(0.7))
        )
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color(red: 0.97, green: 0.96, blue: 0.94))
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background(
                Capsule(style: .continuous)
                    .fill(pantriInk.opacity(configuration.isPressed ? 0.88 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(pantriInk)
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.45 : 0.62))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(pantriDivider.opacity(0.8))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private let pantriInk = Color(red: 0.16, green: 0.14, blue: 0.11)
private let pantriMutedInk = Color(red: 0.48, green: 0.44, blue: 0.39)
private let pantriSoftInk = Color(red: 0.56, green: 0.51, blue: 0.45)
private let pantriDivider = Color(red: 0.74, green: 0.69, blue: 0.62)
private let pantriCheck = Color(red: 0.49, green: 0.45, blue: 0.40)
private let pantriBadgeFill = Color(red: 0.87, green: 0.83, blue: 0.77)
private let pantriBadgeInk = Color(red: 0.33, green: 0.28, blue: 0.23)

private var pantriBackground: some View {
    LinearGradient(
        colors: [
            Color(red: 0.97, green: 0.96, blue: 0.94),
            Color(red: 0.95, green: 0.93, blue: 0.89)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    .ignoresSafeArea()
}

private var pantriPrimaryToolbarPlacement: ToolbarItemPlacement {
#if os(macOS)
    .automatic
#else
    .topBarTrailing
#endif
}

private extension View {
    @ViewBuilder
    func pantriInlineNavigationTitle() -> some View {
#if os(macOS)
        self
#else
        navigationBarTitleDisplayMode(.inline)
#endif
    }

    @ViewBuilder
    func pantriGroupedListStyle() -> some View {
#if os(macOS)
        listStyle(.automatic)
#else
        listStyle(.insetGrouped)
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
