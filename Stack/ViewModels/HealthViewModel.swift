import Foundation
import Observation
import SwiftData

@Observable
final class HealthViewModel {

    // MARK: - SwiftData entries

    private(set) var weightEntries: [WeightEntry] = []
    private(set) var sleepEntries: [SleepEntry]   = []
    private(set) var cardioEntries: [CardioEntry] = []

    // MARK: - HealthKit values

    var hkWeight: Double?        = nil
    var hkSleep: Double?         = nil
    var hkCalories: Int?         = nil
    var isLoadingHealthData: Bool = false

    // MARK: - Computed

    var currentWeight: Double? {
        weightEntries.first?.pounds ?? hkWeight
    }

    var weightIsFromHK: Bool {
        weightEntries.isEmpty && hkWeight != nil
    }

    var weeklyAvgSleep: Double {
        let week = Array(sleepEntries.prefix(7))
        guard !week.isEmpty else { return 0 }
        return week.reduce(0) { $0 + $1.hours } / Double(week.count)
    }

    /// Last 14 entries in ascending date order for charting.
    var weightTrend: [WeightEntry] {
        Array(weightEntries.prefix(14)).reversed()
    }

    var last7Sleep: [SleepEntry] {
        Array(sleepEntries.prefix(7)).reversed()
    }

    var weeklyCardioCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return cardioEntries.filter { $0.date >= cutoff }.count
    }

    var weeklyCardioMinutes: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return cardioEntries.filter { $0.date >= cutoff }.reduce(0) { $0 + $1.durationMinutes }
    }

    // MARK: - Setup

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
        loadEntries()
    }

    private func loadEntries() {
        guard let ctx = modelContext else { return }
        do {
            var wDesc = FetchDescriptor<WeightEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            wDesc.fetchLimit = 30
            weightEntries = try ctx.fetch(wDesc)

            var sDesc = FetchDescriptor<SleepEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            sDesc.fetchLimit = 14
            sleepEntries = try ctx.fetch(sDesc)

            var cDesc = FetchDescriptor<CardioEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            cDesc.fetchLimit = 14
            cardioEntries = try ctx.fetch(cDesc)
        } catch {
            // Fetch failed — leave arrays unchanged
        }
    }

    // MARK: - HealthKit load

    func loadHealthKitData() async {
        await MainActor.run { isLoadingHealthData = true }
        let svc = HealthKitService.shared
        async let w = svc.fetchLatestWeight()
        async let s = svc.fetchLastNightSleep()
        async let c = svc.fetchTodayActiveCalories()
        let (weight, sleep, cal) = await (w, s, c)
        await MainActor.run {
            hkWeight          = weight
            hkSleep           = sleep
            hkCalories        = cal
            isLoadingHealthData = false
        }
    }

    // MARK: - Weight CRUD

    func addWeight(pounds: Double, note: String) {
        guard let ctx = modelContext else { return }
        let entry = WeightEntry(pounds: pounds, note: note)
        ctx.insert(entry)
        weightEntries.insert(entry, at: 0)
    }

    func deleteWeight(_ entry: WeightEntry) {
        guard let ctx = modelContext else { return }
        ctx.delete(entry)
        weightEntries.removeAll { $0 === entry }
    }

    // MARK: - Sleep CRUD

    func addSleep(hours: Double, quality: Int, note: String) {
        guard let ctx = modelContext else { return }
        let entry = SleepEntry(hours: hours, quality: quality, note: note)
        ctx.insert(entry)
        sleepEntries.insert(entry, at: 0)
    }

    func deleteSleep(_ entry: SleepEntry) {
        guard let ctx = modelContext else { return }
        ctx.delete(entry)
        sleepEntries.removeAll { $0 === entry }
    }

    // MARK: - Cardio CRUD

    func addCardio(type: String, duration: Int, distance: Double, calories: Int, note: String) {
        guard let ctx = modelContext else { return }
        let entry = CardioEntry(
            type: type, durationMinutes: duration,
            distanceMiles: distance, calories: calories, note: note
        )
        ctx.insert(entry)
        cardioEntries.insert(entry, at: 0)
    }

    func deleteCardio(_ entry: CardioEntry) {
        guard let ctx = modelContext else { return }
        ctx.delete(entry)
        cardioEntries.removeAll { $0 === entry }
    }
}
