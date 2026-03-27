import Foundation
import Observation
import SwiftData

@Observable
final class JournalViewModel {

    private(set) var entries: [JournalEntry] = []
    var errorMessage: String? = nil

    var todayEntry: JournalEntry? {
        entries.first { $0.dateKey == JournalEntry.todayKey }
    }

    var totalEntries: Int { entries.count }

    var totalWords: Int { entries.reduce(0) { $0 + $1.wordCount } }

    var currentStreak: Int {
        var streak = 0
        var checkDate = Date()
        let keys = Set(entries.map { $0.dateKey })
        while keys.contains(JournalEntry.makeKey(checkDate)) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
        loadAll()
    }

    private func loadAll() {
        guard let ctx = modelContext else { return }
        do {
            let desc = FetchDescriptor<JournalEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            entries = try ctx.fetch(desc)
        } catch {}
    }

    // MARK: - Save / upsert today's entry

    func saveEntry(body: String, mood: Int, tags: [String]) {
        guard let ctx = modelContext else { return }
        let words = body.split(whereSeparator: \.isWhitespace).count

        if let existing = todayEntry {
            existing.body = body
            existing.mood = mood
            existing.tags = tags
            existing.wordCount = words
            existing.date = Date()
        } else {
            let entry = JournalEntry(body: body, mood: mood, tags: tags)
            entry.wordCount = words
            ctx.insert(entry)
            entries.insert(entry, at: 0)
        }
        do { try ctx.save() } catch { errorMessage = error.localizedDescription }
        DayRecordService.updateJournal(written: true, for: JournalEntry.todayKey, in: ctx)
    }

    func deleteEntry(_ entry: JournalEntry) {
        guard let ctx = modelContext else { return }
        ctx.delete(entry)
        do { try ctx.save() } catch { errorMessage = error.localizedDescription }
        entries.removeAll { $0 === entry }
    }
}
