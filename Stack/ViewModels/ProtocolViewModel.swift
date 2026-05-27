import Foundation
import Observation
import SwiftData

@Observable
final class ProtocolViewModel {

    // MARK: - State
    var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    var expandedBlockIDs: Set<UUID> = []

    // MARK: - Timer
    private(set) var currentTime: Date = Date()
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }

    deinit { timer?.invalidate() }

    // MARK: - Filtering

    func blocks(for day: Int, from allBlocks: [ScheduleBlock]) -> [ScheduleBlock] {
        // day is Calendar.weekday (1=Sun, 2=Mon … 7=Sat) — stored directly in dayOfWeek
        return allBlocks.filter { $0.dayOfWeek == day }.sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Expansion

    func toggleExpanded(_ blockID: UUID) {
        if expandedBlockIDs.contains(blockID) {
            expandedBlockIDs.remove(blockID)
        } else {
            expandedBlockIDs.insert(blockID)
        }
    }

    // MARK: - Completion

    func completionCount(for day: Int, from allBlocks: [ScheduleBlock]) -> (completed: Int, total: Int) {
        let dayBlocks = blocks(for: day, from: allBlocks)
        let isToday = day == Calendar.current.component(.weekday, from: Date())
        if isToday {
            return (dayBlocks.filter { $0.isCompletedToday }.count, dayBlocks.count)
        }
        return (0, dayBlocks.count)
    }

    func toggleBlockCompletion(_ block: ScheduleBlock, context: ModelContext) {
        if block.items.isEmpty {
            block.lastCompletedDate = block.isCompletedToday ? nil : Date()
        } else {
            let allDone = block.items.allSatisfy { $0.isCompletedToday }
            let target: Date? = allDone ? nil : Date()
            for item in block.items {
                item.lastCompletedDate = target
            }
        }
        try? context.save()
    }

    func toggleItemCompletion(_ item: BlockItem, context: ModelContext) {
        item.lastCompletedDate = item.isCompletedToday ? nil : Date()
        try? context.save()
    }

    // MARK: - Current block

    func currentBlockID(for blocks: [ScheduleBlock]) -> PersistentIdentifier? {
        let nowMin = minutesSinceMidnight(currentTime)
        let sorted = blocks.compactMap { block -> (ScheduleBlock, Int)? in
            guard let min = minutesSinceMidnightStr(block.time) else { return nil }
            return (block, min)
        }.sorted { $0.1 < $1.1 }

        for (idx, (block, blockMin)) in sorted.enumerated() {
            let nextMin = idx + 1 < sorted.count ? sorted[idx + 1].1 : Int.max
            if nowMin >= blockMin && nowMin < nextMin {
                return block.persistentModelID
            }
        }
        return nil
    }

    // MARK: - Helpers

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
    }

    func minutesSinceMidnightStr(_ timeStr: String) -> Int? {
        let s = timeStr.lowercased().trimmingCharacters(in: .whitespaces)
        guard s != "variable", s != "all day" else { return nil }
        let isPM = s.hasSuffix("pm")
        let isAM = s.hasSuffix("am")
        let clean = s
            .replacingOccurrences(of: "pm", with: "")
            .replacingOccurrences(of: "am", with: "")
            .trimmingCharacters(in: .whitespaces)
        let parts = clean.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return nil }
        var h = parts[0]
        let m = parts.count > 1 ? parts[1] : 0
        if isPM && h != 12 { h += 12 }
        if isAM && h == 12 { h = 0 }
        return h * 60 + m
    }
}
