import SwiftUI
import SwiftData

struct EditProtocolSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ProtocolSection.sortOrder) private var sections: [ProtocolSection]

    // Expansion
    @State private var expandedSections: Set<String> = []

    // Delete confirmation — sections
    @State private var sectionToDelete: ProtocolSection? = nil
    @State private var showDeleteSectionAlert = false

    // Delete confirmation — items
    @State private var itemToDelete: ProtocolItem? = nil
    @State private var itemSectionForDelete: ProtocolSection? = nil
    @State private var showDeleteItemAlert = false

    // Add item inline
    @State private var addingToSectionID: String? = nil
    @State private var newItemDraft = ""
    @FocusState private var newItemFocused: Bool

    // Add section inline
    @State private var isAddingSection = false
    @State private var newSectionDraft = ""
    @FocusState private var newSectionFocused: Bool

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section(
                        isExpanded: expandedBinding(for: section)
                    ) {
                        itemRows(for: section)
                    } header: {
                        sectionHeader(section)
                    }
                }

                addSectionRow
            }
            .scrollContentBackground(.hidden)
            .background(StackTheme.Background.elevated)
            .navigationTitle("Edit Protocol")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, .constant(.active))
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Section?", isPresented: $showDeleteSectionAlert) {
                Button("Delete", role: .destructive) {
                    if let s = sectionToDelete { modelContext.delete(s) }
                    sectionToDelete = nil
                }
                Button("Cancel", role: .cancel) { sectionToDelete = nil }
            } message: {
                Text("This will permanently delete the section and all its items.")
            }
            .alert("Delete Item?", isPresented: $showDeleteItemAlert) {
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete, let sec = itemSectionForDelete {
                        sec.items.removeAll { $0.id == item.id }
                        modelContext.delete(item)
                    }
                    itemToDelete = nil
                    itemSectionForDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    itemToDelete = nil
                    itemSectionForDelete = nil
                }
            } message: {
                Text("This will permanently delete the item.")
            }
        }
        #if os(iOS)
        .presentationDetents([.large])
        #endif
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .onAppear {
            expandedSections = Set(sections.map(\.id))
        }
    }

    // MARK: - Section header

    @ViewBuilder
    private func sectionHeader(_ section: ProtocolSection) -> some View {
        HStack(spacing: StackTheme.Spacing.xs) {
            Text(section.emoji)
                .font(.body)

            TextField(
                "Section label",
                text: Binding(get: { section.label }, set: { section.label = $0 })
            )
            .font(StackTheme.Typography.label)
            .foregroundStyle(StackTheme.Text.secondary)

            Spacer()

            Button {
                sectionToDelete = section
                showDeleteSectionAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Accent.negative)
            }
            .buttonStyle(.plain)
        }
        .textCase(nil)
        .padding(.vertical, StackTheme.Spacing.xs)
    }

    // MARK: - Item rows (inside a section)

    @ViewBuilder
    private func itemRows(for section: ProtocolSection) -> some View {
        let sorted = section.items.sorted { $0.sortOrder < $1.sortOrder }

        ForEach(sorted) { item in
            HStack(spacing: StackTheme.Spacing.sm) {
                TextField(
                    "Item",
                    text: Binding(get: { item.text }, set: { item.text = $0 })
                )
                .font(StackTheme.Typography.body)
                .foregroundStyle(StackTheme.Text.primary)

                Button {
                    itemToDelete = item
                    itemSectionForDelete = section
                    showDeleteItemAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.negative)
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(StackTheme.Background.surface)
        }
        .onMove { from, to in
            moveItems(in: section, from: from, to: to)
        }

        addItemRow(for: section)
    }

    // MARK: - Add item row

    @ViewBuilder
    private func addItemRow(for section: ProtocolSection) -> some View {
        if addingToSectionID == section.id {
            HStack(spacing: StackTheme.Spacing.sm) {
                TextField("New item", text: $newItemDraft)
                    .font(StackTheme.Typography.body)
                    .foregroundStyle(StackTheme.Text.primary)
                    .focused($newItemFocused)
                    .onSubmit { commitNewItem(to: section) }

                Button("Add") { commitNewItem(to: section) }
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Accent.primary)
                    .buttonStyle(.plain)
            }
            .listRowBackground(StackTheme.Background.surface)
            .onAppear { newItemFocused = true }
        } else {
            Button {
                addingToSectionID = section.id
                newItemDraft = ""
            } label: {
                Label("Add item", systemImage: "plus.circle")
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Accent.primary)
            }
            .listRowBackground(StackTheme.Background.surface)
        }
    }

    // MARK: - Add section row

    private var addSectionRow: some View {
        Group {
            if isAddingSection {
                HStack(spacing: StackTheme.Spacing.sm) {
                    TextField("Section name", text: $newSectionDraft)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.primary)
                        .focused($newSectionFocused)
                        .onSubmit { commitNewSection() }

                    Button("Add") { commitNewSection() }
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.primary)
                        .buttonStyle(.plain)
                }
                .onAppear { newSectionFocused = true }
            } else {
                Button {
                    isAddingSection = true
                    newSectionDraft = ""
                } label: {
                    Label("Add Section", systemImage: "plus.circle")
                        .foregroundStyle(StackTheme.Accent.primary)
                }
            }
        }
        .listRowBackground(StackTheme.Background.surface)
    }

    // MARK: - Helpers

    private func expandedBinding(for section: ProtocolSection) -> Binding<Bool> {
        Binding(
            get: { expandedSections.contains(section.id) },
            set: { expanded in
                if expanded { expandedSections.insert(section.id) }
                else { expandedSections.remove(section.id) }
            }
        )
    }

    private func moveItems(in section: ProtocolSection, from source: IndexSet, to destination: Int) {
        var sorted = section.items.sorted { $0.sortOrder < $1.sortOrder }
        sorted.move(fromOffsets: source, toOffset: destination)
        for (idx, item) in sorted.enumerated() {
            item.sortOrder = idx
        }
    }

    private func commitNewItem(to section: ProtocolSection) {
        let text = newItemDraft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { addingToSectionID = nil; return }
        let nextOrder = (section.items.map(\.sortOrder).max() ?? -1) + 1
        let item = ProtocolItem(id: UUID().uuidString, text: text, sortOrder: nextOrder)
        section.items.append(item)
        newItemDraft = ""
        addingToSectionID = nil
    }

    private func commitNewSection() {
        let label = newSectionDraft.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty else { isAddingSection = false; return }
        let nextOrder = (sections.map(\.sortOrder).max() ?? -1) + 1
        let section = ProtocolSection(
            id: UUID().uuidString,
            label: label,
            emoji: "📋",
            colorHex: "#6366f1",
            sortOrder: nextOrder
        )
        modelContext.insert(section)
        expandedSections.insert(section.id)
        newSectionDraft = ""
        isAddingSection = false
    }
}
