import SwiftUI

struct RoadmapView: View {
    let viewModel: LearningViewModel
    @State private var selectedWeek: LearningWeek?

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                progressBanner

                ForEach(viewModel.phases.sorted { $0.order < $1.order }) { phase in
                    PhaseSection(phase: phase, viewModel: viewModel, selectedWeek: $selectedWeek)
                }
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(item: $selectedWeek) { week in
            WeekDetailSheet(week: week, viewModel: viewModel)
        }
    }

    // MARK: — Progress banner

    private var progressBanner: some View {
        StackCard(elevated: true) {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                HStack {
                    if let phase = viewModel.currentPhase, let week = viewModel.currentWeek {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(phase.title)
                                .font(StackTheme.Typography.title)
                                .foregroundStyle(StackTheme.Text.primary)
                            Text(week.title)
                                .font(StackTheme.Typography.caption)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }
                    } else {
                        Text("Learning Roadmap")
                            .font(StackTheme.Typography.title)
                            .foregroundStyle(StackTheme.Text.primary)
                    }

                    Spacer()

                    StackBadge(
                        text: "\(viewModel.completedWeeks)/\(viewModel.totalWeeks) weeks",
                        color: StackTheme.Accent.primary,
                        style: .subtle
                    )
                }

                StackProgressBar(
                    value: viewModel.overallProgress,
                    color: StackTheme.Accent.primary,
                    height: 6
                )

                if viewModel.completedWeeks > 0 {
                    let remaining = viewModel.totalWeeks - viewModel.completedWeeks
                    let eta = Calendar.current.date(byAdding: .weekOfYear, value: remaining, to: Date())
                    if let eta {
                        Text("Est. completion: \(eta.formatted(.dateTime.month().year()))")
                            .font(StackTheme.Typography.caption2)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }
        }
    }
}

// MARK: — Phase section card

private struct PhaseSection: View {
    let phase: LearningPhase
    let viewModel: LearningViewModel
    @Binding var selectedWeek: LearningWeek?

    private var completedCount: Int { phase.weeks.filter { $0.isComplete }.count }
    private var phaseProgress: Double {
        guard !phase.weeks.isEmpty else { return 0 }
        return Double(completedCount) / Double(phase.weeks.count)
    }
    private var isCurrentPhase: Bool { viewModel.currentPhase?.id == phase.id }

    var body: some View {
        VStack(spacing: StackTheme.Spacing.sm) {
            // Phase header card
            Button {
                phase.isExpanded.toggle()
            } label: {
                StackCard {
                    HStack(spacing: StackTheme.Spacing.sm) {
                        // Completion ring
                        ZStack {
                            Circle()
                                .stroke(StackTheme.Accent.soft, lineWidth: 3)
                            Circle()
                                .trim(from: 0, to: phaseProgress)
                                .stroke(StackTheme.Accent.primary, lineWidth: 3)
                                .rotationEffect(.degrees(-90))
                            if phaseProgress >= 1 {
                                Image(systemName: "checkmark")
                                    .font(StackTheme.Typography.caption2)
                                    .bold()
                                    .foregroundStyle(StackTheme.Accent.primary)
                            } else {
                                Text("\(completedCount)")
                                    .font(StackTheme.Typography.caption2)
                                    .foregroundStyle(StackTheme.Accent.primary)
                            }
                        }
                        .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(phase.title)
                                .font(StackTheme.Typography.body.bold())
                                .foregroundStyle(isCurrentPhase ? StackTheme.Accent.primary : StackTheme.Text.primary)
                            Text("\(phase.weeks.count) weeks · \(phase.durationWeeks) weeks target")
                                .font(StackTheme.Typography.caption2)
                                .foregroundStyle(StackTheme.Text.secondary)
                        }

                        Spacer()

                        if isCurrentPhase {
                            StackBadge(text: "Active", color: StackTheme.Accent.primary, style: .filled)
                        }

                        StackBadge(
                            text: "\(phase.weeks.count) wks",
                            color: StackTheme.Accent.primary,
                            style: .subtle
                        )

                        Image(systemName: phase.isExpanded ? "chevron.up" : "chevron.down")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            // Week rows
            if phase.isExpanded {
                ForEach(phase.weeks.sorted { $0.order < $1.order }) { week in
                    weekRow(week)
                }
            }
        }
    }

    private func weekRow(_ week: LearningWeek) -> some View {
        Button {
            selectedWeek = week
        } label: {
            StackCard {
                HStack(spacing: StackTheme.Spacing.sm) {
                    Image(systemName: week.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(week.isComplete ? StackTheme.Accent.positive : StackTheme.Text.secondary)
                        .font(StackTheme.Typography.body)
                        .contentTransition(.symbolEffect(.replace))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(week.title)
                            .font(StackTheme.Typography.body)
                            .foregroundStyle(isCurrentWeek(week) ? StackTheme.Accent.primary : StackTheme.Text.primary)
                            .lineLimit(2)

                        HStack(spacing: StackTheme.Spacing.sm) {
                            StackBadge(
                                text: "\(week.completedTopicCount)/\(week.topics.count) topics",
                                color: StackTheme.Accent.primary,
                                style: .subtle
                            )

                            if week.totalHours > 0 || isCurrentWeek(week) {
                                StackProgressBar(
                                    value: week.weeklyHourTarget > 0
                                        ? min(1, week.totalHours / week.weeklyHourTarget)
                                        : 0,
                                    color: week.totalHours >= week.weeklyHourTarget
                                        ? StackTheme.Accent.positive
                                        : StackTheme.Accent.primary,
                                    height: 4,
                                    animated: false
                                )
                                .frame(width: 60)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(StackTheme.Typography.caption2)
                        .foregroundStyle(StackTheme.Text.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func isCurrentWeek(_ week: LearningWeek) -> Bool {
        viewModel.currentWeek?.id == week.id
    }
}
