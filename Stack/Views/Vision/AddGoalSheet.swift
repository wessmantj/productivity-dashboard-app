import SwiftUI

struct AddGoalSheet: View {
    let viewModel: VisionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var detail = ""
    @State private var category = "Fitness"
    @State private var hasTargetDate = false
    @State private var targetDate = Date()

    private let categories = VisionViewModel.categoryOrder

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: StackTheme.Spacing.md) {
                    // Goal section
                    StackSectionHeader(title: "Goal")

                    StackCard {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            TextField("Title", text: $title)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                            Divider().background(StackTheme.Border.subtle)
                            TextField("Detail (optional)", text: $detail, axis: .vertical)
                                .lineLimit(3, reservesSpace: false)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                        }
                    }

                    // Category section
                    StackSectionHeader(title: "Category")

                    StackCard {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            HStack(spacing: StackTheme.Spacing.sm) {
                                ForEach(categories, id: \.self) { cat in
                                    Button {
                                        category = cat
                                    } label: {
                                        StackBadge(
                                            text: cat,
                                            color: StackTheme.Accent.primary,
                                            style: category == cat ? .filled : .subtle
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Target Date section
                    StackSectionHeader(title: "Target Date")

                    StackCard {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            Toggle("Set a target date", isOn: $hasTargetDate)
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.primary)
                                .tint(StackTheme.Accent.primary)
                            if hasTargetDate {
                                Divider().background(StackTheme.Border.subtle)
                                DatePicker("Target", selection: $targetDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                    }

                    // Save button
                    Button {
                        viewModel.addGoal(
                            title: title.trimmingCharacters(in: .whitespaces),
                            detail: detail,
                            category: category,
                            targetDate: hasTargetDate ? targetDate : nil,
                            colorHex: "6366f1"
                        )
                        dismiss()
                    } label: {
                        Text("Add Goal")
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
            .navigationTitle("Add Goal")
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
        .presentationDetents([.medium, .large])
    }
}
