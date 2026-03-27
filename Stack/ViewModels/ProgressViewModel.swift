import Foundation
import Observation
import SwiftData

// MARK: — Types

enum HeatmapType {
    case protocol_, workout, journal, learning, overall
}

enum IntensityLevel {
    case none, low, medium, high
}

// MARK: — ViewModel

@Observable
final class ProgressViewModel {

    private(set) var allRecords: [DayRecord] = []
    private var modelContext: ModelContext?

    // MARK: - Setup

    func setup(context: ModelContext) {
        modelContext = context
        loadRecords()
    }

    func refresh() { loadRecords() }

    private func loadRecords() {
        guard let ctx = modelContext else { return }
        let year = Calendar.current.component(.year, from: Date())
        let startKey = "\(year)-01-01"
        let endKey   = "\(year)-12-31"
        let descriptor = FetchDescriptor<DayRecord>(
            sortBy: [SortDescriptor(\.date)]
        )
        let all = (try? ctx.fetch(descriptor)) ?? []
        allRecords = all.filter { $0.dateKey >= startKey && $0.dateKey <= endKey }
    }

    // MARK: - Computed arrays

    var protocolRecords: [DayRecord] { allRecords.filter { $0.protocolRatio  > 0    } }
    var workoutRecords:  [DayRecord] { allRecords.filter { $0.workoutCompleted       } }
    var journalRecords:  [DayRecord] { allRecords.filter { $0.journalWritten         } }
    var learningRecords: [DayRecord] { allRecords.filter { $0.learningHours > 0     } }

    // MARK: - Stats

    var totalActiveDays: Int { allRecords.filter { isActive($0) }.count }

    var currentStreak: Int {
        var streak = 0
        var checkDate = Date()
        let cal = Calendar.current
        let dict = recordsByKey
        while true {
            let key = dateKey(from: checkDate)
            if let record = dict[key], isActive(record) {
                streak += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        let active = allRecords.filter { isActive($0) }.sorted { $0.date < $1.date }
        guard !active.isEmpty else { return 0 }
        var longest = 1
        var current = 1
        let cal = Calendar.current
        for i in 1..<active.count {
            let diff = cal.dateComponents([.day], from: active[i-1].date, to: active[i].date).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    // MARK: - Intensity

    func intensity(for record: DayRecord, type: HeatmapType) -> IntensityLevel {
        switch type {
        case .protocol_:
            guard record.protocolRatio > 0 else { return .none }
            if record.protocolRatio < 0.4 { return .low }
            if record.protocolRatio < 0.8 { return .medium }
            return .high

        case .workout:
            return record.workoutCompleted ? .high : .none

        case .journal:
            return record.journalWritten ? .high : .none

        case .learning:
            guard record.learningHours > 0 else { return .none }
            if record.learningHours < 1 { return .low }
            if record.learningHours < 3 { return .medium }
            return .high

        case .overall:
            let levels = [
                intensity(for: record, type: .protocol_),
                intensity(for: record, type: .workout),
                intensity(for: record, type: .journal),
                intensity(for: record, type: .learning)
            ]
            let active = levels.filter { $0 != .none }.count
            if active == 0 { return .none }
            if active == 1 { return .low }
            if active <= 3 { return .medium }
            return .high
        }
    }

    func activeDays(for type: HeatmapType) -> Int {
        allRecords.filter { intensity(for: $0, type: type) != .none }.count
    }

    // MARK: - Helpers

    var recordsByKey: [String: DayRecord] {
        Dictionary(uniqueKeysWithValues: allRecords.map { ($0.dateKey, $0) })
    }

    private func isActive(_ record: DayRecord) -> Bool {
        record.protocolRatio > 0 || record.workoutCompleted ||
        record.journalWritten  || record.learningHours > 0
    }

    private func dateKey(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}
