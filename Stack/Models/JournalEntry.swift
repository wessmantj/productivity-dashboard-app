import Foundation
import SwiftData

@Model
final class JournalEntry {
    var date: Date = Date()
    var dateKey: String = ""        // "yyyy-MM-dd" for deduplication
    var body: String = ""
    var mood: Int = 0               // 1–5
    var wordCount: Int = 0
    var tags: [String] = []

    init(date: Date = Date(), body: String = "", mood: Int = 3, tags: [String] = []) {
        self.date = date
        self.dateKey = Self.makeKey(date)
        self.body = body
        self.mood = mood
        self.wordCount = body.split(separator: " ").count
        self.tags = tags
    }

    static func makeKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    static var todayKey: String { makeKey(Date()) }
}
