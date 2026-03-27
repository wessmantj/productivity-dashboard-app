import SwiftData
import Foundation

@Model
final class Supplement {
    var name: String
    var dose: String
    var time: String
    var isTakenToday: Bool
    var lastResetDate: Date

    init(
        name: String = "",
        dose: String = "",
        time: String = "Morning",
        isTakenToday: Bool = false,
        lastResetDate: Date = Date()
    ) {
        self.name = name
        self.dose = dose
        self.time = time
        self.isTakenToday = isTakenToday
        self.lastResetDate = lastResetDate
    }
}
