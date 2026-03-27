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

                // MARK: — 7-night chart
                if viewModel.last7Sleep.count >= 2 {
                    sleepChart
                }

                // MARK: — Empty state
                if viewModel.sleepEntries.isEmpty && !viewModel.isLoadingHealthData {
                    ContentUnavailableView(
                        "No sleep logged",
                        systemImage: "moon.zzz.fill",
                        description: Text("Tap \"Log Sleep\" above to track your first night.")
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

    private var sleepCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                HStack {
                    Label("Sleep", systemImage: "moon.zzz.fill")
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Accent.primary)
                    Spacer()
                    if viewModel.hkSleep != nil && viewModel.sleepEntries.isEmpty {
                        StackBadge(text: "Apple Health", color: StackTheme.Accent.primary, style: .subtle)
                    }
                }

                if viewModel.isLoadingHealthData && viewModel.sleepEntries.isEmpty && viewModel.hkSleep == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .tint(StackTheme.Accent.primary)
                } else {
                    HStack(alignment: .bottom, spacing: StackTheme.Spacing.lg) {
                        // Last night hero number
                        if let hrs = viewModel.sleepEntries.first?.hours ?? viewModel.hkSleep {
                            HStack(alignment: .lastTextBaseline, spacing: StackTheme.Spacing.xs) {
                                Text(String(format: "%.1f", hrs))
                                    .font(StackTheme.Typography.heroNumber)
                                    .foregroundStyle(sleepColor(hrs))
                                Text("hrs")
                                    .font(StackTheme.Typography.caption)
                                    .foregroundStyle(StackTheme.Text.secondary)
                            }
                        } else {
                            Text("—")
                                .font(StackTheme.Typography.heroNumber)
                                .foregroundStyle(StackTheme.Text.tertiary)
                        }

                        // Weekly average badge
                        if viewModel.weeklyAvgSleep > 0 {
                            StackBadge(
                                text: String(format: "%.1f hrs avg", viewModel.weeklyAvgSleep),
                                color: StackTheme.Accent.primary,
                                style: .subtle
                            )
                        }
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

                Chart(viewModel.last7Sleep) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Hours", entry.hours)
                    )
                    .foregroundStyle(barColor(entry.hours))
                    .cornerRadius(5)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                            .font(StackTheme.Typography.caption2)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisValueLabel()
                            .font(StackTheme.Typography.caption2)
                            .foregroundStyle(StackTheme.Text.tertiary)
                    }
                }
                .chartPlotStyle { $0.background(StackTheme.Background.card) }
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
