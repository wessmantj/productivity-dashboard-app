import SwiftData
import Foundation

@Model
final class ProtocolSection {
    var id: String
    var label: String
    var emoji: String
    var colorHex: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade) var items: [ProtocolItem]

    init(
        id: String,
        label: String,
        emoji: String,
        colorHex: String,
        sortOrder: Int,
        items: [ProtocolItem] = []
    ) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.items = items
    }
}
