import SwiftData
import Foundation

@Model
final class WorkoutDay {
    var dayOfWeek: Int
    var muscleGroup: String
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]
    var isRestDay: Bool
    var isCompleted: Bool
    var completedDate: Date?

    init(
        dayOfWeek: Int,
        muscleGroup: String = "",
        exercises: [Exercise] = [],
        isRestDay: Bool = false,
        isCompleted: Bool = false,
        completedDate: Date? = nil
    ) {
        self.dayOfWeek = dayOfWeek
        self.muscleGroup = muscleGroup
        self.exercises = exercises
        self.isRestDay = isRestDay
        self.isCompleted = isCompleted
        self.completedDate = completedDate
    }
}
