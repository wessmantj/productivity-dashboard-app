import Foundation
import SwiftData

@Model
final class Affirmation {
    var text: String
    var sortOrder: Int
    var isActive: Bool

    init(text: String, sortOrder: Int = 0, isActive: Bool = true) {
        self.text = text
        self.sortOrder = sortOrder
        self.isActive = isActive
    }
}
