import SwiftData
import Foundation

@Model
final class WeightEntry {
    var date: Date = Date()
    var pounds: Double = 0.0
    var note: String = ""

    init(date: Date = Date(), pounds: Double, note: String = "") {
        self.date = date
        self.pounds = pounds
        self.note = note
    }
}
