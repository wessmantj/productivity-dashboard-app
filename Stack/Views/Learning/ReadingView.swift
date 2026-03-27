import SwiftUI

struct ReadingView: View {
    let viewModel: LearningViewModel
    @State private var showAddBook = false
    @State private var selectedEntry: ReadingEntry?
    @State private var showCompleted = false
    @State private var bookToDelete: ReadingEntry?

    private var activeBooks: [ReadingEntry] { viewModel.readingEntries.filter { !$0.isComplete } }
    private var completedBooks: [ReadingEntry] { viewModel.readingEntries.filter { $0.isComplete } }

    private static let dateF: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none; return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                // Add Book button
                Button {
                    showAddBook = true
                } label: {
                    Label("Add Book", systemImage: "plus.circle.fill")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, StackTheme.Spacing.sm + 2)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)

                // Active books
                if activeBooks.isEmpty {
                    StackCard {
                        ContentUnavailableView(
                            "No active books",
                            systemImage: "book.fill",
                            description: Text("Tap 'Add Book' to start tracking your reading.")
                        )
                        .foregroundStyle(StackTheme.Text.secondary)
                    }
                } else {
                    StackSectionHeader(title: "Reading Now")

                    ForEach(activeBooks) { entry in
                        bookCard(entry)
                    }
                }

                // Completed books
                if !completedBooks.isEmpty {
                    StackSectionHeader(title: "Completed")

                    DisclosureGroup(isExpanded: $showCompleted) {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            ForEach(completedBooks) { entry in
                                StackCard {
                                    completedRow(entry)
                                }
                            }
                        }
                    } label: {
                        Label("Completed (\(completedBooks.count))", systemImage: "checkmark.seal.fill")
                            .font(StackTheme.Typography.body.weight(.semibold))
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(isPresented: $showAddBook) { AddBookSheet(viewModel: viewModel) }
        .sheet(item: $selectedEntry) { entry in
            UpdateProgressSheet(entry: entry, viewModel: viewModel)
        }
        .alert("Delete book?", isPresented: Binding(
            get: { bookToDelete != nil },
            set: { if !$0 { bookToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let b = bookToDelete { viewModel.deleteBook(b) }
                bookToDelete = nil
            }
            Button("Cancel", role: .cancel) { bookToDelete = nil }
        }
    }

    // MARK: — Book card

    private func bookCard(_ entry: ReadingEntry) -> some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title)
                            .font(StackTheme.Typography.body.bold())
                            .foregroundStyle(StackTheme.Text.primary)
                        Text(entry.author)
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                    Spacer()
                }

                StackProgressBar(value: entry.progress, color: StackTheme.Accent.primary, height: 6)

                HStack {
                    Text("p. \(entry.currentPage) / \(entry.totalPages)")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Text.secondary)
                    Spacer()
                    if entry.daysRemaining > 0 {
                        StackBadge(
                            text: "\(entry.daysRemaining) days left",
                            color: StackTheme.Accent.primary,
                            style: .subtle
                        )
                    }
                }

                HStack(spacing: StackTheme.Spacing.sm) {
                    Button {
                        selectedEntry = entry
                    } label: {
                        Text("Update Progress")
                            .font(StackTheme.Typography.caption.weight(.semibold))
                            .foregroundStyle(StackTheme.Text.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, StackTheme.Spacing.xs + 2)
                            .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.sm))
                    }
                    .buttonStyle(.plain)

                    Button { bookToDelete = entry } label: {
                        Image(systemName: "trash")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Accent.negative)
                            .padding(StackTheme.Spacing.xs + 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: — Completed row

    private func completedRow(_ entry: ReadingEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(StackTheme.Typography.body.weight(.semibold))
                    .foregroundStyle(StackTheme.Text.primary)
                Text(entry.author)
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Text.secondary)
            }
            Spacer()
            if let date = entry.completedDate {
                Text(Self.dateF.string(from: date))
                    .font(StackTheme.Typography.caption2)
                    .foregroundStyle(StackTheme.Text.secondary)
            }
            Button { bookToDelete = entry } label: {
                Image(systemName: "trash")
                    .font(StackTheme.Typography.caption)
                    .foregroundStyle(StackTheme.Accent.negative)
            }
            .buttonStyle(.plain)
            .padding(.leading, StackTheme.Spacing.xs)
        }
    }
}
