import Foundation
import SwiftData

@Model
final class LearningPhase {
    var order: Int
    var title: String
    var durationWeeks: Int
    @Relationship(deleteRule: .cascade) var weeks: [LearningWeek]
    var isExpanded: Bool

    init(order: Int, title: String, durationWeeks: Int, isExpanded: Bool = false) {
        self.order = order
        self.title = title
        self.durationWeeks = durationWeeks
        self.weeks = []
        self.isExpanded = isExpanded
    }
}
