import SwiftUI
import SwiftData

struct VisionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = VisionViewModel()
    @State private var segment: Segment = .board

    enum Segment: String, CaseIterable {
        case board  = "Board"
        case goals  = "Goals"
        case quotes = "Quotes"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segment picker using StackBadge
                HStack(spacing: StackTheme.Spacing.sm) {
                    ForEach(Segment.allCases, id: \.self) { seg in
                        Button {
                            segment = seg
                        } label: {
                            StackBadge(
                                text: seg.rawValue,
                                color: StackTheme.Accent.primary,
                                style: segment == seg ? .filled : .subtle
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.vertical, StackTheme.Spacing.sm)

                switch segment {
                case .board:  BoardView(viewModel: viewModel)
                case .goals:  GoalsView(viewModel: viewModel)
                case .quotes: QuotesView(viewModel: viewModel)
                }
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .navigationTitle("Vision")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }
}
