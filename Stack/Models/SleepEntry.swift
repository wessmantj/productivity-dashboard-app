import SwiftData
import Foundation

@Model
final class SleepEntry {
    var date: Date
    var hours: Double
    var quality: Int    // 1–5 star rating
    var note: String

    init(date: Date = Date(), hours: Double, quality: Int, note: String = "") {
        self.date = date
        self.hours = hours
        self.quality = quality
        self.note = note
    }
}
