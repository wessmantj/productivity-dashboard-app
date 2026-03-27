import SwiftUI

struct BoardView: View {
    let viewModel: VisionViewModel

    var body: some View {
        #if os(macOS)
        macOSLayout
        #else
        iOSLayout
        #endif
    }

    // MARK: — iOS layout (single column)

    private var iOSLayout: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.lg) {
                quoteCard
                affirmationBanner
                goalCategories
            }
            .padding(.horizontal, StackTheme.Spacing.md)
            .padding(.vertical, StackTheme.Spacing.lg)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
    }

    // MARK: — macOS layout (two-column)

    #if os(macOS)
    private var macOSLayout: some View {
        ScrollView {
            HStack(alignment: .top, spacing: StackTheme.Spacing.lg) {
                VStack(spacing: StackTheme.Spacing.lg) {
                    quoteCard
                    affirmationBanner
                }
                .frame(maxWidth: 420)

                goalCategories
                    .frame(maxWidth: .infinity)
            }
            .padding(StackTheme.Spacing.lg)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
    }
    #endif

    // MARK: — Quote card

    private var quoteCard: some View {
        Button {
            if let q = viewModel.dailyQuote { viewModel.toggleQuoteFavorite(q) }
        } label: {
            StackCard(elevated: true, padding: StackTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                    HStack {
                        Image(systemName: "quote.bubble.fill")
                            .foregroundStyle(StackTheme.Accent.primary)
                            .font(.title3)
                        Spacer()
                        Image(systemName: viewModel.dailyQuote?.isFavorite == true
                              ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.dailyQuote?.isFavorite == true
                                             ? StackTheme.Accent.primary : StackTheme.Text.secondary)
                            .font(StackTheme.Typography.body)
                            .contentTransition(.symbolEffect(.replace))
                    }

                    if let q = viewModel.dailyQuote {
                        Text("\u{201C}\(q.text)\u{201D}")
                            .font(StackTheme.Typography.quote)
                            .foregroundStyle(StackTheme.Text.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)

                        Text("— \(q.author)")
                            .font(StackTheme.Typography.headline)
                            .foregroundStyle(StackTheme.Text.secondary)
                    } else {
                        Text("No quotes yet. Add one in the Quotes tab.")
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: — Affirmation banner

    private var affirmationBanner: some View {
        StackCard {
            if let aff = viewModel.dailyAffirmation {
                Text(aff.text)
                    .font(StackTheme.Typography.quote.italic())
                    .foregroundStyle(StackTheme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: — Goal categories

    private var goalCategories: some View {
        VStack(alignment: .leading, spacing: StackTheme.Spacing.lg) {
            ForEach(VisionViewModel.categoryOrder, id: \.self) { category in
                let catGoals = (viewModel.goalsByCategory[category] ?? [])
                    .sorted { $0.sortOrder < $1.sortOrder }
                if !catGoals.isEmpty {
                    categoryRow(category: category, goals: catGoals)
                }
            }
        }
    }

    private func categoryRow(category: String, goals: [Goal]) -> some View {
        VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
            StackSectionHeader(title: category)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: StackTheme.Spacing.sm) {
                    ForEach(goals) { goal in
                        GoalCard(goal: goal, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, StackTheme.Spacing.xs)
            }
        }
    }
}

// MARK: — GoalCard

private struct GoalCard: View {
    let goal: Goal
    let viewModel: VisionViewModel
    @State private var showDetail = false

    var body: some View {
        Button { showDetail = true } label: {
            StackCard {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                    HStack(alignment: .top) {
                        Text(goal.title)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(StackTheme.Text.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if goal.isAchieved {
                            StackBadge(text: "✓", color: StackTheme.Accent.positive, style: .filled)
                        }
                    }

                    if let date = goal.targetDate {
                        Text(date.formatted(.dateTime.month(.abbreviated).year()))
                            .font(StackTheme.Typography.caption2)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }
            }
            .frame(width: 200)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            GoalDetailSheet(goal: goal, viewModel: viewModel)
        }
    }
}
