import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String = ""
    var detail: String = ""
    var isComplete: Bool = false
    var priority: Int = 0           // 0 = low, 1 = medium, 2 = high
    var dueDate: Date?
    var completedDate: Date?
    var category: String = ""       // "Personal", "Learning", "Work", "Health", "Other"
    var sortOrder: Int = 0
    var reminderDate: Date?
    var hasReminder: Bool = false

    init(title: String, detail: String = "", priority: Int = 1,
         dueDate: Date? = nil, category: String = "Personal",
         sortOrder: Int = 0, reminderDate: Date? = nil, hasReminder: Bool = false) {
        self.title = title
        self.detail = detail
        self.isComplete = false
        self.priority = priority
        self.dueDate = dueDate
        self.completedDate = nil
        self.category = category
        self.sortOrder = sortOrder
        self.reminderDate = reminderDate
        self.hasReminder = hasReminder
    }

    var isOverdue: Bool {
        guard !isComplete, let due = dueDate else { return false }
        return due < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let due = dueDate else { return false }
        return Calendar.current.isDateInToday(due)
    }
}
