import Foundation
import SwiftData

@Model
final class LearningPhase {
    var order: Int = 0
    var title: String = ""
    var durationWeeks: Int = 0
    @Relationship(deleteRule: .cascade) var weeks: [LearningWeek] = []
    var isExpanded: Bool = false

    init(order: Int, title: String, durationWeeks: Int, isExpanded: Bool = false) {
        self.order = order
        self.title = title
        self.durationWeeks = durationWeeks
        self.weeks = []
        self.isExpanded = isExpanded
    }
}
