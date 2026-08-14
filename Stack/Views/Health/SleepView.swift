import SwiftUI
import Charts

struct SleepView: View {
    let viewModel: HealthViewModel
    @State private var showLog = false

    private static let dateF: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none; return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                // MARK: — Sleep stats card
                sleepCard

                // MARK: — 7-night chart (manual logs, or Fitbit data via Apple Health)
                if viewModel.sleepChart.count >= 2 {
                    sleepChart
                }

                // MARK: — Empty state
                if viewModel.sleepChart.isEmpty && !viewModel.isLoadingHealthData {
                    ContentUnavailableView(
                        "No sleep data",
                        systemImage: "moon.zzz.fill",
                        description: Text("Log a night above, or let your watch sync sleep into Apple Health.")
                    )
                }

                // MARK: — Recent entries
                if !viewModel.sleepEntries.isEmpty {
                    VStack(spacing: StackTheme.Spacing.sm) {
                        StackSectionHeader(title: "RECENT")
                            .padding(.horizontal, StackTheme.Spacing.xs)

                        ForEach(viewModel.sleepEntries) { entry in
                            StackCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: StackTheme.Spacing.xs) {
                                        Text(String(format: "%.1f hrs", entry.hours))
                                            .font(StackTheme.Typography.headline)
                                            .foregroundStyle(StackTheme.Text.primary)
                                        Text(Self.dateF.string(from: entry.date))
                                            .font(StackTheme.Typography.caption)
                                            .foregroundStyle(StackTheme.Text.tertiary)
                                    }
                                    Spacer()
                                    starsView(entry.quality)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteSleep(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(StackTheme.Spacing.md)
        }
        .background(StackTheme.Background.base)
        .sheet(isPresented: $showLog) { LogSleepSheet(viewModel: viewModel) }
    }

    // MARK: — Sleep card

    private let sleepGoal: Double = 8

    private var sleepCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                HStack {
                    StackLabel("Last night")
                    Spacer()
                    if viewModel.sleepIsFromHK {
                        StackBadge(text: "Fitbit · Health", color: StackTheme.Accent.primary, style: .subtle)
                    }
                }

                if viewModel.isLoadingHealthData && viewModel.lastNightSleep == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .tint(StackTheme.Accent.primary)
                } else {
                    // Whoop-style sleep performance ring vs the 8h goal
                    HStack(spacing: StackTheme.Spacing.xl) {
                        let hrs = viewModel.lastNightSleep
                        StackRing(
                            value: min(1, (hrs ?? 0) / sleepGoal),
                            color: hrs.map(sleepColor) ?? StackTheme.Accent.primary,
                            lineWidth: 11,
                            size: 140
                        ) {
                            VStack(spacing: 2) {
                                if let hrs {
                                    Text(String(format: "%.1f", hrs))
                                        .font(StackTheme.Typography.stat)
                                        .monospacedDigit()
                                        .foregroundStyle(sleepColor(hrs))
                                } else {
                                    Text("—")
                                        .font(StackTheme.Typography.stat)
                                        .foregroundStyle(StackTheme.Text.tertiary)
                                }
                                StackLabel("of \(Int(sleepGoal))h", color: StackTheme.Text.tertiary)
                            }
                        }

                        VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                            if let hrs = viewModel.lastNightSleep {
                                VStack(alignment: .leading, spacing: 2) {
                                    StackLabel("Performance", color: StackTheme.Text.tertiary)
                                    Text("\(Int(min(1, hrs / sleepGoal) * 100))%")
                                        .font(StackTheme.Typography.metric)
                                        .monospacedDigit()
                                        .foregroundStyle(sleepColor(hrs))
                                }
                            }
                            if viewModel.weeklyAvgSleep > 0 {
                                VStack(alignment: .leading, spacing: 2) {
                                    StackLabel("7-night avg", color: StackTheme.Text.tertiary)
                                    Text(String(format: "%.1f hrs", viewModel.weeklyAvgSleep))
                                        .font(StackTheme.Typography.metric)
                                        .monospacedDigit()
                                        .foregroundStyle(StackTheme.Text.primary)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }

                Button { showLog = true } label: {
                    Text("Log Sleep")
                        .font(StackTheme.Typography.body.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sleepColor(_ hrs: Double) -> Color {
        hrs >= 8 ? StackTheme.Accent.positive : hrs >= 6 ? StackTheme.Accent.warning : StackTheme.Accent.negative
    }

    // MARK: — Sleep chart

    private var sleepChart: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                StackSectionHeader(title: "7-Night Overview")

                Chart(viewModel.sleepChart) { night in
                    BarMark(
                        x: .value("Date", night.date, unit: .day),
                        y: .value("Hours", night.hours)
                    )
                    .foregroundStyle(barColor(night.hours))
                    .cornerRadius(5)

                    RuleMark(y: .value("Goal", sleepGoal))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(StackTheme.Text.tertiary)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                            .font(StackTheme.Typography.label)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisValueLabel()
                            .font(StackTheme.Typography.label)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }
                .chartPlotStyle { $0.background(StackTheme.Background.surface) }
                .frame(height: 160)
            }
        }
    }

    private func barColor(_ hours: Double) -> Color {
        hours >= 8 ? StackTheme.Accent.positive : hours >= 6 ? StackTheme.Accent.warning : StackTheme.Accent.negative
    }

    // MARK: — Helpers

    private func starsView(_ quality: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= quality ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(i <= quality ? StackTheme.Accent.warning : StackTheme.Text.tertiary)
            }
        }
    }
}
