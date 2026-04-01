import Foundation
import SwiftData

@Model
final class Quote {
    var text: String = ""
    var author: String = ""
    var isFavorite: Bool = false
    var sortOrder: Int = 0
    var dateAdded: Date = Date()

    init(text: String, author: String, sortOrder: Int = 0) {
        self.text = text
        self.author = author
        self.isFavorite = false
        self.sortOrder = sortOrder
        self.dateAdded = Date()
    }
}
