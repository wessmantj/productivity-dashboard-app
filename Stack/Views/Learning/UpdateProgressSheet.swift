import SwiftUI

struct UpdateProgressSheet: View {
    let entry: ReadingEntry
    let viewModel: LearningViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var pageText = ""

    private var pageValue: Int? {
        guard let v = Int(pageText), v >= 0, v <= entry.totalPages else { return nil }
        return v
    }

    private var currentProgress: Double {
        guard entry.totalPages > 0, let v = pageValue else {
            return entry.progress
        }
        return Double(v) / Double(entry.totalPages)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // Book info + input card
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text(entry.title)
                                .font(StackTheme.Typography.body.bold())
                                .foregroundStyle(StackTheme.Text.primary)

                            Text("Currently on page \(entry.currentPage)")
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)

                            Divider().background(StackTheme.Border.subtle)

                            HStack {
                                TextField("Current page", text: $pageText)
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.primary)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                Text("of \(entry.totalPages)")
                                    .font(StackTheme.Typography.body)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }

                            StackProgressBar(
                                value: currentProgress,
                                color: StackTheme.Accent.primary,
                                height: 6
                            )
                        }
                    }

                    // Completion notice
                    if pageValue == entry.totalPages {
                        StackCard {
                            Label("This will mark the book complete!", systemImage: "checkmark.seal.fill")
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Accent.positive)
                        }
                    }

                    // Save button
                    Button {
                        if let p = pageValue {
                            viewModel.updateProgress(entry: entry, currentPage: p)
                            if p == entry.totalPages { viewModel.markBookComplete(entry) }
                        }
                        dismiss()
                    } label: {
                        Text("Save Progress")
                            .font(StackTheme.Typography.body.bold())
                            .foregroundStyle(StackTheme.Text.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, StackTheme.Spacing.md)
                            .background(
                                pageValue != nil ? StackTheme.Accent.primary : StackTheme.Accent.primary.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: StackTheme.Radius.md)
                            )
                    }
                    .disabled(pageValue == nil)
                    .buttonStyle(.plain)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle("Update Progress")
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
        .onAppear { pageText = "\(entry.currentPage)" }
    }
}
