import Foundation
import Observation
import SwiftData

@Observable
final class DashboardViewModel {

    // MARK: - Header
    var greetingPrefix: String = ""
    var userName: String = ""
    var formattedDate: String = ""

    // MARK: - Right Now
    var currentBlockTitle: String? = nil
    var currentBlockTime: String? = nil

    // MARK: - Today's Progress
    var completedBlocks: Int = 0
    var totalBlocks: Int = 0
    var completionRatio: Double = 0

    // MARK: - Today's Workout
    var todayWorkoutName: String = ""
    var todayWorkoutSubtitle: String = ""
    /// Exercise completion 0–1 (1.0 on rest days so the gauge reads "done").
    var workoutRatio: Double = 0

    // MARK: - Tasks
    var openTaskCount: Int = 0

    // MARK: - Activity (Fitbit → Apple Health)
    var hkSteps: Int? = nil
    var hkCalories: Int? = nil
    var hkRestingHR: Int? = nil

    // MARK: - Internal

    private var modelContext: ModelContext?
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    deinit { timer?.invalidate() }

    func setup(context: ModelContext) {
        modelContext = context
        refresh()
    }

    func refresh() {
        guard let context = modelContext else { return }
        refreshHeader()
        refreshSchedule(context: context)
        refreshWorkout(context: context)
        refreshTasks(context: context)
    }

    // MARK: - Header

    private func refreshHeader() {
        let hour = Calendar.current.component(.hour, from: Date())
        greetingPrefix = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        formattedDate = Date().longDisplay
    }

    // MARK: - Schedule (current block + progress)

    private func refreshSchedule(context: ModelContext) {
        let today = Weekday.today
        guard let blocks = try? context.fetch(
            FetchDescriptor<ScheduleBlock>(
                predicate: #Predicate<ScheduleBlock> { $0.dayOfWeek == today }
            )
        ) else {
            currentBlockTitle = nil
            currentBlockTime = nil
            return
        }

        let active = ScheduleTime.currentBlock(in: blocks)
        currentBlockTitle = active?.label
        currentBlockTime = active?.time

        totalBlocks = blocks.count
        completedBlocks = blocks.filter { $0.isCompletedToday }.count
        completionRatio = totalBlocks > 0 ? Double(completedBlocks) / Double(totalBlocks) : 0
    }

    // MARK: - Workout

    private func refreshWorkout(context: ModelContext) {
        let today = Weekday.today
        guard let workout = try? context.fetch(
            FetchDescriptor<WorkoutDay>(
                predicate: #Predicate<WorkoutDay> { $0.dayOfWeek == today }
            )
        ).first else {
            todayWorkoutName = "No workout scheduled"
            todayWorkoutSubtitle = ""
            workoutRatio = 0
            return
        }

        if workout.isRestDay {
            todayWorkoutName = "Rest Day"
            todayWorkoutSubtitle = "Recovery"
            workoutRatio = 1
        } else {
            todayWorkoutName = workout.muscleGroup.isEmpty ? "No workout scheduled" : workout.muscleGroup
            let total = workout.exercises.count
            let done = workout.exercises.filter { $0.isCompleted }.count
            todayWorkoutSubtitle = total > 0
                ? "\(done) of \(total) exercises"
                : ""
            workoutRatio = total > 0 ? Double(done) / Double(total) : 0
        }
    }

    // MARK: - Activity metrics

    func loadHealthMetrics() async {
        let svc = HealthKitService.shared
        async let steps = svc.fetchTodaySteps()
        async let calories = svc.fetchTodayActiveCalories()
        async let restingHR = svc.fetchRestingHeartRate()
        let (s, c, hr) = await (steps, calories, restingHR)
        await MainActor.run {
            hkSteps     = s
            hkCalories  = c
            hkRestingHR = hr
        }
    }

    // MARK: - Tasks

    private func refreshTasks(context: ModelContext) {
        let desc = FetchDescriptor<TaskItem>(
            predicate: #Predicate<TaskItem> { !$0.isComplete }
        )
        openTaskCount = (try? context.fetchCount(desc)) ?? 0
    }
}
