import Foundation
import Observation
import SwiftData

@Observable
final class FitnessViewModel {

    // MARK: - Nutrition tracking (stored in UserDefaults, keyed by date string)

    private let nutritionKey = "fitnessNutrition"

    var nutritionStatus: NutritionStatus {
        get {
            let key = nutritionKey + todayKey
            let raw = UserDefaults.standard.integer(forKey: key)
            return NutritionStatus(rawValue: raw) ?? .onTrack
        }
        set {
            let key = nutritionKey + todayKey
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }

    enum NutritionStatus: Int, CaseIterable {
        case onTrack = 0
        case okay    = 1
        case offTrack = 2

        var label: String {
            switch self {
            case .onTrack:  return "🟢 On Track"
            case .okay:     return "🟡 Okay"
            case .offTrack: return "🔴 Off Track"
            }
        }
    }

    // MARK: - Date helpers

    var todayWeekday: Int {
        Calendar.current.component(.weekday, from: Date()) - 1  // 0 = Sunday
    }

    private var todayKey: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    // MARK: - Supplement reset

    func resetSupplementsIfNeeded(_ supplements: [Supplement]) {
        for supplement in supplements where !isToday(supplement.lastResetDate) {
            supplement.isTakenToday = false
            supplement.lastResetDate = Date()
        }
    }

    // MARK: - Progress

    func progress(for workout: WorkoutDay) -> Double {
        let total = workout.exercises.count
        guard total > 0 else { return 0 }
        let done = workout.exercises.filter(\.isCompleted).count
        return Double(done) / Double(total)
    }

    // MARK: - Model context

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
    }

    // MARK: - Complete workout

    func completeWorkout(_ workout: WorkoutDay) {
        for exercise in workout.exercises {
            exercise.isCompleted = true
        }
        workout.isCompleted = true
        workout.completedDate = Date()
        if let ctx = modelContext {
            DayRecordService.updateWorkout(completed: true, for: todayKey, in: ctx)
        }
    }

    // MARK: - Reset today's workout

    func resetWorkout(_ workout: WorkoutDay) {
        for exercise in workout.exercises {
            exercise.isCompleted = false
        }
        workout.isCompleted = false
        workout.completedDate = nil
    }
}
