import Foundation
import Observation
import SwiftData

@Observable
final class FitnessViewModel {

    // MARK: - Nutrition tracking (persisted per day in UserDefaults)

    enum NutritionStatus: Int, CaseIterable {
        case onTrack  = 0
        case okay     = 1
        case offTrack = 2

        var label: String {
            switch self {
            case .onTrack:  return "On Track"
            case .okay:     return "Okay"
            case .offTrack: return "Off Track"
            }
        }
    }

    // Stored (not computed) so @Observable actually notifies the UI;
    // persisted under a per-day key so it resets each morning.
    private(set) var nutritionStatus: NutritionStatus = .onTrack
    private var nutritionLoadedForKey: String = ""

    private var nutritionKey: String { "fitnessNutrition" + Date().dateKey }

    func setNutritionStatus(_ status: NutritionStatus) {
        nutritionStatus = status
        nutritionLoadedForKey = Date().dateKey
        UserDefaults.standard.set(status.rawValue, forKey: nutritionKey)
    }

    /// Reloads today's stored value; cheap to call from onAppear so the
    /// selection rolls over correctly when a new day starts.
    func refreshNutritionStatus() {
        let key = Date().dateKey
        guard nutritionLoadedForKey != key else { return }
        nutritionLoadedForKey = key
        let raw = UserDefaults.standard.integer(forKey: nutritionKey)
        nutritionStatus = NutritionStatus(rawValue: raw) ?? .onTrack
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
        refreshNutritionStatus()
    }

    // MARK: - Complete workout

    func completeWorkout(_ workout: WorkoutDay) {
        for exercise in workout.exercises {
            exercise.isCompleted = true
        }
        workout.isCompleted = true
        workout.completedDate = Date()
        if let ctx = modelContext {
            DayRecordService.updateWorkout(completed: true, for: Date().dateKey, in: ctx)
        }
    }
}
