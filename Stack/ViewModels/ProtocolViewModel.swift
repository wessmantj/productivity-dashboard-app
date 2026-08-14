import Foundation
import Observation
import SwiftData

@Observable
final class ProtocolViewModel {

    // MARK: - State
    var selectedDay: Int = Weekday.today
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
        let isToday = day == Weekday.today
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
        ScheduleTime.currentBlock(in: blocks, at: currentTime)?.persistentModelID
    }
}
