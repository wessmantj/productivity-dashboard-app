import Foundation
import SwiftData

@Model
final class Goal {
    var title: String
    var detail: String
    var category: String
    var targetDate: Date?
    var isAchieved: Bool
    var achievedDate: Date?
    var sortOrder: Int
    var colorHex: String

    init(title: String, detail: String, category: String,
         targetDate: Date? = nil, sortOrder: Int = 0, colorHex: String = "f59e0b") {
        self.title = title
        self.detail = detail
        self.category = category
        self.targetDate = targetDate
        self.isAchieved = false
        self.achievedDate = nil
        self.sortOrder = sortOrder
        self.colorHex = colorHex
    }
}
