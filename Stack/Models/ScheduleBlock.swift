import SwiftData
import Foundation

@Model
final class ScheduleBlock {
    var id: UUID = UUID()
    var dayOfWeek: Int = 0      // Calendar.weekday: 1=Sun, 2=Mon … 7=Sat
    var time: String = ""       // e.g. "7:20am", "10:30pm", "Variable"
    var label: String = ""
    var category: String = ""   // morning | class | deepwork | gym | body | commute | evening | sleep | free
    var sortOrder: Int = 0
    var lastCompletedDate: Date? = nil
    @Relationship(deleteRule: .cascade, inverse: \BlockItem.parentBlock) var items: [BlockItem] = []

    var isCompletedToday: Bool {
        if items.isEmpty {
            guard let d = lastCompletedDate else { return false }
            return Calendar.current.isDateInToday(d)
        }
        return items.allSatisfy { $0.isCompletedToday }
    }

    init(dayOfWeek: Int, time: String, label: String, category: String, sortOrder: Int) {
        self.dayOfWeek = dayOfWeek
        self.time = time
        self.label = label
        self.category = category
        self.sortOrder = sortOrder
    }
}
