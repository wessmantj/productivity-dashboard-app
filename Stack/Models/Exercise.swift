import SwiftData
import Foundation

@Model
final class Exercise {
    var name: String = ""
    var sets: Int = 0
    var reps: String = ""
    var weight: String = ""
    var isCompleted: Bool = false
    var sortOrder: Int = 0

    init(
        name: String = "",
        sets: Int = 3,
        reps: String = "8-12",
        weight: String = "",
        isCompleted: Bool = false,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}
