import SwiftUI
import SwiftData

struct FitnessView: View {

    @Environment(\.modelContext) private var context
    @State private var viewModel = FitnessViewModel()
    @State private var selectedSection: Section = .today

    enum Section: String, CaseIterable {
        case today   = "Today"
        case routine = "Routine"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segment picker — filled for active, subtle for inactive
                HStack(spacing: StackTheme.Spacing.sm) {
                    ForEach(Section.allCases, id: \.self) { section in
                        Button {
                            selectedSection = section
                        } label: {
                            StackBadge(
                                text: section.rawValue,
                                color: StackTheme.Accent.primary,
                                style: selectedSection == section ? .filled : .subtle
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, StackTheme.Spacing.md)
                .padding(.vertical, 12)

                // Content
                Group {
                    switch selectedSection {
                    case .today:
                        TodayWorkoutView(viewModel: viewModel)
                    case .routine:
                        RoutineView()
                    }
                }
            }
            .navigationTitle("Fitness")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .background(StackTheme.Background.base.ignoresSafeArea())
            .onAppear {
                FitnessSeedService.seedIfNeeded(in: context)
                viewModel.setup(context: context)
            }
        }
    }
}

#Preview {
    FitnessView()
}
