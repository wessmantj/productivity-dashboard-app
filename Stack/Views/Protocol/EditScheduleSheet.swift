import SwiftUI
import SwiftData

struct EditScheduleSheet: View {
    let selectedDay: Int  // Calendar weekday: 1=Sun, 2=Mon…7=Sat

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var allBlocks: [ScheduleBlock]

    @State private var showAddForm = false
    @State private var newTime = Date()
    @State private var newTitle = ""
    @State private var newCategory = "Morning"

    // Matches the categories used by the seeded schedule and ProtocolView's color map.
    private static let categories = [
        "Morning", "Recovery", "Nutrition", "ML", "Work",
        "Fitness", "Career", "Personal", "Evening"
    ]

    private var dayBlocks: [ScheduleBlock] {
        allBlocks.filter { $0.dayOfWeek == selectedDay }.sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(dayBlocks) { block in
                    HStack(spacing: StackTheme.Spacing.sm) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ScheduleTime.display(block.time))
                                .font(StackTheme.Typography.time)
                                .foregroundStyle(StackTheme.Text.secondary)
                            Text(block.label)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                        }
                        Spacer()
                        Button {
                            context.delete(block)
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
                    moveBlocks(from: from, to: to)
                }

                if showAddForm {
                    addFormSection
                } else {
                    Button {
                        showAddForm = true
                    } label: {
                        Label("Add Block", systemImage: "plus.circle")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Accent.primary)
                    }
                    .listRowBackground(StackTheme.Background.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(StackTheme.Background.elevated)
            .navigationTitle(dayName)
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? context.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
    }

    // MARK: - Add form

    @ViewBuilder
    private var addFormSection: some View {
        DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .listRowBackground(StackTheme.Background.surface)

        TextField("Title", text: $newTitle)
            .font(StackTheme.Typography.body)
            .foregroundStyle(StackTheme.Text.primary)
            .listRowBackground(StackTheme.Background.surface)

        Picker("Category", selection: $newCategory) {
            ForEach(Self.categories, id: \.self) { cat in
                Text(cat).tag(cat)
            }
        }
        .listRowBackground(StackTheme.Background.surface)

        HStack(spacing: StackTheme.Spacing.md) {
            Button("Add") { commitNewBlock() }
                .foregroundStyle(StackTheme.Accent.primary)
                .fontWeight(.semibold)
            Button("Cancel") {
                newTitle = ""
                showAddForm = false
            }
            .foregroundStyle(StackTheme.Text.secondary)
        }
        .font(StackTheme.Typography.body)
        .listRowBackground(StackTheme.Background.surface)
    }

    // MARK: - Helpers

    private var dayName: String {
        Weekday.fullName(for: selectedDay)
    }

    private func moveBlocks(from source: IndexSet, to destination: Int) {
        var sorted = dayBlocks
        sorted.move(fromOffsets: source, toOffset: destination)
        for (idx, block) in sorted.enumerated() {
            block.sortOrder = idx
        }
    }

    private func commitNewBlock() {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        let cal = Calendar.current
        let timeStr = ScheduleTime.string(
            hour: cal.component(.hour, from: newTime),
            minute: cal.component(.minute, from: newTime)
        )
        let nextOrder = (dayBlocks.map(\.sortOrder).max() ?? -1) + 1
        let block = ScheduleBlock(
            dayOfWeek: selectedDay,
            time: timeStr,
            label: title,
            category: newCategory,
            sortOrder: nextOrder
        )
        context.insert(block)
        newTitle = ""
        newTime = Date()
        newCategory = "Morning"
        showAddForm = false
    }
}
