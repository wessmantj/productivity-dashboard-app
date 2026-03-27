import SwiftUI
import Charts

struct BodyView: View {
    let viewModel: HealthViewModel
    @State private var showLog = false

    private static let dateF: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none; return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: StackTheme.Spacing.md) {
                // MARK: — Current weight card
                weightCard

                // MARK: — Chart
                if viewModel.weightTrend.count >= 2 {
                    weightChart
                }

                // MARK: — Empty state
                if viewModel.weightEntries.isEmpty && !viewModel.isLoadingHealthData {
                    ContentUnavailableView(
                        "No weight logged",
                        systemImage: "scalemass.fill",
                        description: Text("Tap \"Log Weight\" above to record your first entry.")
                    )
                }

                // MARK: — Recent entries
                if !viewModel.weightEntries.isEmpty {
                    VStack(spacing: StackTheme.Spacing.sm) {
                        StackSectionHeader("HISTORY")
                            .padding(.horizontal, StackTheme.Spacing.xs)

                        ForEach(viewModel.weightEntries) { entry in
                            StackCard {
                                HStack {
                                    Text(Self.dateF.string(from: entry.date))
                                        .font(StackTheme.Typography.body)
                                        .foregroundStyle(StackTheme.Text.secondary)
                                    Spacer()
                                    Text(String(format: "%.1f lbs", entry.pounds))
                                        .font(StackTheme.Typography.headline)
                                        .foregroundStyle(StackTheme.Text.primary)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteWeight(entry)
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
        .background(StackTheme.Background.base.ignoresSafeArea())
        .sheet(isPresented: $showLog) { LogWeightSheet(viewModel: viewModel) }
    }

    // MARK: — Weight card

    private var weightCard: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.md) {
                HStack {
                    Label("Body Weight", systemImage: "scalemass.fill")
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(StackTheme.Accent.primary)
                    Spacer()
                    if viewModel.hkWeight != nil && viewModel.weightEntries.isEmpty {
                        StackBadge(text: "Apple Health", color: StackTheme.Accent.primary, style: .subtle)
                    }
                }

                if viewModel.isLoadingHealthData && viewModel.currentWeight == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .tint(StackTheme.Accent.primary)
                } else if let w = viewModel.currentWeight {
                    HStack(alignment: .lastTextBaseline, spacing: StackTheme.Spacing.xs) {
                        Text(String(format: "%.1f", w))
                            .font(StackTheme.Typography.stat)
                            .foregroundStyle(StackTheme.Text.primary)
                        Text("lbs")
                            .font(StackTheme.Typography.caption)
                            .foregroundStyle(StackTheme.Text.secondary)
                    }
                } else {
                    Text("No data yet")
                        .font(StackTheme.Typography.title)
                        .foregroundStyle(StackTheme.Text.tertiary)
                }

                Button { showLog = true } label: {
                    Text("Log Weight")
                        .font(StackTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(StackTheme.Accent.primary, in: RoundedRectangle(cornerRadius: StackTheme.Radius.md))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: — Weight chart

    private var weightChart: some View {
        StackCard {
            VStack(alignment: .leading, spacing: StackTheme.Spacing.sm) {
                StackSectionHeader("14-Day Trend")

                Chart(viewModel.weightTrend) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("lbs", entry.pounds)
                    )
                    .foregroundStyle(StackTheme.Accent.primary)
                    .lineStyle(.init(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("lbs", entry.pounds)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [StackTheme.Accent.primary.opacity(0.25), StackTheme.Accent.primary.opacity(0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("lbs", entry.pounds)
                    )
                    .symbolSize(30)
                    .foregroundStyle(StackTheme.Accent.primary)
                }
                .chartXAxis(.hidden)
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
}
