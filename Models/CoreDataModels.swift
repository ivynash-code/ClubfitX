import CoreData
import SwiftUI

// MARK: - UserProfile
@objc(UserProfile) public class UserProfile: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var gender: String
    @NSManaged public var heightCm: Double
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var goalWeightKg: Double
    @NSManaged public var startWeightKg: Double
    @NSManaged public var dailyCalorieGoal: Int32
    @NSManaged public var dailyProteinGoal: Int32
    @NSManaged public var dailyCarbsGoal: Int32
    @NSManaged public var dailyFatGoal: Int32
    @NSManaged public var weeklyWorkoutGoal: Int32
    @NSManaged public var dailyStepGoal: Int32
    @NSManaged public var dailyWaterGoalL: Double
    @NSManaged public var dailySleepGoalHrs: Double
    @NSManaged public var fitnessLevel: String   // Beginner / Intermediate / Advanced
    @NSManaged public var primaryGoal: String    // Lose Weight / Build Muscle / Stay Fit
    @NSManaged public var createdAt: Date

    var heightM: Double { heightCm / 100.0 }
    func bmi(weightKg: Double) -> Double? {
        guard heightCm > 0 else { return nil }
        return weightKg / (heightM * heightM)
    }
    func bmiCategory(weightKg: Double) -> BMICategory {
        guard let b = bmi(weightKg: weightKg) else { return .unknown }
        return BMICategory.from(bmi: b)
    }
    var age: Int? {
        guard let dob = dateOfBirth else { return nil }
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year
    }
}
extension UserProfile: Identifiable {}

// MARK: - WorkoutEntry
@objc(WorkoutEntry) public class WorkoutEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var type: String
    @NSManaged public var emoji: String
    @NSManaged public var source: String        // Manual / HealthKit / AppleWatch
    @NSManaged public var durationMinutes: Int32
    @NSManaged public var caloriesBurned: Double
    @NSManaged public var distanceKm: Double
    @NSManaged public var avgHeartRate: Int32
    @NSManaged public var maxHeartRate: Int32
    @NSManaged public var steps: Int32
    @NSManaged public var notes: String?
    @NSManaged public var healthKitID: String?
}
extension WorkoutEntry: Identifiable {}

// MARK: - NutritionEntry
@objc(NutritionEntry) public class NutritionEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var foodName: String
    @NSManaged public var mealType: String
    @NSManaged public var calories: Double
    @NSManaged public var protein: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var fiber: Double
    @NSManaged public var servingSize: String
    @NSManaged public var quantity: Double
}
extension NutritionEntry: Identifiable {}

// MARK: - WeightEntry
@objc(WeightEntry) public class WeightEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var weightKg: Double
    @NSManaged public var notes: String?
    @NSManaged public var source: String
}
extension WeightEntry: Identifiable {}

// MARK: - SleepEntry
@objc(SleepEntry) public class SleepEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var bedtime: Date
    @NSManaged public var wakeTime: Date
    @NSManaged public var durationHrs: Double
    @NSManaged public var quality: String   // Poor / Fair / Good / Excellent
    @NSManaged public var source: String
    @NSManaged public var notes: String?
}
extension SleepEntry: Identifiable {}

// MARK: - WaterEntry
@objc(WaterEntry) public class WaterEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amountML: Int32
}
extension WaterEntry: Identifiable {}

// MARK: - Badge
@objc(Badge) public class Badge: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var badgeID: String
    @NSManaged public var earnedAt: Date
    @NSManaged public var isNew: Bool
}
extension Badge: Identifiable {}

// MARK: - Challenge
@objc(Challenge) public class Challenge: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var challengeID: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var progress: Double
    @NSManaged public var isCompleted: Bool
}
extension Challenge: Identifiable {}

// MARK: - BMI Category
enum BMICategory: String {
    case underweight = "Underweight"
    case normal      = "Normal"
    case overweight  = "Overweight"
    case obese       = "Obese"
    case unknown     = "--"

    static func from(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5:   return .underweight
        case 18.5..<25: return .normal
        case 25..<30:   return .overweight
        default:        return .obese
        }
    }
    var colorName: String {
        switch self {
        case .underweight: return "AccentTeal"
        case .normal:      return "AccentGreen"
        case .overweight:  return "AccentOrange"
        case .obese:       return "AccentRed"
        case .unknown:     return "AccentPurple"
        }
    }
    var emoji: String {
        switch self {
        case .underweight: return "📉"
        case .normal:      return "✅"
        case .overweight:  return "⚠️"
        case .obese:       return "🔴"
        case .unknown:     return "❓"
        }
    }
    var advice: String {
        switch self {
        case .underweight: return "Increase caloric intake and build muscle."
        case .normal:      return "You're in the healthy range. Keep it up!"
        case .overweight:  return "A calorie deficit and cardio will help."
        case .obese:       return "Consistent workouts + diet changes matter."
        case .unknown:     return "Add height to calculate BMI."
        }
    }
}
