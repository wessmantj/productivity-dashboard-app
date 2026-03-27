import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = JournalViewModel()
    @State private var segment: Segment = .today

    enum Segment: String, CaseIterable {
        case today   = "Today"
        case history = "History"
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
                case .today:   TodayJournalView(viewModel: viewModel)
                case .history: JournalHistoryView(viewModel: viewModel)
                }
            }
            .background(StackTheme.Background.base.ignoresSafeArea())
            .navigationTitle("Journal")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }
}
