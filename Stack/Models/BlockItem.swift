import SwiftData
import Foundation

@Model
final class BlockItem {
    var id: UUID = UUID()
    var title: String = ""
    var sortOrder: Int = 0
    var lastCompletedDate: Date? = nil
    var parentBlock: ScheduleBlock? = nil

    var isCompletedToday: Bool {
        guard let d = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(d)
    }

    init(
        id: UUID = UUID(),
        title: String = "",
        sortOrder: Int = 0,
        lastCompletedDate: Date? = nil,
        parentBlock: ScheduleBlock? = nil
    ) {
        self.id = id
        self.title = title
        self.sortOrder = sortOrder
        self.lastCompletedDate = lastCompletedDate
        self.parentBlock = parentBlock
    }
}
