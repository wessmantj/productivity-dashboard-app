import SwiftUI
import SwiftData
#if os(iOS)
import UserNotifications
#endif

@main
struct StackApp: App {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    let container: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            HealthMetric.self,
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
            #if os(macOS)
                .frame(minWidth: 900, minHeight: 600)
            #endif
                .onAppear {
                    WorkoutSeedService.seedIfNeeded(in: container.mainContext)
                    ScheduleSeedService.seedIfNeeded(in: container.mainContext)
                    ScheduleSeedService.seedBlockItemsIfNeeded(in: container.mainContext)
                    requestNotificationAuth()
                }
                #if os(iOS)
                .fullScreenCover(isPresented: Binding(
                    get: { !hasCompletedOnboarding },
                    set: { if !$0 { hasCompletedOnboarding = true } }
                )) {
                    OnboardingView()
                }
                #else
                .sheet(isPresented: Binding(
                    get: { !hasCompletedOnboarding },
                    set: { if !$0 { hasCompletedOnboarding = true } }
                )) {
                    OnboardingView()
                }
                #endif
        }
        .modelContainer(container)
        #if os(macOS)
        .defaultSize(width: 1100, height: 750)
        #endif
    }

    private func requestNotificationAuth() {
        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
        #endif
    }
}
