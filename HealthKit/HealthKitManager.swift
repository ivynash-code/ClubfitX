import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let store = HKHealthStore()

    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var todayActiveCalories: Double = 0
    @Published var currentHeartRate: Int = 0
    @Published var todayDistance: Double = 0   // km
    @Published var latestWeight: Double? = nil
    @Published var recentSleep: Double = 0     // hours last night
    @Published var recentWorkouts: [HKWorkout] = []

    // MARK: - Read types we want from HealthKit
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .stepCount, .activeEnergyBurned, .heartRate,
            .distanceWalkingRunning, .distanceCycling,
            .bodyMass, .height
        ]
        quantityTypes.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }
            .forEach { types.insert($0) }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        types.insert(HKObjectType.workoutType())
        return types
    }

    // MARK: - Request Authorization
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            await fetchAll()
            startObservers()
        } catch {
            print("HealthKit auth error: \(error)")
        }
    }

    // MARK: - Fetch All Today
    func fetchAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchTodaySteps() }
            group.addTask { await self.fetchTodayCalories() }
            group.addTask { await self.fetchTodayDistance() }
            group.addTask { await self.fetchLatestHeartRate() }
            group.addTask { await self.fetchLatestWeight() }
            group.addTask { await self.fetchLastNightSleep() }
            group.addTask { await self.fetchRecentWorkouts() }
        }
    }

    // MARK: - Steps
    func fetchTodaySteps() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let predicate = todayPredicate()
        let result = await fetchSum(type: type, unit: HKUnit.count(), predicate: predicate)
        todaySteps = Int(result)
    }

    // MARK: - Active Calories
    func fetchTodayCalories() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let result = await fetchSum(type: type, unit: .kilocalorie(), predicate: todayPredicate())
        todayActiveCalories = result
    }

    // MARK: - Distance
    func fetchTodayDistance() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let result = await fetchSum(type: type, unit: .meterUnit(with: .kilo), predicate: todayPredicate())
        todayDistance = result
    }

    // MARK: - Heart Rate
    func fetchLatestHeartRate() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                Task { @MainActor in self.currentHeartRate = Int(bpm) }
            }
        }
        store.execute(query)
    }

    // MARK: - Weight
    func fetchLatestWeight() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                Task { @MainActor in self.latestWeight = kg }
            }
        }
        store.execute(query)
    }

    // MARK: - Sleep
    func fetchLastNightSleep() async {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let start     = Calendar.current.startOfDay(for: yesterday)
        let end       = Calendar.current.startOfDay(for: Date()).addingTimeInterval(3600 * 12) // noon today
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, _ in
            var totalSecs = 0.0
            for sample in (samples ?? []) {
                if let cat = sample as? HKCategorySample,
                   cat.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                   cat.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                   cat.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                   cat.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                    totalSecs += cat.endDate.timeIntervalSince(cat.startDate)
                }
            }
            Task { @MainActor in self.recentSleep = totalSecs / 3600 }
        }
        store.execute(query)
    }

    // MARK: - Recent Workouts
    func fetchRecentWorkouts() async {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: nil, limit: 20, sortDescriptors: [sort]) { _, samples, _ in
            let workouts = (samples as? [HKWorkout]) ?? []
            Task { @MainActor in self.recentWorkouts = workouts }
        }
        store.execute(query)
    }

    // MARK: - Observers (live updates)
    private func startObservers() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, _ in
            Task { await self?.fetchTodaySteps() }
        }
        store.execute(query)
    }

    // MARK: - Helper: convert HKWorkout to WorkoutEntry data
    func workoutData(from hkWorkout: HKWorkout) -> WorkoutImport {
        let type  = mapWorkoutType(hkWorkout.workoutActivityType)
        let emoji = mapWorkoutEmoji(hkWorkout.workoutActivityType)
        let cal   = hkWorkout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
        let dist  = (hkWorkout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo))) ?? 0
        let dur   = Int(hkWorkout.duration / 60)
        return WorkoutImport(date: hkWorkout.endDate, type: type, emoji: emoji,
                              durationMinutes: dur, caloriesBurned: cal,
                              distanceKm: dist, source: "HealthKit",
                              healthKitID: hkWorkout.uuid.uuidString)
    }

    // MARK: - HealthKit workout type → app type
    func mapWorkoutType(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running:            return "Running"
        case .cycling:            return "Cycling"
        case .walking:            return "Walking"
        case .swimming:           return "Swimming"
        case .yoga:               return "Yoga"
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "Strength Training"
        case .highIntensityIntervalTraining: return "HIIT"
        case .dance:              return "Dance"
        case .soccer:             return "Football"
        case .cricket:            return "Cricket"
        case .badminton:          return "Badminton"
        case .rowing:             return "Rowing"
        case .elliptical:         return "Elliptical"
        case .stairClimbing:      return "Stair Climbing"
        case .jumpRope:           return "Jump Rope"
        default:                  return "Workout"
        }
    }

    func mapWorkoutEmoji(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running:            return "🏃"
        case .cycling:            return "🚴"
        case .walking:            return "🚶"
        case .swimming:           return "🏊"
        case .yoga:               return "🧘"
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "🏋️"
        case .highIntensityIntervalTraining: return "⚡"
        case .dance:              return "💃"
        case .soccer:             return "⚽"
        case .cricket:            return "🏏"
        case .badminton:          return "🏸"
        default:                  return "💪"
        }
    }

    // MARK: - Helpers
    private func todayPredicate() -> NSPredicate {
        let start = Calendar.current.startOfDay(for: Date())
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
    }

    private func fetchSum(type: HKQuantityType, unit: HKUnit, predicate: NSPredicate) async -> Double {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }
}

// MARK: - Import struct (plain, sendable)
struct WorkoutImport {
    let date: Date
    let type: String
    let emoji: String
    let durationMinutes: Int
    let caloriesBurned: Double
    let distanceKm: Double
    let source: String
    let healthKitID: String
}
