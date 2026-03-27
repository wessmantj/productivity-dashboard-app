import SwiftUI

struct JournalHistoryView: View {
    let viewModel: JournalViewModel
    @State private var selectedEntry: JournalEntry?
    @State private var entryToDelete: JournalEntry?

    private static let moods: [Int: String] = [1:"😔",2:"😕",3:"😐",4:"🙂",5:"😄"]

    private var grouped: [(String, [JournalEntry])] {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        let dict = Dictionary(grouping: viewModel.entries) { fmt.string(from: $0.date) }
        return dict.sorted { lhs, rhs in
            guard let l = dict[lhs.key]?.first?.date,
                  let r = dict[rhs.key]?.first?.date else { return false }
            return l > r
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                if viewModel.entries.isEmpty {
                    StackCard {
                        ContentUnavailableView(
                            "No past entries",
                            systemImage: "book.closed.fill",
                            description: Text("Start writing today and build your history.")
                        )
                        .foregroundStyle(StackTheme.Text.secondary)
                    }
                } else {
                    ForEach(grouped, id: \.0) { month, entries in
                        StackSectionHeader(title: month)

                        ForEach(entries) { entry in
                            entryRow(entry)
                                .contentShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                                .onTapGesture { selectedEntry = entry }
                        }
                    }
                }
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(item: $selectedEntry) { entry in
            EntryReadSheet(entry: entry)
        }
        .alert("Delete entry?", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let e = entryToDelete { viewModel.deleteEntry(e) }
                entryToDelete = nil
            }
            Button("Cancel", role: .cancel) { entryToDelete = nil }
        }
    }

    private func entryRow(_ entry: JournalEntry) -> some View {
        StackCard {
            HStack(spacing: StackTheme.Spacing.sm) {
                Text(Self.moods[entry.mood] ?? "😐")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                    if !entry.body.isEmpty {
                        Text(String(entry.body.prefix(80)))
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                StackBadge(
                    text: "\(entry.wordCount)w",
                    color: StackTheme.Accent.primary,
                    style: .subtle
                )

                Button { entryToDelete = entry } label: {
                    Image(systemName: "trash")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.negative)
                }
                .buttonStyle(.plain)
                .padding(.leading, StackTheme.Spacing.xs)
            }
        }
    }
}

// MARK: — Read-only sheet

private struct EntryReadSheet: View {
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss
    private static let moods: [Int: String] = [1:"😔",2:"😕",3:"😐",4:"🙂",5:"😄"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                    HStack(spacing: StackTheme.Spacing.sm) {
                        Text(Self.moods[entry.mood] ?? "😐").font(.system(size: 36))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.date.formatted(.dateTime.weekday(.wide).month().day().year()))
                                .font(StackTheme.Typography.headline)
                                .foregroundStyle(StackTheme.Text.primary)
                            Text("\(entry.wordCount) words")
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }
                    }

                    Text(entry.body)
                        .font(StackTheme.Typography.body)
                        .lineSpacing(5)
                        .foregroundStyle(StackTheme.Text.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !entry.tags.isEmpty {
                        HStack(spacing: StackTheme.Spacing.xs) {
                            ForEach(entry.tags, id: \.self) { tag in
                                StackBadge(text: "#\(tag)", color: StackTheme.Accent.primary, style: .subtle)
                            }
                        }
                    }
                }
                .padding(StackTheme.Spacing.lg)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle("Journal")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .presentationDetents([.large])
    }
}
