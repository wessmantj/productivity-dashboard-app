import Foundation
import SwiftData

/// Rolls daily state forward when the app is opened on a new calendar day.
/// Runs at launch and whenever the app returns to the foreground, so workout
/// checkmarks and supplement toggles never carry over from a previous day
/// (or a previous week, since workouts are keyed by weekday).
enum DailyResetService {

    private static let lastResetKey = "lastDailyResetKey"

    static func runIfNeeded(in context: ModelContext) {
        let todayKey = Date().dateKey
        guard UserDefaults.standard.string(forKey: lastResetKey) != todayKey else { return }

        resetWorkouts(in: context)
        resetSupplements(in: context)
        cleanUpOrphanBlocks(in: context)
        purgeStaleNutritionKeys()
        try? context.save()

        UserDefaults.standard.set(todayKey, forKey: lastResetKey)
    }

    /// Clears completion state on every workout day. History is preserved in
    /// DayRecord, so this only affects the live checklist UI.
    private static func resetWorkouts(in context: ModelContext) {
        guard let workouts = try? context.fetch(FetchDescriptor<WorkoutDay>()) else { return }
        for workout in workouts {
            if workout.isCompleted || workout.completedDate != nil {
                workout.isCompleted = false
                workout.completedDate = nil
            }
            for exercise in workout.exercises where exercise.isCompleted {
                exercise.isCompleted = false
            }
        }
    }

    private static func resetSupplements(in context: ModelContext) {
        guard let supplements = try? context.fetch(FetchDescriptor<Supplement>()) else { return }
        for supplement in supplements where supplement.isTakenToday {
            supplement.isTakenToday = false
            supplement.lastResetDate = Date()
        }
    }

    /// Nutrition status is stored under per-day UserDefaults keys
    /// ("fitnessNutrition<yyyy-MM-dd>"); drop everything except today's so
    /// the keys don't accumulate forever.
    private static func purgeStaleNutritionKeys() {
        let defaults = UserDefaults.standard
        let todayKey = "fitnessNutrition" + Date().dateKey
        for key in defaults.dictionaryRepresentation().keys
        where key.hasPrefix("fitnessNutrition") && key != todayKey {
            defaults.removeObject(forKey: key)
        }
    }

    /// A past bug wrote schedule blocks with a 0-based weekday, which never
    /// matches the 1–7 Calendar.weekday convention and so never renders.
    /// Remove anything outside the valid range.
    private static func cleanUpOrphanBlocks(in context: ModelContext) {
        guard let blocks = try? context.fetch(
            FetchDescriptor<ScheduleBlock>(
                predicate: #Predicate<ScheduleBlock> { $0.dayOfWeek < 1 || $0.dayOfWeek > 7 }
            )
        ) else { return }
        blocks.forEach { context.delete($0) }
    }
}
