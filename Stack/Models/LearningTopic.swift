import Foundation
import SwiftData

@Model
final class LearningTopic {
    var order: Int = 0
    var title: String = ""
    var detail: String = ""
    var isComplete: Bool = false
    var topicType: String = ""   // "theory", "implementation", "milestone"

    init(order: Int, title: String, detail: String = "", topicType: String = "theory") {
        self.order = order
        self.title = title
        self.detail = detail
        self.isComplete = false
        self.topicType = topicType
    }
}
