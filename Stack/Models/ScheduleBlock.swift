import SwiftData
import Foundation

@Model
final class ScheduleBlock {
    var dayOfWeek: Int      // 0 = Monday … 6 = Sunday
    var time: String        // e.g. "7:20", "10:30pm", "Variable"
    var label: String
    var category: String    // morning | class | deepwork | gym | body | commute | evening | sleep | free
    var sortOrder: Int

    init(dayOfWeek: Int, time: String, label: String, category: String, sortOrder: Int) {
        self.dayOfWeek = dayOfWeek
        self.time = time
        self.label = label
        self.category = category
        self.sortOrder = sortOrder
    }
}
