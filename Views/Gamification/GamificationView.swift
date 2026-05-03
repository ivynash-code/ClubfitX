import SwiftUI

struct GamificationView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTab = 0
    let tabs = ["🏆 Badges", "⚡ Challenges", "📊 Progress"]

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Level hero
                    levelHero.padding(.horizontal, 16).padding(.top, 8)

                    Picker("", selection: $selectedTab) {
                        ForEach(tabs.indices, id: \.self) { Text(tabs[$0]).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16).padding(.vertical, 10)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            switch selectedTab {
                            case 0: BadgesSection()
                            case 1: ChallengesSection()
                            default: ProgressSection()
                            }
                            Spacer(minLength: 100)
                        }.padding(.horizontal, 16).padding(.top, 4)
                    }
                }
            }
            .navigationTitle("The Club")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    var levelHero: some View {
        CardView {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [vm.currentLevel.color.opacity(0.3), vm.currentLevel.color.opacity(0.1)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 70, height: 70)
                    VStack(spacing: 2) {
                        Text(vm.currentLevel.emoji).font(.system(size: 30))
                        Text("Lv.\(vm.currentLevel.number)")
                            .font(.system(size: 10, weight: .heavy)).foregroundColor(vm.currentLevel.color)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(vm.currentLevel.name).font(.system(size: 20, weight: .heavy)).foregroundColor(.white)
                    Text("\(vm.totalXP) XP").font(.system(size: 13, weight: .bold)).foregroundColor(vm.currentLevel.color)
                    if let next = vm.nextLevel {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                                Capsule().fill(vm.currentLevel.color)
                                    .frame(width: geo.size.width * vm.levelProgress, height: 6)
                            }
                        }.frame(height: 6)
                        Text("\(next.minXP - vm.totalXP) XP to \(next.name) \(next.emoji)")
                            .font(.system(size: 10)).foregroundColor(.textTertiary)
                    }
                }
                Spacer()
            }.padding(14)
        }
    }
}

// MARK: - Badges
private struct BadgesSection: View {
    @EnvironmentObject var vm: AppViewModel

    var earnedIDs: Set<String> { Set(vm.earnedBadges.map { $0.badgeID }) }

    var body: some View {
        VStack(spacing: 14) {
            // Streak banner
            if vm.streak > 0 {
                CardView {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.accentOrange.opacity(0.2)).frame(width: 54, height: 54)
                            Text("🔥").font(.system(size: 28))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(vm.streak)-Day Streak!").font(.system(size: 18, weight: .heavy)).foregroundColor(.white)
                            Text(streakMessage).font(.system(size: 12)).foregroundColor(.textSecondary)
                        }
                        Spacer()
                    }.padding(14)
                }
            }

            SectionHeader(title: "Earned (\(vm.earnedBadges.count))")
            if vm.earnedBadges.isEmpty {
                EmptyStateView(icon: "trophy", message: "No badges yet.\nComplete workouts to earn your first!")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(BadgeCatalog.all.filter { earnedIDs.contains($0.id) }) { def in
                        earnedBadgeCell(def)
                    }
                }
            }

            SectionHeader(title: "Locked (\(BadgeCatalog.all.count - vm.earnedBadges.count))")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(BadgeCatalog.all.filter { !earnedIDs.contains($0.id) }) { def in
                    lockedBadgeCell(def)
                }
            }
        }
    }

    func earnedBadgeCell(_ def: BadgeDefinition) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [def.color.opacity(0.3), def.color.opacity(0.1)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                Text(def.emoji).font(.system(size: 30))
            }
            Text(def.name).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .padding(10)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(def.color.opacity(0.4), lineWidth: 1))
    }

    func lockedBadgeCell(_ def: BadgeDefinition) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(Color.white.opacity(0.05)).frame(width: 64, height: 64)
                Text(def.emoji).font(.system(size: 30)).opacity(0.25)
                Image(systemName: "lock.fill").foregroundColor(.textTertiary).font(.system(size: 14))
                    .offset(x: 18, y: 18)
            }
            Text(def.name).font(.system(size: 10, weight: .semibold)).foregroundColor(.textTertiary)
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .padding(10)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    var streakMessage: String {
        switch vm.streak {
        case 1:     return "Day 1! Every journey starts here."
        case 2..<7: return "Keep it up! You're building momentum."
        case 7..<30: return "A whole week! You're dedicated."
        case 30...: return "A month+! You're a true 99%er!"
        default:    return "Start your streak today!"
        }
    }
}

// MARK: - Challenges
private struct ChallengesSection: View {
    @EnvironmentObject var vm: AppViewModel

    var activeIDs: Set<String>    { Set(vm.challenges.map { $0.challengeID }) }
    var completedIDs: Set<String> { Set(vm.challenges.filter { $0.isCompleted }.map { $0.challengeID }) }

    var body: some View {
        VStack(spacing: 14) {
            SectionHeader(title: "Active Challenges")
            let active = vm.challenges.filter { !$0.isCompleted }
            if active.isEmpty {
                CardView {
                    Text("Join a challenge below to get started!")
                        .font(.system(size: 14)).foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity).padding(20)
                }
            } else {
                ForEach(active) { c in
                    if let def = ChallengeCatalog.challenge(for: c.challengeID) {
                        activeChallengeCard(c, def: def)
                    }
                }
            }

            SectionHeader(title: "Available Challenges")
            ForEach(ChallengeCatalog.all.filter { !activeIDs.contains($0.id) }) { def in
                availableChallengeCard(def)
            }

            if !completedIDs.isEmpty {
                SectionHeader(title: "Completed 🏆")
                ForEach(ChallengeCatalog.all.filter { completedIDs.contains($0.id) }) { def in
                    completedChallengeCard(def)
                }
            }
        }
    }

    func activeChallengeCard(_ c: Challenge, def: ChallengeDefinition) -> some View {
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: c.endDate).day ?? 0
        return CardView {
            VStack(spacing: 12) {
                HStack {
                    Text(def.emoji).font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(def.name).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        Text("\(max(daysLeft, 0)) days left · \(def.difficulty)")
                            .font(.system(size: 11)).foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Text("+\(def.xpReward) XP").font(.system(size: 12, weight: .bold)).foregroundColor(.accentPurple)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.accentPurple.opacity(0.15)).clipShape(Capsule())
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                        Capsule().fill(Color.accentGreen)
                            .frame(width: geo.size.width * min(c.progress, 1), height: 8)
                    }
                }.frame(height: 8)
                HStack {
                    Text(String(format: "%.0f%%", c.progress * 100)).font(.system(size: 12, weight: .bold)).foregroundColor(.accentGreen)
                    Spacer()
                    Text(def.description).font(.system(size: 11)).foregroundColor(.textTertiary)
                }
            }.padding(14)
        }
    }

    func availableChallengeCard(_ def: ChallengeDefinition) -> some View {
        CardView {
            HStack(spacing: 14) {
                Text(def.emoji).font(.system(size: 30))
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(def.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        difficultyBadge(def.difficulty)
                    }
                    Text(def.description).font(.system(size: 11)).foregroundColor(.textSecondary)
                    Text("\(def.durationDays) days · +\(def.xpReward) XP")
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(.accentPurple)
                }
                Spacer()
                Button { vm.joinChallenge(id: def.id) } label: {
                    Text("Join").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.accentPurple).clipShape(Capsule())
                }
            }.padding(14)
        }
    }

    func completedChallengeCard(_ def: ChallengeDefinition) -> some View {
        CardView {
            HStack(spacing: 14) {
                Text(def.emoji).font(.system(size: 28))
                Text(def.name).font(.system(size: 14, weight: .bold)).foregroundColor(.textSecondary)
                Spacer()
                Image(systemName: "checkmark.circle.fill").foregroundColor(.accentGreen).font(.title3)
            }.padding(14)
        }
    }

    func difficultyBadge(_ d: String) -> some View {
        let color: Color = d == "Easy" ? .accentGreen : d == "Medium" ? .accentOrange : .accentRed
        return Text(d).font(.system(size: 9, weight: .bold)).foregroundColor(color)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.15)).clipShape(Capsule())
    }
}

// MARK: - Progress section
private struct ProgressSection: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 14) {
            // Weekly workout progress
            GoalCard(icon: "🏋️", title: "Weekly Workouts",
                     current: Double(vm.weekWorkouts().count),
                     goal: Double(vm.userProfile?.weeklyWorkoutGoal ?? 5),
                     unit: "sessions", color: .accentPurple)
            GoalCard(icon: "🔥", title: "Calories Burned (Week)",
                     current: vm.weeklyCaloriesBurned(), goal: 3000,
                     unit: "kcal", color: .accentOrange)
            GoalCard(icon: "🥗", title: "Today Calories",
                     current: vm.todayCaloriesConsumed, goal: vm.calGoal,
                     unit: "kcal", color: .accentGreen)
            GoalCard(icon: "🥩", title: "Today Protein",
                     current: vm.todayProtein, goal: vm.proteinGoal,
                     unit: "g", color: .accentRed)
            GoalCard(icon: "💧", title: "Today Water",
                     current: Double(vm.todayWaterML), goal: Double(vm.waterGoalML),
                     unit: "ml", color: .accentTeal)
            GoalCard(icon: "😴", title: "Last Night Sleep",
                     current: vm.lastNightSleep?.durationHrs ?? 0, goal: vm.sleepGoalHrs,
                     unit: "hrs", color: .accentPurple)
        }
    }
}

struct GoalCard: View {
    let icon: String; let title: String
    let current: Double; let goal: Double; let unit: String; let color: Color
    var progress: Double { goal > 0 ? min(current / goal, 1.0) : 0 }

    var body: some View {
        CardView {
            HStack(spacing: 14) {
                Text(icon).font(.title2)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        Spacer()
                        Text(String(format: "%.0f / %.0f %@", current, goal, unit))
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(color)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08)).frame(height: 7)
                            Capsule().fill(color).frame(width: geo.size.width * progress, height: 7)
                                .animation(.spring(response: 0.5), value: progress)
                        }
                    }.frame(height: 7)
                }
            }.padding(14)
        }
    }
}

