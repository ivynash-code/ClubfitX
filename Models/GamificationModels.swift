import SwiftUI

// MARK: - Badge Definition
struct BadgeDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let color: Color
    let category: BadgeCategory

    enum BadgeCategory: String {
        case workout  = "Workout"
        case nutrition = "Nutrition"
        case weight   = "Weight"
        case sleep    = "Sleep"
        case water    = "Hydration"
        case streak   = "Streak"
        case special  = "Special"
    }
}

// MARK: - All Badges
struct BadgeCatalog {
    static let all: [BadgeDefinition] = [
        // Workout badges
        BadgeDefinition(id: "first_workout",   name: "First Step",      description: "Complete your first workout",       emoji: "👟", color: .accentGreen,  category: .workout),
        BadgeDefinition(id: "workout_7",       name: "Week Warrior",    description: "Complete 7 workouts",               emoji: "💪", color: .accentPurple, category: .workout),
        BadgeDefinition(id: "workout_30",      name: "Monthly Mover",   description: "Complete 30 workouts",              emoji: "🏆", color: .accentOrange, category: .workout),
        BadgeDefinition(id: "workout_100",     name: "Centurion",       description: "Complete 100 workouts",             emoji: "🌟", color: .yellow,       category: .workout),
        BadgeDefinition(id: "calorie_burn_500",name: "Inferno",         description: "Burn 500 kcal in one workout",      emoji: "🔥", color: .accentRed,    category: .workout),
        BadgeDefinition(id: "distance_5k",     name: "5K Runner",       description: "Run 5 km in one session",           emoji: "🏃", color: .accentGreen,  category: .workout),
        BadgeDefinition(id: "distance_10k",    name: "10K Champion",    description: "Run 10 km in one session",          emoji: "🏅", color: .accentOrange, category: .workout),
        BadgeDefinition(id: "steps_10k",       name: "Step Master",     description: "Hit 10,000 steps in a day",         emoji: "👣", color: .accentTeal,   category: .workout),
        // Streak badges
        BadgeDefinition(id: "streak_3",        name: "Hat Trick",       description: "3-day workout streak",              emoji: "🎯", color: .accentOrange, category: .streak),
        BadgeDefinition(id: "streak_7",        name: "On Fire",         description: "7-day workout streak",              emoji: "🔥", color: .accentRed,    category: .streak),
        BadgeDefinition(id: "streak_30",       name: "Unstoppable",     description: "30-day workout streak",             emoji: "⚡", color: .accentPurple, category: .streak),
        BadgeDefinition(id: "streak_100",      name: "Legend",          description: "100-day workout streak",            emoji: "👑", color: .yellow,       category: .streak),
        // Weight badges
        BadgeDefinition(id: "weight_log_7",    name: "Scale Tracker",   description: "Log weight 7 days in a row",        emoji: "⚖️", color: .accentTeal,  category: .weight),
        BadgeDefinition(id: "weight_1kg",      name: "First Kilo",      description: "Lost first 1 kg",                   emoji: "📉", color: .accentGreen,  category: .weight),
        BadgeDefinition(id: "weight_5kg",      name: "5 Kg Down",       description: "Lost 5 kg from start",              emoji: "🎉", color: .accentPurple, category: .weight),
        BadgeDefinition(id: "goal_reached",    name: "Goal Getter",     description: "Reached your goal weight!",         emoji: "🏆", color: .yellow,       category: .weight),
        // Nutrition badges
        BadgeDefinition(id: "log_meals_7",     name: "Food Journalist", description: "Log meals for 7 consecutive days",  emoji: "📝", color: .accentOrange, category: .nutrition),
        BadgeDefinition(id: "protein_goal_7",  name: "Protein Pro",     description: "Hit protein goal 7 days in a row",  emoji: "🥩", color: .accentRed,    category: .nutrition),
        // Sleep badges
        BadgeDefinition(id: "sleep_goal_7",    name: "Sleep Champion",  description: "Hit sleep goal 7 days in a row",    emoji: "😴", color: .accentPurple, category: .sleep),
        BadgeDefinition(id: "early_bird",      name: "Early Bird",      description: "Wake before 6 AM for 5 days",       emoji: "🌅", color: .accentOrange, category: .sleep),
        // Water badges
        BadgeDefinition(id: "water_goal_7",    name: "Hydration Hero",  description: "Hit water goal 7 days in a row",    emoji: "💧", color: .accentTeal,   category: .water),
        // Special
        BadgeDefinition(id: "club_member",     name: "Club Member",     description: "Welcome to The 99 Percent Club!",   emoji: "💜", color: .accentPurple, category: .special),
        BadgeDefinition(id: "bmi_normal",      name: "Healthy Range",   description: "BMI reached the healthy range",     emoji: "✅", color: .accentGreen,  category: .special),
    ]

    static func badge(for id: String) -> BadgeDefinition? {
        all.first { $0.id == id }
    }
}

// MARK: - Level System
struct LevelSystem {
    struct Level {
        let number: Int
        let name: String
        let emoji: String
        let minXP: Int
        let color: Color
    }

    static let levels: [Level] = [
        Level(number: 1,  name: "Rookie",        emoji: "🌱", minXP: 0,    color: .accentGreen),
        Level(number: 2,  name: "Beginner",      emoji: "💪", minXP: 100,  color: .accentGreen),
        Level(number: 3,  name: "Active",        emoji: "🏃", minXP: 300,  color: .accentTeal),
        Level(number: 4,  name: "Dedicated",     emoji: "🎯", minXP: 600,  color: .accentTeal),
        Level(number: 5,  name: "Athlete",       emoji: "⚡", minXP: 1000, color: .accentPurple),
        Level(number: 6,  name: "Champion",      emoji: "🏆", minXP: 1500, color: .accentPurple),
        Level(number: 7,  name: "Elite",         emoji: "🌟", minXP: 2200, color: .accentOrange),
        Level(number: 8,  name: "Legend",        emoji: "👑", minXP: 3000, color: .accentOrange),
        Level(number: 9,  name: "Icon",          emoji: "🔥", minXP: 4000, color: .accentRed),
        Level(number: 10, name: "99%er",         emoji: "💜", minXP: 5000, color: Color(red:0.4,green:0.2,blue:0.8)),
    ]

    static func level(for xp: Int) -> Level {
        levels.last(where: { $0.minXP <= xp }) ?? levels[0]
    }

    static func nextLevel(for xp: Int) -> Level? {
        guard let current = levels.last(where: { $0.minXP <= xp }),
              let idx = levels.firstIndex(where: { $0.number == current.number }),
              idx + 1 < levels.count else { return nil }
        return levels[idx + 1]
    }

    static func progress(for xp: Int) -> Double {
        guard let current = levels.last(where: { $0.minXP <= xp }),
              let next = nextLevel(for: xp) else { return 1.0 }
        let range = Double(next.minXP - current.minXP)
        let done  = Double(xp - current.minXP)
        return range > 0 ? min(done / range, 1.0) : 1.0
    }

    // XP rewards
    static func xp(for action: XPAction) -> Int { action.points }

    enum XPAction {
        case workoutCompleted, workoutOver30min, workoutOver60min
        case mealLogged, proteinGoalHit
        case weightLogged, waterGoalHit
        case sleepGoalHit, badgeEarned, challengeCompleted
        case streakDay

        var points: Int {
            switch self {
            case .workoutCompleted:   return 20
            case .workoutOver30min:   return 10
            case .workoutOver60min:   return 20
            case .mealLogged:         return 5
            case .proteinGoalHit:     return 15
            case .weightLogged:       return 10
            case .waterGoalHit:       return 10
            case .sleepGoalHit:       return 10
            case .badgeEarned:        return 50
            case .challengeCompleted: return 100
            case .streakDay:          return 5
            }
        }
    }
}

// MARK: - Challenge Definitions
struct ChallengeDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let durationDays: Int
    let targetValue: Double
    let unit: String
    let type: ChallengeType
    let difficulty: String   // Easy / Medium / Hard
    let xpReward: Int

    enum ChallengeType {
        case workoutCount, totalDistance, totalCaloriesBurned
        case waterStreak, sleepStreak, mealLogging, weightLoss
    }
}

struct ChallengeCatalog {
    static let all: [ChallengeDefinition] = [
        ChallengeDefinition(id: "week_warrior",    name: "Week Warrior",      description: "Complete 5 workouts this week",     emoji: "💪", durationDays: 7,  targetValue: 5,   unit: "workouts",  type: .workoutCount,         difficulty: "Easy",   xpReward: 100),
        ChallengeDefinition(id: "hydration_week",  name: "Hydration Week",    description: "Drink 2.5L water every day for 7 days", emoji: "💧", durationDays: 7,  targetValue: 7,   unit: "days",     type: .waterStreak,          difficulty: "Easy",   xpReward: 75),
        ChallengeDefinition(id: "run_50k",         name: "50K Run Club",      description: "Run a total of 50 km this month",   emoji: "🏃", durationDays: 30, targetValue: 50,  unit: "km",        type: .totalDistance,        difficulty: "Medium", xpReward: 200),
        ChallengeDefinition(id: "burn_5000",       name: "Burn 5000",         description: "Burn 5,000 calories in 2 weeks",    emoji: "🔥", durationDays: 14, targetValue: 5000,unit: "kcal",      type: .totalCaloriesBurned,  difficulty: "Medium", xpReward: 150),
        ChallengeDefinition(id: "sleep_champion",  name: "Sleep Champion",    description: "Get 8h sleep for 7 days straight",  emoji: "😴", durationDays: 7,  targetValue: 7,   unit: "days",      type: .sleepStreak,          difficulty: "Medium", xpReward: 100),
        ChallengeDefinition(id: "meal_master",     name: "Meal Tracker",      description: "Log all meals for 14 days",         emoji: "🥗", durationDays: 14, targetValue: 14,  unit: "days",      type: .mealLogging,          difficulty: "Easy",   xpReward: 100),
        ChallengeDefinition(id: "drop_2kg",        name: "Drop 2 Kg",         description: "Lose 2 kg in 30 days",              emoji: "📉", durationDays: 30, targetValue: 2,   unit: "kg",        type: .weightLoss,           difficulty: "Hard",   xpReward: 250),
        ChallengeDefinition(id: "workout_30days",  name: "30-Day Grind",      description: "Complete 20 workouts in 30 days",   emoji: "⚡", durationDays: 30, targetValue: 20,  unit: "workouts",  type: .workoutCount,         difficulty: "Hard",   xpReward: 300),
    ]

    static func challenge(for id: String) -> ChallengeDefinition? {
        all.first { $0.id == id }
    }
}
