import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var workoutReminder  = true
    @Published var waterReminder    = true
    @Published var sleepReminder    = true
    @Published var mealReminder     = true
    @Published var badgeNotification = true

    // User-configurable times
    @AppStorage("workoutReminderHour")  var workoutHour: Int  = 7
    @AppStorage("workoutReminderMin")   var workoutMin: Int   = 0
    @AppStorage("sleepReminderHour")    var sleepHour: Int    = 22
    @AppStorage("sleepReminderMin")     var sleepMin: Int     = 0
    @AppStorage("waterReminderEnabled") var waterEnabled: Bool = true

    private let center = UNUserNotificationCenter.current()

    // MARK: - Request Permission
    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge])
            isAuthorized = granted
            if granted { await scheduleAll() }
        } catch {
            print("Notification auth error: \(error)")
        }
    }

    func checkStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule All
    func scheduleAll() async {
        center.removeAllPendingNotificationRequests()
        if workoutReminder  { await scheduleWorkoutReminder() }
        if waterReminder    { await scheduleWaterReminders() }
        if sleepReminder    { await scheduleSleepReminder() }
        if mealReminder     { await scheduleMealReminders() }
    }

    // MARK: - Workout Reminder (daily)
    func scheduleWorkoutReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Time to Move! 💪"
        content.body  = "Your ClubFitX workout is waiting. The 99 Percent Club doesn't skip days!"
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"

        var comps = DateComponents()
        comps.hour = workoutHour; comps.minute = workoutMin
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "workout_daily", content: content, trigger: trigger)
        try? await center.add(req)
    }

    // MARK: - Water Reminders (every 2 hours 8am–8pm)
    func scheduleWaterReminders() async {
        let messages = [
            "💧 Time to hydrate! Drink a glass of water.",
            "💧 Stay hydrated! Your body is 60% water.",
            "💧 Water break! Log your intake in ClubFitX.",
            "💧 Drink up! Hydration = Performance.",
        ]
        for hour in stride(from: 8, through: 20, by: 2) {
            let content = UNMutableNotificationContent()
            content.title = "Hydration Reminder 💧"
            content.body  = messages[(hour - 8) / 2 % messages.count]
            content.sound = .default

            var comps = DateComponents()
            comps.hour = hour; comps.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let req = UNNotificationRequest(identifier: "water_\(hour)", content: content, trigger: trigger)
            try? await center.add(req)
        }
    }

    // MARK: - Sleep Reminder
    func scheduleSleepReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Bedtime Reminder 😴"
        content.body  = "Time to wind down! Good sleep = better workouts tomorrow."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = sleepHour; comps.minute = sleepMin
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "sleep_reminder", content: content, trigger: trigger)
        try? await center.add(req)
    }

    // MARK: - Meal Reminders
    func scheduleMealReminders() async {
        let meals: [(String, String, Int, Int)] = [
            ("Breakfast Time 🌅", "Don't skip breakfast! Log it in ClubFitX.", 8, 0),
            ("Lunch Time 🍱",     "Mid-day fuel! Log your lunch to stay on track.", 13, 0),
            ("Dinner Time 🌙",    "Dinner time! Make healthy choices tonight.", 19, 30),
        ]
        for (title, body, hour, min) in meals {
            let content = UNMutableNotificationContent()
            content.title = title; content.body = body; content.sound = .default
            var comps = DateComponents()
            comps.hour = hour; comps.minute = min
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let req = UNNotificationRequest(identifier: "meal_\(hour)", content: content, trigger: trigger)
            try? await center.add(req)
        }
    }

    // MARK: - Badge notification (triggered on badge earn)
    func sendBadgeEarned(badge: BadgeDefinition) {
        let content = UNMutableNotificationContent()
        content.title = "New Badge Earned! \(badge.emoji)"
        content.body  = "You earned '\(badge.name)': \(badge.description)"
        content.sound = .defaultRingtone
        let req = UNNotificationRequest(identifier: "badge_\(badge.id)_\(Date().timeIntervalSince1970)",
                                         content: content, trigger: nil)
        center.add(req)
    }

    // MARK: - Streak notification
    func sendStreakNotification(days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 \(days)-Day Streak!"
        content.body  = "You're on fire! \(days) days straight. Keep going, 99%er!"
        content.sound = .default
        let req = UNNotificationRequest(identifier: "streak_\(days)", content: content, trigger: nil)
        center.add(req)
    }
}
