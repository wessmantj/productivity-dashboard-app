import SwiftData
import Foundation

@Model
final class HealthMetric {
    var id: UUID
    var type: String
    var value: Double
    var unit: String
    var recordedAt: Date

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
