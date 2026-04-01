import SwiftData
import Foundation

@Model
final class HealthMetric {
    var id: UUID = UUID()
    var type: String = ""
    var value: Double = 0.0
    var unit: String = ""
    var recordedAt: Date = Date()

    init(
        id: UUID = UUID(),
        type: String = "",
        value: Double = 0,
        unit: String = "",
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.unit = unit
        self.recordedAt = recordedAt
    }
}
