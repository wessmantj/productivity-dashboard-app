import SwiftData
import Foundation

@Model
final class ProtocolItem {
    var id: String = ""
    var text: String = ""
    var sortOrder: Int = 0

    init(id: String, text: String, sortOrder: Int) {
        self.id = id
        self.text = text
        self.sortOrder = sortOrder
    }
}
