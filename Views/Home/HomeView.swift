import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var hk: HealthKitManager
    @State private var showProfile = false

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // MARK: Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(greeting) 👋")
                                    .font(.system(size: 14, weight: .medium)).foregroundColor(.textSecondary)
                                Text(vm.userProfile?.name ?? "Athlete")
                                    .font(.system(size: 24, weight: .heavy)).foregroundColor(.white)
                            }
                            Spacer()
                            // Level badge
                            Button { showProfile = true } label: {
                                VStack(spacing: 2) {
                                    ZStack {
                                        Circle()
                                            .fill(vm.currentLevel.color.opacity(0.25))
                                            .frame(width: 48, height: 48)
                                        Text(vm.currentLevel.emoji).font(.system(size: 22))
                                    }
                                    Text("Lv.\(vm.currentLevel.number)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(vm.currentLevel.color)
                                }
                            }
                        }
                        .padding(.top, 4)

                        // MARK: XP / Level Progress
                        CardView {
                            VStack(spacing: 10) {
                                HStack {
                                    Text(vm.currentLevel.emoji + " " + vm.currentLevel.name)
                                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                    Spacer()
                                    Text("\(vm.totalXP) XP")
                                        .font(.system(size: 13, weight: .bold)).foregroundColor(vm.currentLevel.color)
                                    if let next = vm.nextLevel {
                                        Text("→ \(next.name)")
                                            .font(.system(size: 11)).foregroundColor(.textTertiary)
                                    }
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                                        Capsule()
                                            .fill(LinearGradient(colors: [vm.currentLevel.color, vm.currentLevel.color.opacity(0.6)],
                                                                 startPoint: .leading, endPoint: .trailing))
                                            .frame(width: geo.size.width * vm.levelProgress, height: 8)
                                            .animation(.spring(response: 0.6), value: vm.levelProgress)
                                    }
                                }.frame(height: 8)
                            }.padding(14)
                        }

                        // MARK: Activity Rings
                        CardView {
                            HStack(spacing: 20) {
                                ZStack {
                                    ProgressRing(progress: min(Double(hk.todaySteps) / Double(vm.userProfile?.dailyStepGoal ?? 10000), 1),
                                                 lineWidth: 9, color: .accentOrange, size: 90)
                                    ProgressRing(progress: min(vm.todayCaloriesBurned / 600, 1),
                                                 lineWidth: 9, color: .accentGreen, size: 70)
                                    ProgressRing(progress: vm.waterProgress,
                                                 lineWidth: 9, color: .accentTeal, size: 50)
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Today's Activity").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                    ringRow(color: .accentOrange, label: "Steps",   value: "\(hk.todaySteps.formatted()) / \(vm.userProfile?.dailyStepGoal ?? 10000)")
                                    ringRow(color: .accentGreen,  label: "Burned",  value: "\(Int(vm.todayCaloriesBurned)) kcal")
                                    ringRow(color: .accentTeal,   label: "Water",   value: "\(vm.todayWaterML) / \(vm.waterGoalML) ml")
                                }
                                Spacer()
                            }.padding(16)
                        }

                        // MARK: Live HealthKit stats (Apple Watch)
                        if hk.isAuthorized {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                hkStatCard(label: "Heart Rate", value: hk.currentHeartRate > 0 ? "\(hk.currentHeartRate)" : "--",
                                           unit: "bpm", icon: "heart.fill", color: .accentRed)
                                hkStatCard(label: "Distance",  value: String(format: "%.1f", hk.todayDistance),
                                           unit: "km",  icon: "figure.walk", color: .accentOrange)
                                hkStatCard(label: "Calories",  value: "\(Int(hk.todayActiveCalories))",
                                           unit: "kcal", icon: "flame.fill", color: .accentGreen)
                                hkStatCard(label: "Sleep",     value: hk.recentSleep > 0 ? String(format: "%.1f", hk.recentSleep) : "--",
                                           unit: "hrs",  icon: "moon.fill", color: .accentPurple)
                            }
                        }

                        // MARK: BMI Card
                        if let bmi = vm.currentBMI {
                            CardView {
                                VStack(spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("BODY MASS INDEX").font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.textTertiary).kerning(0.5)
                                            HStack(alignment: .lastTextBaseline, spacing: 6) {
                                                Text(String(format: "%.1f", bmi))
                                                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                                                    .foregroundColor(Color(vm.currentBMICategory.colorName))
                                                Text(vm.currentBMICategory.emoji).font(.title2)
                                            }
                                            Text(vm.currentBMICategory.rawValue)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(Color(vm.currentBMICategory.colorName))
                                        }
                                        Spacer()
                                        BMIGaugeRing(bmi: bmi, category: vm.currentBMICategory)
                                    }
                                    BMIScaleBarView(bmi: bmi)
                                    Text(vm.currentBMICategory.advice)
                                        .font(.system(size: 12)).foregroundColor(.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.padding(16)
                            }
                        }

                        // MARK: Quick Log Row
                        SectionHeader(title: "Quick Log")
                        HStack(spacing: 10) {
                            quickLogButton(icon: "drop.fill",      label: "Water",   color: .accentTeal)   { vm.addWater(ml: 250) }
                            quickLogButton(icon: "moon.fill",      label: "Sleep",   color: .accentPurple) { }
                            quickLogButton(icon: "scalemass.fill", label: "Weight",  color: .accentGreen)  { }
                            quickLogButton(icon: "fork.knife",     label: "Meal",    color: .accentOrange) { }
                        }

                        // MARK: Streak
                        if vm.streak > 0 {
                            CardView {
                                HStack(spacing: 14) {
                                    Text("🔥").font(.system(size: 32))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(vm.streak)-Day Streak!").font(.system(size: 16, weight: .heavy)).foregroundColor(.white)
                                        Text("Keep going — you're unstoppable!").font(.system(size: 12)).foregroundColor(.textSecondary)
                                    }
                                    Spacer()
                                }.padding(14)
                            }
                        }

                        // MARK: HealthKit Import
                        if hk.isAuthorized && !hk.recentWorkouts.isEmpty {
                            SectionHeader(title: "Recent from Apple Health")
                            ForEach(hk.recentWorkouts.prefix(3), id: \.uuid) { w in
                                let imp = hk.workoutData(from: w)
                                CardView {
                                    HStack(spacing: 12) {
                                        Text(imp.emoji).font(.title2)
                                            .frame(width: 44, height: 44)
                                            .background(Color.accentPurple.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(imp.type).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                            Text("\(imp.durationMinutes) min · \(shortDate(imp.date))")
                                                .font(.system(size: 11)).foregroundColor(.textSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("\(Int(imp.caloriesBurned)) kcal")
                                                .font(.system(size: 13, weight: .bold)).foregroundColor(.accentOrange)
                                            Text("Apple Health").font(.system(size: 9)).foregroundColor(.textTertiary)
                                        }
                                        Button {
                                            vm.importFromHealthKit(imp)
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.accentPurple).font(.title3)
                                        }
                                    }.padding(12)
                                }
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) {
                ProfileView().environmentObject(vm)
            }
            .onAppear {
                Task { await hk.fetchAll() }
            }
        }
    }

    func ringRow(color: Color, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.textSecondary)
            Spacer()
            Text(value).font(.system(size: 11, weight: .bold)).foregroundColor(.white)
        }
    }

    func hkStatCard(label: String, value: String, unit: String, icon: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon).foregroundColor(color).font(.system(size: 13))
                    Text(label).font(.system(size: 10, weight: .bold)).foregroundColor(.textTertiary)
                }
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(value).font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundColor(.white)
                    Text(unit).font(.system(size: 11)).foregroundColor(.textSecondary)
                }
            }.padding(14)
        }
    }

    func quickLogButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.opacity(0.15)).frame(width: 56, height: 56)
                    Image(systemName: icon).foregroundColor(color).font(.system(size: 22, weight: .semibold))
                }
                Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - BMI Gauge Ring
struct BMIGaugeRing: View {
    let bmi: Double; let category: BMICategory
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.08), lineWidth: 10).frame(width: 80, height: 80)
            Circle().trim(from: 0, to: min((bmi - 10) / 30, 1))
                .stroke(Color(category.colorName), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90)).frame(width: 80, height: 80)
                .animation(.spring(response: 0.6), value: bmi)
            VStack(spacing: 0) {
                Text(String(format: "%.0f", bmi))
                    .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundColor(.white)
                Text("BMI").font(.system(size: 9)).foregroundColor(.textTertiary)
            }
        }
    }
}
