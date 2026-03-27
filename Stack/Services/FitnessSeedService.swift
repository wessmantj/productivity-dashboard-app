import SwiftData
import Foundation

struct FitnessSeedService {

    private struct E {
        let name: String
        let sets: Int
        let reps: String
        init(_ name: String, sets: Int, reps: String) {
            self.name = name; self.sets = sets; self.reps = reps
        }
    }

    private struct D {
        let dayOfWeek: Int
        let muscleGroup: String
        let isRestDay: Bool
        let exercises: [E]

        init(_ dayOfWeek: Int, _ muscleGroup: String, _ exercises: [E]) {
            self.dayOfWeek = dayOfWeek
            self.muscleGroup = muscleGroup
            self.isRestDay = false
            self.exercises = exercises
        }

        init(rest dayOfWeek: Int) {
            self.dayOfWeek = dayOfWeek
            self.muscleGroup = ""
            self.isRestDay = true
            self.exercises = []
        }
    }

    // MARK: — Public entry point

    static func seedIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "fitnessV2Seeded") else { return }
        clearAllWorkouts(in: context)
        seedV2(in: context)
        UserDefaults.standard.set(true, forKey: "fitnessV2Seeded")
    }

    // MARK: — Clear old data

    private static func clearAllWorkouts(in context: ModelContext) {
        let desc = FetchDescriptor<WorkoutDay>()
        if let workouts = try? context.fetch(desc) {
            for workout in workouts { context.delete(workout) }
        }
    }

    // MARK: — V2 seed (0 = Sunday … 6 = Saturday)

    private static func seedV2(in context: ModelContext) {
        let days: [D] = [
            D(rest: 0), // Sunday

            D(1, "Chest & Back", [
                E("T-Bar / Chest Supported Rows",  sets: 3, reps: "8-10"),
                E("Smith Machine Incline Press",    sets: 3, reps: "6-8"),
                E("Chest Flys",                    sets: 2, reps: "10-12"),
                E("Rear Delt Flys",                sets: 2, reps: "12"),
                E("Pulldowns / Pullups",            sets: 2, reps: "Failure"),
            ]),

            D(2, "Arms", [
                E("Seated Alternating Curls",       sets: 3, reps: "10-12"),
                E("Tricep Pushdowns",               sets: 3, reps: "8-10"),
                E("Preacher Curls",                 sets: 2, reps: "8-10"),
                E("Overhead / Single Arm Tricep",   sets: 2, reps: "8-10"),
                E("Close Grip Bicep Curls",         sets: 2, reps: "Failure"),
            ]),

            D(3, "Hamstrings & Shoulders", [
                E("Lying Hamstring Curls",          sets: 3, reps: "8-10"),
                E("Seated Hamstring Curls",         sets: 2, reps: "8-10"),
                E("Romanian Deadlifts",             sets: 2, reps: "8-10"),
                E("Seated Smith Machine Press",     sets: 3, reps: "8-10"),
                E("Rear Delt Flys",                 sets: 2, reps: "10-12"),
                E("Lateral Raises",                 sets: 3, reps: "Failure"),
            ]),

            D(4, "Quads & Calves", [
                E("Seated Calf Raises",             sets: 3, reps: "10-15"),
                E("Single Leg Extensions",          sets: 3, reps: "8-12"),
                E("Hack Squats",                    sets: 4, reps: "6-10"),
                E("Standing Calf Raises",           sets: 2, reps: "10-12"),
                E("Adductors (Inner)",              sets: 2, reps: "Failure"),
                E("Abductors (Outer)",              sets: 2, reps: "Failure"),
            ]),

            D(5, "Upper Body", [
                E("Smith Machine Shoulder Press",   sets: 2, reps: "8-10"),
                E("Chest Flys",                     sets: 2, reps: "10-12"),
                E("T-Bar / Chest Supported Rows",   sets: 3, reps: "6-8"),
                E("Seated Curls",                   sets: 2, reps: "Failure"),
                E("Tricep Pushdowns",               sets: 2, reps: "Failure"),
                E("Dips + Pullups (Superset)",      sets: 2, reps: "Failure"),
            ]),

            D(6, "Legs & Abs", [
                E("Seated Calf Raises",             sets: 3, reps: "10-12"),
                E("Seated Hamstring Curls",         sets: 3, reps: "10-12"),
                E("Leg Press",                      sets: 3, reps: "6-10"),
                E("Leg Extensions",                 sets: 2, reps: "10-12"),
                E("Romanian Deadlifts",             sets: 3, reps: "8-10"),
                E("Standing Calf Raises",           sets: 2, reps: "Failure"),
                E("Hanging Leg Raises",             sets: 2, reps: "Failure"),
                E("Machine Crunches",               sets: 2, reps: "Failure"),
            ]),
        ]

        for def in days {
            let workout = WorkoutDay(
                dayOfWeek: def.dayOfWeek,
                muscleGroup: def.muscleGroup,
                isRestDay: def.isRestDay
            )
            context.insert(workout)
            for (order, e) in def.exercises.enumerated() {
                let exercise = Exercise(
                    name: e.name,
                    sets: e.sets,
                    reps: e.reps,
                    sortOrder: order
                )
                context.insert(exercise)
                workout.exercises.append(exercise)
            }
        }
    }
}
