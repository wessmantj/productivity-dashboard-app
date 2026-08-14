import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()

    private let statColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StackTheme.Spacing.lg) {

                    // Stats row
                    LazyVGrid(columns: statColumns, spacing: StackTheme.Spacing.sm) {
                        StackStatCard(
                            value: "\(viewModel.currentStreak)",
                            unit: "d",
                            label: "Streak",
                            icon: "flame.fill",
                            iconColor: viewModel.currentStreak > 0
                                ? StackTheme.Accent.positive
                                : StackTheme.Accent.primary
                        )
                        StackStatCard(
                            value: "\(viewModel.longestStreak)",
                            unit: "d",
                            label: "Best",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        StackStatCard(
                            value: "\(viewModel.totalActiveDays)",
                            label: "Active",
                            icon: "calendar"
                        )
                    }

                    // Overall heatmap
                    HeatmapCard(title: "Overall Year", type: .overall, viewModel: viewModel)

                    // Individual heatmaps
                    HeatmapCard(title: "Protocol",  type: .protocol_, viewModel: viewModel)
                    HeatmapCard(title: "Workout",   type: .workout,   viewModel: viewModel)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }
}
