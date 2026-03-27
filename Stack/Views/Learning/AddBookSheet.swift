import SwiftUI

struct AddBookSheet: View {
    let viewModel: LearningViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var totalPagesText = ""
    @State private var dailyGoalText = "20"

    private var canSave: Bool {
        !title.isEmpty && !author.isEmpty &&
        (Int(totalPagesText) ?? 0) > 0 &&
        (Int(dailyGoalText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // Book section
                    StackSectionHeader(title: "Book")

                    StackCard {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            TextField("Title", text: $title)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                            Divider().background(StackTheme.Border.subtle)
                            TextField("Author", text: $author)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                        }
                    }

                    // Pages section
                    StackSectionHeader(title: "Pages")

                    StackCard {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            HStack {
                                TextField("Total pages", text: $totalPagesText)
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.primary)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                Text("pages")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                            Divider().background(StackTheme.Border.subtle)
                            HStack {
                                TextField("Daily goal", text: $dailyGoalText)
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.primary)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                Text("pages/day")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        }
                    }

                    // Save button
                    Button {
                        viewModel.addBook(
                            title: title, author: author,
                            totalPages: Int(totalPagesText) ?? 0,
                            dailyGoal: Int(dailyGoalText) ?? 20
                        )
                        dismiss()
                    } label: {
                        Text("Add Book")
                            .font(StackTheme.Typography.body.bold())
                            .foregroundStyle(StackTheme.Text.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, StackTheme.Spacing.md)
                            .background(
                                canSave ? StackTheme.Accent.primary : StackTheme.Accent.primary.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: StackTheme.Radius.md)
                            )
                    }
                    .disabled(!canSave)
                    .buttonStyle(.plain)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle("Add Book")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationBackground(StackTheme.Background.elevated)
        .presentationCornerRadius(StackTheme.Radius.lg)
        .presentationDetents([.medium])
    }
}
