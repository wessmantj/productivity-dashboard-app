import Foundation
import SwiftData

enum DayRecordService {

    @discardableResult
    static func record(for dateKey: String, in context: ModelContext) -> DayRecord {
        let descriptor = FetchDescriptor<DayRecord>(
            predicate: #Predicate<DayRecord> { $0.dateKey == dateKey }
        )
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let date = fmt.date(from: dateKey) ?? Date()
        let record = DayRecord(dateKey: dateKey, date: date)
        context.insert(record)
        return record
    }

    static func updateProtocol(ratio: Double, for dateKey: String, in context: ModelContext) {
        record(for: dateKey, in: context).protocolRatio = ratio
    }

    static func updateWorkout(completed: Bool, for dateKey: String, in context: ModelContext) {
        record(for: dateKey, in: context).workoutCompleted = completed
    }

    static func updateJournal(written: Bool, for dateKey: String, in context: ModelContext) {
        record(for: dateKey, in: context).journalWritten = written
    }

    static func updateLearning(hours: Double, for dateKey: String, in context: ModelContext) {
        record(for: dateKey, in: context).learningHours = hours
    }
}
