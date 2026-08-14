import SwiftUI
import SwiftData

struct FitnessView: View {

    @Environment(\.modelContext) private var context
    @State private var viewModel = FitnessViewModel()
    @State private var healthViewModel = HealthViewModel()
    @State private var selectedSection: Section = .today

    enum Section: String, CaseIterable {
        case today   = "Today"
        case routine = "Routine"
        case body    = "Body"
        case sleep   = "Sleep"
        case cardio  = "Cardio"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionPicker

                Group {
                    switch selectedSection {
                    case .today:
                        TodayWorkoutView(viewModel: viewModel)
                    case .routine:
                        RoutineView()
                    case .body:
                        BodyView(viewModel: healthViewModel)
                    case .sleep:
                        SleepView(viewModel: healthViewModel)
                    case .cardio:
                        CardioView(viewModel: healthViewModel)
                    }
                }
            }
            .navigationTitle("Fitness")
            .navigationBarTitleDisplayMode(.inline)
            .background(StackTheme.Background.base.ignoresSafeArea())
            .onAppear {
                viewModel.setup(context: context)
                healthViewModel.setup(context: context)
                loadHealthDataIfNeeded(for: selectedSection)
            }
            .onChange(of: selectedSection) { _, section in
                loadHealthDataIfNeeded(for: section)
            }
        }
    }

    /// HealthKit fetches (and the first-run permission prompt) only happen once
    /// the user actually opens a health segment.
    private func loadHealthDataIfNeeded(for section: Section) {
        guard section == .body || section == .sleep || section == .cardio else { return }
        Task { await healthViewModel.loadHealthKitData() }
    }

    private var sectionPicker: some View {
        StackSegmentTabs(
            items: Section.allCases.map { ($0, $0.rawValue) },
            selection: $selectedSection
        )
        .padding(.vertical, 12)
    }
}

#Preview {
    FitnessView()
}
