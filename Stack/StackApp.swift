import SwiftUI
import SwiftData

@main
struct StackApp: App {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    let container: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            WorkoutDay.self,
            Exercise.self,
            Supplement.self,
            WeightEntry.self,
            SleepEntry.self,
            CardioEntry.self,
            ScheduleBlock.self,
            BlockItem.self,
            DayRecord.self,
        ])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    WorkoutSeedService.seedIfNeeded(in: container.mainContext)
                    ScheduleSeedService.seedIfNeeded(in: container.mainContext)
                    ScheduleSeedService.seedBlockItemsIfNeeded(in: container.mainContext)
                    DailyResetService.runIfNeeded(in: container.mainContext)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        DailyResetService.runIfNeeded(in: container.mainContext)
                    }
                }
                .fullScreenCover(isPresented: Binding(
                    get: { !hasCompletedOnboarding },
                    set: { if !$0 { hasCompletedOnboarding = true } }
                )) {
                    OnboardingView()
                }
        }
        .modelContainer(container)
    }
}
