import SwiftData
import Foundation

struct WorkoutSeedService {

    private struct E {
        let name: String
        let sets: Int
        let reps: String
        init(_ name: String, _ sets: Int, _ reps: String) {
            self.name = name; self.sets = sets; self.reps = reps
        }
    }

    static func seedIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "workoutSummerV1Seeded") else { return }
        clearAll(in: context)
        seed(in: context)
        UserDefaults.standard.set(true, forKey: "workoutSummerV1Seeded")
    }

    private static func clearAll(in context: ModelContext) {
        if let days = try? context.fetch(FetchDescriptor<WorkoutDay>()) {
            days.forEach { context.delete($0) }
        }
    }

    private static func makeDay(
        _ dayOfWeek: Int,
        _ muscleGroup: String,
        _ exercises: [E],
        isRest: Bool = false,
        in context: ModelContext
    ) {
        let workout = WorkoutDay(dayOfWeek: dayOfWeek, muscleGroup: muscleGroup, isRestDay: isRest)
        context.insert(workout)
        for (order, e) in exercises.enumerated() {
            let exercise = Exercise(name: e.name, sets: e.sets, reps: e.reps, sortOrder: order)
            context.insert(exercise)
            workout.exercises.append(exercise)
        }
    }

    // MARK: — Seed (Calendar.weekday: 1=Sun, 2=Mon … 7=Sat)

    private static func seed(in context: ModelContext) {

        // Monday (2) — Push
        makeDay(2, "Push (Chest, Shoulders, Triceps)", [
            E("Smith Incline Press",          3, "6–8"),
            E("Machine Press or Flys",        3, "8–10"),
            E("Seated Shoulder Press",        3, "8–10"),
            E("Cable Lateral Raises",         3, "12–15"),
            E("Tricep Pushdowns",             3, "8–10"),
            E("Overhead Tricep Extension",    2, "10–12"),
        ], in: context)

        // Tuesday (3) — Pull
        makeDay(3, "Pull (Back, Biceps, Rear Delts)", [
            E("T-Bar or Chest-Supported Row", 3, "6–8"),
            E("Lat Pulldown or Pullup",       3, "8–10"),
            E("Seated Cable Row",             2, "8–10"),
            E("Rear Delt Fly",                2, "12–15"),
            E("Preacher Curl",                3, "8–10"),
            E("Hammer Curl",                  2, "10–12"),
        ], in: context)

        // Wednesday (4) — Lower Quad
        makeDay(4, "Lower (Quad Focus)", [
            E("Leg Extension",                3, "10–12"),
            E("Hack Squat",                   3, "6–8"),
            E("Walking Lunge or Split Squat", 2, "10/leg"),
            E("Adductors",                    2, "12–15"),
            E("Standing Calf Raise",          3, "10–12"),
            E("Seated Calf Raise",            2, "12–15"),
        ], in: context)

        // Thursday (5) — Rest
        makeDay(5, "Rest & Active Recovery", [], isRest: true, in: context)

        // Friday (6) — Upper Blend
        makeDay(6, "Upper (Blend)", [
            E("Smith Incline Press",          2, "6–8"),
            E("Chest-Supported Row",          2, "8–10"),
            E("Cable Lateral Raises",         3, "12–15"),
            E("Lat Pulldown",                 2, "10–12"),
            E("Dips or Tricep Pushdowns",     2, "8–12"),
            E("DB or Cable Curl",             2, "10–12"),
        ], in: context)

        // Saturday (7) — Lower Posterior + Abs
        makeDay(7, "Lower (Posterior) + Abs", [
            E("Romanian Deadlift",            3, "8–10"),
            E("Lying Hamstring Curl",         3, "10–12"),
            E("Seated Hamstring Curl",        2, "10–12"),
            E("Glute Focus",                  2, "10–12"),
            E("Abductors",                    2, "12–15"),
            E("Hanging Leg Raise",            3, "10–15"),
            E("Cable Crunch",                 2, "12–15"),
        ], in: context)

        // Sunday (1) — Rest
        makeDay(1, "Rest & Synthesis", [], isRest: true, in: context)
    }
}
