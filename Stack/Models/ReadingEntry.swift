import Foundation
import SwiftData

@Model
final class ReadingEntry {
    var title: String
    var author: String
    var totalPages: Int
    var currentPage: Int
    var dailyGoalPages: Int
    var startedDate: Date
    var completedDate: Date?
    var notes: String

    init(title: String, author: String, totalPages: Int, currentPage: Int = 0,
         dailyGoalPages: Int, startedDate: Date = Date(), notes: String = "") {
        self.title = title
        self.author = author
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.dailyGoalPages = dailyGoalPages
        self.startedDate = startedDate
        self.completedDate = nil
        self.notes = notes
    }

    var isComplete: Bool { completedDate != nil }
    var pagesRemaining: Int { max(0, totalPages - currentPage) }
    var daysRemaining: Int {
        guard dailyGoalPages > 0 else { return 0 }
        return Int(ceil(Double(pagesRemaining) / Double(dailyGoalPages)))
    }
    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
}
