import Foundation
import Observation
import SwiftData

@Observable
final class ProtocolViewModel {

    // MARK: - Date state

    private var selectedDate: Date = Date()

    var selectedDateKey: String { Self.dateKey(selectedDate) }

    var displayDateFull: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMMM d"
        return fmt.string(from: selectedDate)
    }

    var selectedOffset: Int {
        let cal = Calendar.current
        if cal.isDateInYesterday(selectedDate) { return -1 }
        if cal.isDateInTomorrow(selectedDate)  { return  1 }
        return 0   // today (and any other day snaps to today for picker display)
    }

    // MARK: - Completion state

    private(set) var completedItems: Set<String> = []
    var totalItems: Int = 0

    var completedCount: Int { completedItems.count }

    var completionRatio: Double {
        guard totalItems > 0 else { return 0 }
        return Double(completedCount) / Double(totalItems)
    }

    // MARK: - Setup

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
        loadCompletions()
    }

    // MARK: - Date navigation

    func selectOffset(_ offset: Int) {
        let cal = Calendar.current
        guard let date = cal.date(byAdding: .day, value: offset, to: Date()) else { return }
        selectedDate = date
        loadCompletions()
    }

    // MARK: - Toggle

    func toggle(itemID: String) {
        if completedItems.contains(itemID) {
            completedItems.remove(itemID)
        } else {
            completedItems.insert(itemID)
        }
        persist()
        if let ctx = modelContext {
            DayRecordService.updateProtocol(ratio: completionRatio, for: selectedDateKey, in: ctx)
        }
    }

    // MARK: - Persistence

    private func loadCompletions() {
        guard let ctx = modelContext else { return }
        let key = selectedDateKey
        let descriptor = FetchDescriptor<DailyProtocol>(
            predicate: #Predicate<DailyProtocol> { $0.date == key }
        )
        let ids = (try? ctx.fetch(descriptor))?.first?.completedItems ?? []
        completedItems = Set(ids)
    }

    private func persist() {
        guard let ctx = modelContext else { return }
        let key = selectedDateKey
        let ids = Array(completedItems)
        let descriptor = FetchDescriptor<DailyProtocol>(
            predicate: #Predicate<DailyProtocol> { $0.date == key }
        )
        if let existing = (try? ctx.fetch(descriptor))?.first {
            existing.completedItems = ids
        } else {
            ctx.insert(DailyProtocol(date: key, completedItems: ids))
        }
    }

    // MARK: - Helpers

    private static func dateKey(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}
