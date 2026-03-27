import SwiftUI
import SwiftData

struct LearningView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LearningViewModel()
    @State private var segment: Segment = .roadmap

    enum Segment: String, CaseIterable {
        case roadmap = "Roadmap"
        case reading = "Reading"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segment picker using StackBadge pills
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
                case .roadmap: RoadmapView(viewModel: viewModel)
                case .reading: ReadingView(viewModel: viewModel)
                }
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .navigationTitle("Learn")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }
}
