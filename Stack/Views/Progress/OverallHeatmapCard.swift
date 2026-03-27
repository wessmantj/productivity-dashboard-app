import SwiftUI

struct OverallHeatmapCard: View {
    let viewModel: ProgressViewModel

    var body: some View {
        HeatmapCard(title: "Overall Year", type: .overall, viewModel: viewModel)
    }
}
