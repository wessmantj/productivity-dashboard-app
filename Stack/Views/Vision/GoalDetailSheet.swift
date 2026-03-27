import SwiftUI

struct GoalDetailSheet: View {
    let goal: Goal
    let viewModel: VisionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var bounceCheckmark = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.lg) {
                    // Category badge
                    StackBadge(text: goal.category.uppercased(), color: StackTheme.Accent.primary, style: .subtle)

                    // Title
                    Text(goal.title)
                        .font(StackTheme.Typography.quote.weight(.bold))
                        .foregroundStyle(StackTheme.Text.primary)

                    // Detail
                    Text(goal.detail)
                        .font(StackTheme.Typography.body)
                        .foregroundStyle(StackTheme.Text.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider()
                        .background(StackTheme.Border.subtle)

                    // Target date picker
                    StackCard {
                        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                            Text("Target Date")
                                .font(StackTheme.Typography.caption.weight(.semibold))
                                .foregroundStyle(StackTheme.Text.secondary)

                            if let date = goal.targetDate {
                                HStack {
                                    DatePicker("", selection: Binding(
                                        get: { date },
                                        set: { goal.targetDate = $0 }
                                    ), displayedComponents: .date)
                                    .labelsHidden()

                                    Button {
                                        goal.targetDate = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(StackTheme.Text.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                Button {
                                    goal.targetDate = Calendar.current.date(
                                        byAdding: .month, value: 3, to: Date()
                                    )
                                } label: {
                                    Label("Set target date", systemImage: "calendar.badge.plus")
                                        .font(StackTheme.Typography.body)
                                        .foregroundStyle(StackTheme.Accent.primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Achieved date
                    if goal.isAchieved, let date = goal.achievedDate {
                        HStack(spacing: StackTheme.Spacing.xs) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(StackTheme.Accent.positive)
                            Text("Achieved \(date.formatted(.dateTime.month().day().year()))")
                                .font(StackTheme.Typography.body)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }
                    }

                    // Mark achieved button
                    Button {
                        viewModel.toggleGoalAchieved(goal)
                        if goal.isAchieved {
                            bounceCheckmark = true
                        }
                    } label: {
                        HStack(spacing: StackTheme.Spacing.sm) {
                            Image(systemName: goal.isAchieved
                                  ? "checkmark.seal.fill" : "checkmark.seal")
                                .font(.title3)
                                .symbolEffect(.bounce, value: bounceCheckmark)
                                .foregroundStyle(goal.isAchieved ? StackTheme.Accent.positive : StackTheme.Accent.primary)

                            Text(goal.isAchieved ? "Mark as Not Achieved" : "Mark as Achieved")
                                .font(StackTheme.Typography.body.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, StackTheme.Spacing.md)
                        .background(
                            goal.isAchieved
                                ? StackTheme.Accent.positive.opacity(0.12)
                                : StackTheme.Accent.primary.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: StackTheme.Radius.md)
                        )
                        .foregroundStyle(goal.isAchieved ? StackTheme.Accent.positive : StackTheme.Accent.primary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(StackTheme.Spacing.lg)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(StackTheme.Background.elevated.ignoresSafeArea())
            .navigationTitle(goal.category)
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
        .presentationDetents([.medium, .large])
    }
}
