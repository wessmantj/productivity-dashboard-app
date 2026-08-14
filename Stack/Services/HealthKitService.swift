import Foundation
import HealthKit

/// A single night of sleep pulled from HealthKit (e.g. synced from Fitbit
/// via Google Health Connect → Apple Health).
struct HKSleepNight: Identifiable {
    let id = UUID()
    let date: Date      // morning the sleep ended
    let hours: Double
}

final class HealthKitService {

    static let shared = HealthKitService()
    private init() {}

    private let store = HKHealthStore()
    private let authKey = "healthKitAuthorized"

    /// Everything Stack reads. Wearable data (Fitbit etc.) lands in these same
    /// types when synced into Apple Health.
    static var readTypes: Set<HKObjectType> {
        [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        ]
    }

    private func requestAuthorizationIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: authKey) else { return }
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: Self.readTypes)
            UserDefaults.standard.set(true, forKey: authKey)
        } catch {
            // Silently ignore — user may have declined
        }
    }

    // MARK: - Weight

    func fetchLatestWeight() async -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        await requestAuthorizationIfNeeded()
        let type = HKQuantityType(.bodyMass)
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: sort) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil); return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: .pound()))
            }
            store.execute(query)
        }
    }

    // MARK: - Sleep

    func fetchLastNightSleep() async -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        await requestAuthorizationIfNeeded()
        return await sleepHours(endingOnMorningOf: Date())
    }

    /// One entry per night for the last `nights` nights (most recent last).
    /// Nights with no data are skipped.
    func fetchSleepHistory(nights: Int) async -> [HKSleepNight] {
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        await requestAuthorizationIfNeeded()
        let cal = Calendar.current
        var result: [HKSleepNight] = []
        for offset in stride(from: nights - 1, through: 0, by: -1) {
            guard let morning = cal.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            if let hours = await sleepHours(endingOnMorningOf: morning), hours > 0 {
                result.append(HKSleepNight(date: cal.startOfDay(for: morning), hours: hours))
            }
        }
        return result
    }

    /// Total asleep time between 8 PM the prior evening and 10 AM of `morning`.
    private func sleepHours(endingOnMorningOf morning: Date) async -> Double? {
        let type = HKCategoryType(.sleepAnalysis)
        let cal = Calendar.current
        guard let evening = cal.date(byAdding: .day, value: -1, to: morning),
              let start = cal.date(bySettingHour: 20, minute: 0, second: 0, of: evening),
              let end   = cal.date(bySettingHour: 10, minute: 0, second: 0, of: morning)
        else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictEndDate)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type, predicate: predicate,
                limit: HKObjectQueryNoLimit, sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil); return
                }
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                ]
                let totalSeconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: totalSeconds > 0 ? totalSeconds / 3600 : nil)
            }
            store.execute(query)
        }
    }

    // MARK: - Activity

    func fetchTodayActiveCalories() async -> Int? {
        await todaySum(of: HKQuantityType(.activeEnergyBurned), unit: .kilocalorie()).map(Int.init)
    }

    func fetchTodaySteps() async -> Int? {
        await todaySum(of: HKQuantityType(.stepCount), unit: .count()).map(Int.init)
    }

    func fetchRestingHeartRate() async -> Int? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        await requestAuthorizationIfNeeded()
        let type = HKQuantityType(.restingHeartRate)
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: sort) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil); return
                }
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: Int(bpm))
            }
            store.execute(query)
        }
    }

    private func todaySum(of type: HKQuantityType, unit: HKUnit) async -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        await requestAuthorizationIfNeeded()
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }
}
