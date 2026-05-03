import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var hk: HealthKitManager
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home",       systemImage: "house.fill") }.tag(0)
                WorkoutView()
                    .tabItem { Label("Workout",    systemImage: "figure.run") }.tag(1)
                NutritionView()
                    .tabItem { Label("Nutrition",  systemImage: "fork.knife") }.tag(2)
                TrackingView()
                    .tabItem { Label("Track",      systemImage: "chart.bar.fill") }.tag(3)
                GamificationView()
                    .tabItem { Label("Club",       systemImage: "trophy.fill") }.tag(4)
            }
            .accentColor(.accentPurple)

            // Badge toast overlay
            if vm.showBadgeToast, let badge = vm.newBadge {
                BadgeToastView(badge: badge)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4), value: vm.showBadgeToast)
                    .zIndex(100)
                    .padding(.top, 60)
            }
        }
    }
}

// MARK: - Badge Toast
struct BadgeToastView: View {
    let badge: BadgeDefinition
    var body: some View {
        HStack(spacing: 12) {
            Text(badge.emoji).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("Badge Earned!").font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textSecondary)
                Text(badge.name).font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentGreen).font(.title3)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.bgCard)
                .shadow(color: badge.color.opacity(0.4), radius: 12, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(badge.color.opacity(0.5), lineWidth: 1))
        .padding(.horizontal, 16)
    }
}
