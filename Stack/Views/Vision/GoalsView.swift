import SwiftUI

struct GoalsView: View {
    let viewModel: VisionViewModel
    @State private var showAddGoal = false
    @State private var selectedGoal: Goal?
    @State private var showAchieved = false
    @State private var goalToDelete: Goal?

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                // Add Goal button
                Button { showAddGoal = true } label: {
                    Label("Add Goal", systemImage: "plus.circle.fill")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(StackTheme.Text.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, StackTheme.Spacing.sm + 2)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)

                // Goals by category
                ForEach(VisionViewModel.categoryOrder, id: \.self) { category in
                    let catGoals = (viewModel.goalsByCategory[category] ?? [])
                        .filter { !$0.isAchieved }
                        .sorted { $0.sortOrder < $1.sortOrder }
                    if !catGoals.isEmpty {
                        StackSectionHeader(title: category)

                        ForEach(catGoals) { goal in
                            goalRow(goal)
                        }
                    }
                }

                // Achieved section
                if !viewModel.achievedGoals.isEmpty {
                    StackSectionHeader(title: "Achieved")

                    DisclosureGroup(isExpanded: $showAchieved) {
                        VStack(spacing: StackTheme.Spacing.sm) {
                            ForEach(viewModel.achievedGoals) { goal in
                                goalRow(goal)
                            }
                        }
                    } label: {
                        Label("Achieved (\(viewModel.achievedGoals.count))",
                              systemImage: "checkmark.seal.fill")
                            .font(StackTheme.Typography.body.weight(.semibold))
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(isPresented: $showAddGoal) { AddGoalSheet(viewModel: viewModel) }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailSheet(goal: goal, viewModel: viewModel)
        }
        .alert("Delete goal?", isPresented: Binding(
            get: { goalToDelete != nil },
            set: { if !$0 { goalToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let g = goalToDelete { viewModel.deleteGoal(g) }
                goalToDelete = nil
            }
            Button("Cancel", role: .cancel) { goalToDelete = nil }
        }
    }

    private func goalRow(_ goal: Goal) -> some View {
        StackCard {
            HStack(spacing: StackTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(goal.isAchieved ? StackTheme.Text.tertiary : StackTheme.Text.primary)
                        .strikethrough(goal.isAchieved)

                    if let date = goal.targetDate {
                        Text(date.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(StackTheme.Typography.caption2)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }

                Spacer()

                if goal.isAchieved {
                    StackBadge(text: "✓ Achieved", color: StackTheme.Accent.positive, style: .filled)
                }

                Image(systemName: "chevron.right")
                    .font(StackTheme.Typography.caption2)
                    .foregroundStyle(StackTheme.Text.tertiary)

                Button { goalToDelete = goal } label: {
                    Image(systemName: "trash")
                        .font(StackTheme.Typography.caption)
                        .foregroundStyle(StackTheme.Accent.negative)
                }
                .buttonStyle(.plain)
                .padding(.leading, StackTheme.Spacing.xs)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: StackTheme.Radius.md))
        .onTapGesture { selectedGoal = goal }
    }
}
