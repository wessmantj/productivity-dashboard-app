import SwiftData
import Foundation

@Model
final class CardioEntry {
    var date: Date = Date()
    var type: String = ""
    var durationMinutes: Int = 0
    var distanceMiles: Double = 0.0
    var calories: Int = 0
    var note: String = ""

    init(
        date: Date = Date(),
        type: String,
        durationMinutes: Int,
        distanceMiles: Double = 0,
        calories: Int = 0,
        note: String = ""
    ) {
        self.date = date
        self.type = type
        self.durationMinutes = durationMinutes
        self.distanceMiles = distanceMiles
        self.calories = calories
        self.note = note
    }
}
