import SwiftUI
import UserNotifications

@main
struct ClubFitXApp: App {
    let persistence = PersistenceController.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var healthKitManager   = HealthKitManager.shared

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(notificationManager)
                .environmentObject(healthKitManager)
        }
    }

    private func configureAppearance() {
        // Tab bar appearance
        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1)
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar

        // Navigation bar appearance
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1)
        nav.titleTextAttributes    = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance   = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
    }
}

// MARK: - Root View (handles onboarding)
struct RootView: View {
    @Environment(\.managedObjectContext) private var ctx
    @AppStorage("hasCompletedOnboarding") private var hasOnboarded = false
    @StateObject private var vm: AppViewModel

    init() {
        _vm = StateObject(wrappedValue: AppViewModel(
            context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        Group {
            if hasOnboarded {
                MainTabView()
                    .environmentObject(vm)
            } else {
                OnboardingView(hasOnboarded: $hasOnboarded)
                    .environmentObject(vm)
            }
        }
        .preferredColorScheme(.dark)
    }
}
