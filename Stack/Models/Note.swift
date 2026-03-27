import SwiftData
import Foundation

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
    }
}
