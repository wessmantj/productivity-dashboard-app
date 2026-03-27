import SwiftUI
import SwiftData

struct HealthView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HealthViewModel()
    @State private var segment: Segment = .body

    enum Segment: String, CaseIterable {
        case body   = "Body"
        case sleep  = "Sleep"
        case cardio = "Cardio"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segment picker
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
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

                switch segment {
                case .body:   BodyView(viewModel: viewModel)
                case .sleep:  SleepView(viewModel: viewModel)
                case .cardio: CardioView(viewModel: viewModel)
                }
            }
            .navigationTitle("Health")
            .background(StackTheme.Background.base.ignoresSafeArea())
        }
        .onAppear {
            viewModel.setup(context: modelContext)
            Task { await viewModel.loadHealthKitData() }
        }
    }
}
