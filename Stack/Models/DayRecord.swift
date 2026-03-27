import Foundation
import SwiftData

@Model
final class DayRecord {
    var dateKey: String        // "yyyy-MM-dd"
    var protocolRatio: Double  // 0.0–1.0
    var workoutCompleted: Bool
    var journalWritten: Bool
    var learningHours: Double
    var date: Date

    init(dateKey: String, date: Date = Date()) {
        self.dateKey = dateKey
        self.date = date
        self.protocolRatio = 0.0
        self.workoutCompleted = false
        self.journalWritten = false
        self.learningHours = 0.0
    }
}
