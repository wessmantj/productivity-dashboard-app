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
                            label: "Current Streak",
                            icon: "flame.fill"
                        )
                        StackStatCard(
                            value: "\(viewModel.longestStreak)",
                            label: "Longest Streak",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        StackStatCard(
                            value: "\(viewModel.totalActiveDays)",
                            label: "Active Days",
                            icon: "calendar"
                        )
                    }

                    // Overall heatmap
                    OverallHeatmapCard(viewModel: viewModel)

                    // Individual heatmaps
                    HeatmapCard(title: "Protocol",  type: .protocol_, viewModel: viewModel)
                    HeatmapCard(title: "Workout",   type: .workout,   viewModel: viewModel)
                    HeatmapCard(title: "Journal",   type: .journal,   viewModel: viewModel)
                    HeatmapCard(title: "Learning",  type: .learning,  viewModel: viewModel)
                }
                .padding(StackTheme.Spacing.md)
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }
}
