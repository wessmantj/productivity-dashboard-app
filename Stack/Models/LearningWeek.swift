import Foundation
import SwiftData

@Model
final class LearningWeek {
    var order: Int
    var title: String
    @Relationship(deleteRule: .cascade) var topics: [LearningTopic]
    var theoryHours: Double
    var implementationHours: Double
    var synthesisHours: Double
    var weeklyHourTarget: Double
    var isComplete: Bool
    var notes: String
    var startedDate: Date?
    var completedDate: Date?

    init(order: Int, title: String, weeklyHourTarget: Double = 20.0) {
        self.order = order
        self.title = title
        self.topics = []
        self.theoryHours = 0
        self.implementationHours = 0
        self.synthesisHours = 0
        self.weeklyHourTarget = weeklyHourTarget
        self.isComplete = false
        self.notes = ""
        self.startedDate = nil
        self.completedDate = nil
    }

    var totalHours: Double { theoryHours + implementationHours + synthesisHours }
    var completedTopicCount: Int { topics.filter { $0.isComplete }.count }
    var allTopicsComplete: Bool { !topics.isEmpty && topics.allSatisfy { $0.isComplete } }
}
