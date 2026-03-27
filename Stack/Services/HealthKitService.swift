import Foundation
#if os(iOS)
import HealthKit
#endif

final class HealthKitService {

    static let shared = HealthKitService()
    private init() {}

    // MARK: - iOS Implementation

#if os(iOS)
    private let store = HKHealthStore()
    private let authKey = "healthKitAuthorized"

    private var readTypes: Set<HKObjectType> {
        [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        ]
    }

    private func requestAuthorizationIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: authKey) else { return }
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            UserDefaults.standard.set(true, forKey: authKey)
        } catch {
            // Silently ignore — user may have declined
        }
    }

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

    func fetchLastNightSleep() async -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        await requestAuthorizationIfNeeded()
        let type = HKCategoryType(.sleepAnalysis)
        let cal = Calendar.current
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        let start = cal.date(bySettingHour: 20, minute: 0, second: 0, of: yesterday)!
        let end   = cal.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
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

    func fetchTodayActiveCalories() async -> Int? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        await requestAuthorizationIfNeeded()
        let type = HKQuantityType(.activeEnergyBurned)
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                if let sum = stats?.sumQuantity() {
                    continuation.resume(returning: Int(sum.doubleValue(for: .kilocalorie())))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }

// MARK: - macOS stubs
#else
    func fetchLatestWeight() async -> Double? { nil }
    func fetchLastNightSleep() async -> Double? { nil }
    func fetchTodayActiveCalories() async -> Int? { nil }
#endif
}
