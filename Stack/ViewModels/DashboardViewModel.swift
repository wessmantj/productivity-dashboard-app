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

    // MARK: - Tasks
    var openTaskCount: Int = 0

    // MARK: - Internal

    private var modelContext: ModelContext?
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refresh()
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
        refreshCurrentBlock(context: context)
        refreshProgress(context: context)
        refreshWorkout(context: context)
        refreshTasks(context: context)
    }

    // MARK: - Header

    private func refreshHeader() {
        let hour = Calendar.current.component(.hour, from: Date())
        greetingPrefix = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMMM d"
        formattedDate = fmt.string(from: Date())
    }

    // MARK: - Current Block

    private func refreshCurrentBlock(context: ModelContext) {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        guard let blocks = try? context.fetch(
            FetchDescriptor<ScheduleBlock>(
                predicate: #Predicate<ScheduleBlock> { $0.dayOfWeek == todayWeekday }
            )
        ) else {
            currentBlockTitle = nil
            currentBlockTime = nil
            return
        }

        let nowMin = minutesSinceMidnight(Date())
        let sorted = blocks.compactMap { block -> (ScheduleBlock, Int)? in
            guard let min = parsedMinutes(block.time) else { return nil }
            return (block, min)
        }.sorted { $0.1 < $1.1 }

        var active: ScheduleBlock? = nil
        for (idx, (block, blockMin)) in sorted.enumerated() {
            let nextMin = idx + 1 < sorted.count ? sorted[idx + 1].1 : Int.max
            if nowMin >= blockMin && nowMin < nextMin {
                active = block
                break
            }
        }

        currentBlockTitle = active?.label
        currentBlockTime = active?.time
    }

    // MARK: - Progress

    private func refreshProgress(context: ModelContext) {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        guard let blocks = try? context.fetch(
            FetchDescriptor<ScheduleBlock>(
                predicate: #Predicate<ScheduleBlock> { $0.dayOfWeek == todayWeekday }
            )
        ) else { return }
        totalBlocks = blocks.count
        completedBlocks = blocks.filter { $0.isCompletedToday }.count
        completionRatio = totalBlocks > 0 ? Double(completedBlocks) / Double(totalBlocks) : 0
    }

    // MARK: - Workout

    private func refreshWorkout(context: ModelContext) {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        guard let workout = try? context.fetch(
            FetchDescriptor<WorkoutDay>(
                predicate: #Predicate<WorkoutDay> { $0.dayOfWeek == todayWeekday }
            )
        ).first else {
            todayWorkoutName = "No workout scheduled"
            todayWorkoutSubtitle = ""
            return
        }

        todayWorkoutName = workout.muscleGroup.isEmpty ? "No workout scheduled" : workout.muscleGroup

        if workout.isRestDay {
            todayWorkoutSubtitle = ""
        } else {
            let total = workout.exercises.count
            let done = workout.exercises.filter { $0.isCompleted }.count
            todayWorkoutSubtitle = total > 0
                ? "\(total) exercise\(total == 1 ? "" : "s") • \(done) of \(total) done"
                : ""
        }
    }

    // MARK: - Tasks

    private func refreshTasks(context: ModelContext) {
        let desc = FetchDescriptor<TaskItem>(
            predicate: #Predicate<TaskItem> { !$0.isComplete }
        )
        openTaskCount = (try? context.fetch(desc).count) ?? 0
    }

    // MARK: - Time helpers

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
    }

    func parsedMinutes(_ timeStr: String) -> Int? {
        let s = timeStr.lowercased().trimmingCharacters(in: .whitespaces)
        let isPM = s.hasSuffix("pm")
        let isAM = s.hasSuffix("am")
        guard isPM || isAM else { return nil }
        let clean = s
            .replacingOccurrences(of: "pm", with: "")
            .replacingOccurrences(of: "am", with: "")
            .trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return nil }
        var h = parts[0]
        let m = parts.count > 1 ? parts[1] : 0
        if isPM && h != 12 { h += 12 }
        if isAM && h == 12 { h = 0 }
        return h * 60 + m
    }
}
