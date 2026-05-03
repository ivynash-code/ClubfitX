import Foundation
import CoreData
import Combine

@MainActor
class AppViewModel: ObservableObject {

    // MARK: - Published
    @Published var workouts:       [WorkoutEntry]   = []
    @Published var todayNutrition: [NutritionEntry] = []
    @Published var weightHistory:  [WeightEntry]    = []
    @Published var sleepHistory:   [SleepEntry]     = []
    @Published var todayWater:     [WaterEntry]     = []
    @Published var earnedBadges:   [Badge]          = []
    @Published var challenges:     [Challenge]      = []
    @Published var userProfile:    UserProfile?
    @Published var totalXP:        Int              = 0
    @Published var newBadge:       BadgeDefinition? = nil
    @Published var showBadgeToast: Bool             = false

    // MARK: - Derived Nutrition
    var todayCaloriesConsumed: Double { todayNutrition.reduce(0) { $0 + $1.calories } }
    var todayProtein: Double          { todayNutrition.reduce(0) { $0 + $1.protein } }
    var todayCarbs:   Double          { todayNutrition.reduce(0) { $0 + $1.carbs } }
    var todayFat:     Double          { todayNutrition.reduce(0) { $0 + $1.fat } }
    var todayFiber:   Double          { todayNutrition.reduce(0) { $0 + $1.fiber } }

    // MARK: - Goals
    var calGoal:     Double { Double(userProfile?.dailyCalorieGoal ?? 2000) }
    var proteinGoal: Double { Double(userProfile?.dailyProteinGoal ?? 150) }
    var carbsGoal:   Double { Double(userProfile?.dailyCarbsGoal ?? 250) }
    var fatGoal:     Double { Double(userProfile?.dailyFatGoal ?? 65) }
    var waterGoalML: Int    { Int((userProfile?.dailyWaterGoalL ?? 2.5) * 1000) }
    var sleepGoalHrs: Double { userProfile?.dailySleepGoalHrs ?? 8 }

    // MARK: - Workout helpers
    var todayWorkouts: [WorkoutEntry] {
        workouts.filter { Calendar.current.isDateInToday($0.date) }
    }
    var todayCaloriesBurned: Double {
        todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }

    // MARK: - Water
    var todayWaterML: Int { todayWater.reduce(0) { $0 + Int($1.amountML) } }
    var waterProgress: Double {
        waterGoalML > 0 ? min(Double(todayWaterML) / Double(waterGoalML), 1.0) : 0
    }

    // MARK: - Sleep
    var lastNightSleep: SleepEntry? { sleepHistory.first }
    var sleepProgress: Double {
        guard let s = lastNightSleep else { return 0 }
        return min(s.durationHrs / sleepGoalHrs, 1.0)
    }

    // MARK: - Weight / BMI
    var latestWeight: Double?     { weightHistory.first?.weightKg }
    var currentBMI: Double? {
        guard let w = latestWeight, let p = userProfile else { return nil }
        return p.bmi(weightKg: w)
    }
    var currentBMICategory: BMICategory {
        guard let w = latestWeight, let p = userProfile else { return .unknown }
        return p.bmiCategory(weightKg: w)
    }
    var weeklyWeightData: [(date: Date, weight: Double)] {
        let last7 = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return weightHistory.filter { $0.date >= last7 }
            .sorted { $0.date < $1.date }
            .map { ($0.date, $0.weightKg) }
    }

    // MARK: - Streak
    var streak: Int {
        var count = 0; var current = Date(); let cal = Calendar.current
        for _ in 0..<365 {
            let has = workouts.contains { cal.isDate($0.date, inSameDayAs: current) }
            if !has { break }
            count += 1
            current = cal.date(byAdding: .day, value: -1, to: current) ?? current
        }
        return count
    }

    // MARK: - Level
    var currentLevel: LevelSystem.Level { LevelSystem.level(for: totalXP) }
    var levelProgress: Double           { LevelSystem.progress(for: totalXP) }
    var nextLevel: LevelSystem.Level?   { LevelSystem.nextLevel(for: totalXP) }

    // MARK: - Core Data
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAll()
        ensureProfile()
        recalcXP()
    }

    // MARK: - Fetch
    func fetchAll() {
        fetchWorkouts(); fetchTodayNutrition()
        fetchWeightHistory(); fetchSleepHistory()
        fetchTodayWater(); fetchBadges(); fetchChallenges()
        fetchProfile()
    }

    private func fetchWorkouts() {
        let r = NSFetchRequest<WorkoutEntry>(entityName: "WorkoutEntry")
        r.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        workouts = (try? context.fetch(r)) ?? []
    }

    func fetchTodayNutrition(for date: Date = Date()) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        let r = NSFetchRequest<NutritionEntry>(entityName: "NutritionEntry")
        r.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        r.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        todayNutrition = (try? context.fetch(r)) ?? []
    }

    func fetchWeightHistory() {
        let r = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
        r.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        weightHistory = (try? context.fetch(r)) ?? []
    }

    func fetchSleepHistory() {
        let r = NSFetchRequest<SleepEntry>(entityName: "SleepEntry")
        r.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        r.fetchLimit = 30
        sleepHistory = (try? context.fetch(r)) ?? []
    }

    func fetchTodayWater() {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        let r = NSFetchRequest<WaterEntry>(entityName: "WaterEntry")
        r.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        todayWater = (try? context.fetch(r)) ?? []
    }

    func fetchBadges() {
        let r = NSFetchRequest<Badge>(entityName: "Badge")
        r.sortDescriptors = [NSSortDescriptor(key: "earnedAt", ascending: false)]
        earnedBadges = (try? context.fetch(r)) ?? []
    }

    func fetchChallenges() {
        let r = NSFetchRequest<Challenge>(entityName: "Challenge")
        challenges = (try? context.fetch(r)) ?? []
    }

    func fetchProfile() {
        let r = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        userProfile = (try? context.fetch(r))?.first
    }

    // MARK: - Range queries (for reports)
    func nutritionEntries(from start: Date, to end: Date) -> [NutritionEntry] {
        let r = NSFetchRequest<NutritionEntry>(entityName: "NutritionEntry")
        r.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        r.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(r)) ?? []
    }

    func workouts(from start: Date, to end: Date) -> [WorkoutEntry] {
        let r = NSFetchRequest<WorkoutEntry>(entityName: "WorkoutEntry")
        r.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        r.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(r)) ?? []
    }

    // MARK: - Add Workout
    func addWorkout(type: String, emoji: String, durationMinutes: Int,
                     caloriesBurned: Double, distanceKm: Double = 0,
                     avgHR: Int = 0, steps: Int = 0,
                     source: String = "Manual", notes: String? = nil,
                     healthKitID: String? = nil) {
        // De-duplicate HealthKit imports
        if let hkID = healthKitID {
            let existing = workouts.first { $0.healthKitID == hkID }
            if existing != nil { return }
        }
        let e = WorkoutEntry(context: context)
        e.id = UUID(); e.date = Date(); e.type = type; e.emoji = emoji
        e.source = source; e.durationMinutes = Int32(durationMinutes)
        e.caloriesBurned = caloriesBurned; e.distanceKm = distanceKm
        e.avgHeartRate = Int32(avgHR); e.steps = Int32(steps)
        e.notes = notes; e.healthKitID = healthKitID
        save(); fetchWorkouts()
        addXP(.workoutCompleted)
        if durationMinutes >= 30 { addXP(.workoutOver30min) }
        if durationMinutes >= 60 { addXP(.workoutOver60min) }
        checkBadges()
    }

    func importFromHealthKit(_ imp: WorkoutImport) {
        addWorkout(type: imp.type, emoji: imp.emoji,
                   durationMinutes: imp.durationMinutes,
                   caloriesBurned: imp.caloriesBurned,
                   distanceKm: imp.distanceKm, source: imp.source,
                   healthKitID: imp.healthKitID)
    }

    func deleteWorkout(_ w: WorkoutEntry) { context.delete(w); save(); fetchWorkouts() }

    // MARK: - Nutrition
    func addNutritionEntry(food: IndianFoodItem, mealType: String, quantity: Double) {
        let e = NutritionEntry(context: context)
        e.id = UUID(); e.date = Date(); e.foodName = food.name
        e.mealType = mealType; e.servingSize = food.servingSize; e.quantity = quantity
        e.calories = food.caloriesPerServing * quantity
        e.protein  = food.proteinPerServing  * quantity
        e.carbs    = food.carbsPerServing    * quantity
        e.fat      = food.fatPerServing      * quantity
        e.fiber    = food.fiberPerServing    * quantity
        save(); fetchTodayNutrition()
        addXP(.mealLogged)
        checkBadges()
    }

    func addCustomNutrition(name: String, mealType: String, calories: Double,
                             protein: Double, carbs: Double, fat: Double) {
        let e = NutritionEntry(context: context)
        e.id = UUID(); e.date = Date(); e.foodName = name
        e.mealType = mealType; e.servingSize = "1 serving"; e.quantity = 1
        e.calories = calories; e.protein = protein; e.carbs = carbs; e.fat = fat; e.fiber = 0
        save(); fetchTodayNutrition()
        addXP(.mealLogged)
    }

    func deleteNutritionEntry(_ e: NutritionEntry) { context.delete(e); save(); fetchTodayNutrition() }

    // MARK: - Weight
    func addWeight(kg: Double, notes: String? = nil, source: String = "Manual") {
        let e = WeightEntry(context: context)
        e.id = UUID(); e.date = Date(); e.weightKg = kg; e.notes = notes; e.source = source
        save(); fetchWeightHistory()
        addXP(.weightLogged)
        checkBadges()
    }

    func deleteWeight(_ e: WeightEntry) { context.delete(e); save(); fetchWeightHistory() }

    // MARK: - Sleep
    func addSleep(bedtime: Date, wakeTime: Date, quality: String, notes: String? = nil) {
        let dur = wakeTime.timeIntervalSince(bedtime) / 3600
        let e = SleepEntry(context: context)
        e.id = UUID(); e.date = wakeTime; e.bedtime = bedtime; e.wakeTime = wakeTime
        e.durationHrs = max(dur, 0); e.quality = quality; e.source = "Manual"; e.notes = notes
        save(); fetchSleepHistory()
        if dur >= sleepGoalHrs { addXP(.sleepGoalHit) }
        checkBadges()
    }

    func deleteSleep(_ e: SleepEntry) { context.delete(e); save(); fetchSleepHistory() }

    // MARK: - Water
    func addWater(ml: Int) {
        let e = WaterEntry(context: context)
        e.id = UUID(); e.date = Date(); e.amountML = Int32(ml)
        save(); fetchTodayWater()
        if todayWaterML >= waterGoalML { addXP(.waterGoalHit) }
        checkBadges()
    }

    func deleteWater(_ e: WaterEntry) { context.delete(e); save(); fetchTodayWater() }

    // MARK: - Profile
    func ensureProfile() {
        fetchProfile()
        guard userProfile == nil else { return }
        let p = UserProfile(context: context)
        p.id = UUID(); p.name = "User"; p.gender = "Male"
        p.heightCm = 170; p.goalWeightKg = 70; p.startWeightKg = 80
        p.dailyCalorieGoal = 2000; p.dailyProteinGoal = 150
        p.dailyCarbsGoal = 250; p.dailyFatGoal = 65
        p.weeklyWorkoutGoal = 5; p.dailyStepGoal = 10000
        p.dailyWaterGoalL = 2.5; p.dailySleepGoalHrs = 8
        p.fitnessLevel = "Beginner"; p.primaryGoal = "Lose Weight"
        p.createdAt = Date()
        save(); fetchProfile()
        earnBadge(id: "club_member")
    }

    func updateProfile(name: String, gender: String, heightCm: Double,
                        dateOfBirth: Date?, calGoal: Int, proteinGoal: Int,
                        carbsGoal: Int, fatGoal: Int, goalWeight: Double,
                        startWeight: Double, weeklyWorkoutGoal: Int,
                        fitnessLevel: String, primaryGoal: String,
                        waterGoalL: Double, sleepGoalHrs: Double) {
        guard let p = userProfile else { return }
        p.name = name; p.gender = gender; p.heightCm = heightCm
        p.dateOfBirth = dateOfBirth
        p.dailyCalorieGoal  = Int32(calGoal)
        p.dailyProteinGoal  = Int32(proteinGoal)
        p.dailyCarbsGoal    = Int32(carbsGoal)
        p.dailyFatGoal      = Int32(fatGoal)
        p.goalWeightKg      = goalWeight
        p.startWeightKg     = startWeight
        p.weeklyWorkoutGoal = Int32(weeklyWorkoutGoal)
        p.fitnessLevel      = fitnessLevel
        p.primaryGoal       = primaryGoal
        p.dailyWaterGoalL   = waterGoalL
        p.dailySleepGoalHrs = sleepGoalHrs
        save(); fetchProfile()
    }

    // MARK: - XP & Gamification
    func addXP(_ action: LevelSystem.XPAction) {
        let pts = LevelSystem.xp(for: action)
        let oldLevel = currentLevel.number
        totalXP += pts
        UserDefaults.standard.set(totalXP, forKey: "totalXP")
        if currentLevel.number > oldLevel {
            // Level up — could trigger notification here
        }
    }

    func recalcXP() {
        totalXP = UserDefaults.standard.integer(forKey: "totalXP")
    }

    // MARK: - Badges
    func earnBadge(id: String) {
        guard !earnedBadges.contains(where: { $0.badgeID == id }) else { return }
        let b = Badge(context: context)
        b.id = UUID(); b.badgeID = id; b.earnedAt = Date(); b.isNew = true
        save(); fetchBadges()
        addXP(.badgeEarned)
        if let def = BadgeCatalog.badge(for: id) {
            newBadge = def
            showBadgeToast = true
            NotificationManager.shared.sendBadgeEarned(badge: def)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showBadgeToast = false
            }
        }
    }

    func checkBadges() {
        // Workout count
        if workouts.count >= 1   { earnBadge(id: "first_workout") }
        if workouts.count >= 7   { earnBadge(id: "workout_7") }
        if workouts.count >= 30  { earnBadge(id: "workout_30") }
        if workouts.count >= 100 { earnBadge(id: "workout_100") }

        // Streak
        if streak >= 3   { earnBadge(id: "streak_3") }
        if streak >= 7   { earnBadge(id: "streak_7") }
        if streak >= 30  { earnBadge(id: "streak_30") }
        if streak >= 100 { earnBadge(id: "streak_100") }

        // Weight loss
        if let current = latestWeight, let p = userProfile {
            let lost = p.startWeightKg - current
            if lost >= 1 { earnBadge(id: "weight_1kg") }
            if lost >= 5 { earnBadge(id: "weight_5kg") }
            if current <= p.goalWeightKg { earnBadge(id: "goal_reached") }
        }

        // BMI
        if currentBMICategory == .normal { earnBadge(id: "bmi_normal") }

        // Calorie burn
        if todayCaloriesBurned >= 500 { earnBadge(id: "calorie_burn_500") }

        // Steps
        if let hk = HealthKitManager.shared as? HealthKitManager, hk.todaySteps >= 10000 {
            earnBadge(id: "steps_10k")
        }
    }

    // MARK: - Challenges
    func joinChallenge(id: String) {
        guard !challenges.contains(where: { $0.challengeID == id }) else { return }
        guard let def = ChallengeCatalog.challenge(for: id) else { return }
        let c = Challenge(context: context)
        c.id = UUID(); c.challengeID = id; c.startDate = Date()
        c.endDate = Calendar.current.date(byAdding: .day, value: def.durationDays, to: Date()) ?? Date()
        c.progress = 0; c.isCompleted = false
        save(); fetchChallenges()
    }

    // MARK: - Helpers
    private func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }

    func nutritionEntries(for mealType: String) -> [NutritionEntry] {
        todayNutrition.filter { $0.mealType == mealType }
    }

    func weekWorkouts() -> [WorkoutEntry] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return workouts.filter { $0.date >= weekAgo }
    }

    func weeklyCaloriesBurned() -> Double {
        weekWorkouts().reduce(0) { $0 + $1.caloriesBurned }
    }
}
