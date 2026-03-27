import SwiftData
import Foundation

@Model
final class DailyProtocol {
    var date: String          // "yyyy-MM-dd"
    var completedItems: [String]  // item ID strings

    init(date: String, completedItems: [String] = []) {
        self.date = date
        self.completedItems = completedItems
    }
}
