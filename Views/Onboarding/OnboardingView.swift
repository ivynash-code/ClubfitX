import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var hk: HealthKitManager
    @EnvironmentObject var notif: NotificationManager
    @Binding var hasOnboarded: Bool
    @State private var page = 0

    var body: some View {
        ZStack { Color.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<5) { i in
                        Capsule()
                            .fill(i == page ? Color.accentPurple : Color.white.opacity(0.2))
                            .frame(width: i == page ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                .padding(.top, 60).padding(.bottom, 20)

                switch page {
                case 0: WelcomePage(onNext: { withAnimation { page = 1 } })
                case 1: ProfilePage(onNext: { withAnimation { page = 2 } })
                case 2: GoalPage(onNext: { withAnimation { page = 3 } })
                case 3: PermissionsPage(onNext: { withAnimation { page = 4 } })
                default: ReadyPage(onDone: { hasOnboarded = true })
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Page 1: Welcome
private struct WelcomePage: View {
    let onNext: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // Logo area
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.accentPurple.opacity(0.3), Color.accentPurple.opacity(0.05)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 160, height: 160)
                VStack(spacing: 4) {
                    Text("💜").font(.system(size: 60))
                    Text("99%").font(.system(size: 22, weight: .heavy)).foregroundColor(.accentPurple)
                }
            }
            .padding(.bottom, 32)

            Text("ClubFitX").font(.system(size: 38, weight: .heavy)).foregroundColor(.white)
            Text("by The 99 Percent Club")
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.accentPurple)
                .padding(.bottom, 16)

            Text("The 1% that separates winners from the rest is showing up every day. Join the 99% who committed.")
                .font(.system(size: 15)).foregroundColor(.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 16) {
                featurePill(icon: "heart.fill",       text: "Apple Watch & HealthKit integration",  color: .accentRed)
                featurePill(icon: "fork.knife",       text: "130+ Indian foods with accurate data", color: .accentOrange)
                featurePill(icon: "trophy.fill",      text: "Badges, levels & team challenges",     color: .accentPurple)
                featurePill(icon: "moon.fill",        text: "Sleep, water & wellness tracking",      color: .accentTeal)
            }
            .padding(.horizontal, 24).padding(.bottom, 32)

            GradientButton(title: "Get Started →", action: onNext)
                .padding(.horizontal, 24).padding(.bottom, 48)
        }
    }

    func featurePill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15)).clipShape(Circle())
            Text(text).font(.system(size: 14, weight: .medium)).foregroundColor(.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Page 2: Profile
private struct ProfilePage: View {
    @EnvironmentObject var vm: AppViewModel
    let onNext: () -> Void
    @State private var name     = ""
    @State private var gender   = "Male"
    @State private var heightCm = 170.0
    @State private var weightKg = 75.0
    @State private var dob      = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    let genders = ["Male", "Female", "Other"]

    var liveBMI: Double {
        let h = heightCm / 100.0
        return h > 0 ? weightKg / (h * h) : 0
    }
    var bmiCat: BMICategory { BMICategory.from(bmi: liveBMI) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("👤").font(.system(size: 44))
                    Text("Your Profile").font(.system(size: 26, weight: .heavy)).foregroundColor(.white)
                    Text("Tell us about yourself").font(.system(size: 14)).foregroundColor(.textSecondary)
                }

                CardView {
                    VStack(spacing: 14) {
                        fieldLabel("Your Name")
                        TextField("e.g. Rahul Sharma", text: $name)
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                            .padding(12).background(Color.bgCard2)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }.padding(16)
                }

                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Gender")
                        HStack(spacing: 8) {
                            ForEach(genders, id: \.self) { g in
                                Button { withAnimation { gender = g } } label: {
                                    Text(genderEmoji(g) + " " + g)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(gender == g ? .white : .textSecondary)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(gender == g ? Color.accentPurple : Color.bgCard2)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }.padding(16)
                }

                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Date of Birth")
                        DatePicker("", selection: $dob, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact).labelsHidden().colorScheme(.dark)
                    }.padding(16)
                }

                CardView {
                    VStack(spacing: 12) {
                        HStack { fieldLabel("Height"); Spacer()
                            Text(String(format: "%.0f cm", heightCm))
                                .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.accentPurple)
                        }
                        Slider(value: $heightCm, in: 100...220, step: 1).tint(.accentPurple)
                    }.padding(16)
                }

                CardView {
                    VStack(spacing: 12) {
                        HStack { fieldLabel("Current Weight"); Spacer()
                            Text(String(format: "%.1f kg", weightKg))
                                .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.accentGreen)
                        }
                        Slider(value: $weightKg, in: 30...200, step: 0.5).tint(.accentGreen)
                    }.padding(16)
                }

                // Live BMI preview
                CardView {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            fieldLabel("Your BMI")
                            Text(String(format: "%.1f", liveBMI))
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(bmiCat.colorName))
                            Text(bmiCat.rawValue + "  " + bmiCat.emoji)
                                .font(.system(size: 13, weight: .bold)).foregroundColor(Color(bmiCat.colorName))
                        }
                        Spacer()
                        BMIScaleBarView(bmi: liveBMI).frame(width: 100)
                    }.padding(16)
                }

                GradientButton(title: "Next →", action: {
                    saveProfile()
                    onNext()
                }).padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
    }

    func saveProfile() {
        vm.updateProfile(
            name: name.isEmpty ? "User" : name,
            gender: gender, heightCm: heightCm,
            dateOfBirth: dob, calGoal: 2000,
            proteinGoal: Int(weightKg * 1.6),
            carbsGoal: 250, fatGoal: 65,
            goalWeight: max(weightKg - 5, 50),
            startWeight: weightKg,
            weeklyWorkoutGoal: 5,
            fitnessLevel: "Beginner",
            primaryGoal: "Lose Weight",
            waterGoalL: 2.5, sleepGoalHrs: 8
        )
        vm.addWeight(kg: weightKg, notes: "Starting weight")
    }

    func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased()).font(.system(size: 10, weight: .bold))
            .foregroundColor(.textTertiary).kerning(0.5)
    }
    func genderEmoji(_ g: String) -> String {
        switch g { case "Female": return "♀️"; case "Other": return "⚧️"; default: return "♂️" }
    }
}

// MARK: - Page 3: Goals
private struct GoalPage: View {
    @EnvironmentObject var vm: AppViewModel
    let onNext: () -> Void
    @State private var primaryGoal  = "Lose Weight"
    @State private var fitnessLevel = "Beginner"
    @State private var goalWeight   = 70.0
    @State private var calGoal      = 2000

    let goals   = ["Lose Weight", "Build Muscle", "Stay Fit", "Improve Stamina", "Manage Stress"]
    let levels  = ["Beginner", "Intermediate", "Advanced"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("🎯").font(.system(size: 44))
                    Text("Your Goals").font(.system(size: 26, weight: .heavy)).foregroundColor(.white)
                    Text("We'll personalise your plan").font(.system(size: 14)).foregroundColor(.textSecondary)
                }

                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Primary Goal")
                        ForEach(goals, id: \.self) { g in
                            Button { withAnimation { primaryGoal = g } } label: {
                                HStack {
                                    Text(goalEmoji(g)).font(.title3)
                                    Text(g).font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(primaryGoal == g ? .white : .textSecondary)
                                    Spacer()
                                    if primaryGoal == g {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.accentPurple)
                                    }
                                }
                                .padding(12)
                                .background(primaryGoal == g ? Color.accentPurple.opacity(0.2) : Color.bgCard2)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(primaryGoal == g ? Color.accentPurple : Color.clear, lineWidth: 1))
                            }
                        }
                    }.padding(16)
                }

                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Fitness Level")
                        HStack(spacing: 8) {
                            ForEach(levels, id: \.self) { l in
                                Button { withAnimation { fitnessLevel = l } } label: {
                                    Text(l).font(.system(size: 13, weight: .bold))
                                        .foregroundColor(fitnessLevel == l ? .white : .textSecondary)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(fitnessLevel == l ? Color.accentPurple : Color.bgCard2)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }.padding(16)
                }

                CardView {
                    VStack(spacing: 10) {
                        HStack { sectionLabel("Goal Weight"); Spacer()
                            Text(String(format: "%.1f kg", goalWeight))
                                .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.accentOrange)
                        }
                        Slider(value: $goalWeight, in: 30...150, step: 0.5).tint(.accentOrange)
                    }.padding(16)
                }

                CardView {
                    VStack(spacing: 10) {
                        HStack { sectionLabel("Daily Calorie Goal"); Spacer()
                            Text("\(calGoal) kcal")
                                .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.accentPurple)
                        }
                        Slider(value: Binding(get: { Double(calGoal) }, set: { calGoal = Int($0) }),
                               in: 1200...4000, step: 50).tint(.accentPurple)
                    }.padding(16)
                }

                GradientButton(title: "Next →", action: {
                    if let p = vm.userProfile {
                        vm.updateProfile(
                            name: p.name, gender: p.gender, heightCm: p.heightCm,
                            dateOfBirth: p.dateOfBirth, calGoal: calGoal,
                            proteinGoal: Int(p.startWeightKg * 1.6),
                            carbsGoal: 250, fatGoal: 65,
                            goalWeight: goalWeight, startWeight: p.startWeightKg,
                            weeklyWorkoutGoal: 5, fitnessLevel: fitnessLevel,
                            primaryGoal: primaryGoal, waterGoalL: 2.5, sleepGoalHrs: 8
                        )
                    }
                    onNext()
                }).padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
    }

    func sectionLabel(_ t: String) -> some View {
        Text(t.uppercased()).font(.system(size: 10, weight: .bold))
            .foregroundColor(.textTertiary).kerning(0.5)
    }
    func goalEmoji(_ g: String) -> String {
        switch g {
        case "Lose Weight": return "📉"
        case "Build Muscle": return "💪"
        case "Stay Fit": return "❤️"
        case "Improve Stamina": return "🏃"
        default: return "🧘"
        }
    }
}

// MARK: - Page 4: Permissions
private struct PermissionsPage: View {
    @EnvironmentObject var hk: HealthKitManager
    @EnvironmentObject var notif: NotificationManager
    let onNext: () -> Void
    @State private var hkGranted    = false
    @State private var notifGranted = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🔐").font(.system(size: 52))
            Text("Permissions").font(.system(size: 28, weight: .heavy)).foregroundColor(.white)
            Text("ClubFitX works best with these enabled")
                .font(.system(size: 14)).foregroundColor(.textSecondary).multilineTextAlignment(.center)

            VStack(spacing: 14) {
                permCard(
                    icon: "heart.fill", color: .accentRed,
                    title: "Apple Health & Watch",
                    desc: "Auto-sync workouts, steps, heart rate, sleep & weight",
                    granted: hkGranted
                ) {
                    Task {
                        await hk.requestAuthorization()
                        hkGranted = hk.isAuthorized
                    }
                }

                permCard(
                    icon: "bell.fill", color: .accentOrange,
                    title: "Notifications",
                    desc: "Water reminders, workout nudges, badge alerts & sleep reminders",
                    granted: notifGranted
                ) {
                    Task {
                        await notif.requestAuthorization()
                        notifGranted = notif.isAuthorized
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                GradientButton(title: "Continue →", action: onNext)
                Button("Skip for now") { onNext() }
                    .font(.system(size: 14)).foregroundColor(.textTertiary)
            }
            .padding(.horizontal, 24).padding(.bottom, 48)
        }
    }

    func permCard(icon: String, color: Color, title: String, desc: String,
                  granted: Bool, action: @escaping () -> Void) -> some View {
        CardView {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(color.opacity(0.2)).frame(width: 48, height: 48)
                    Image(systemName: icon).foregroundColor(color).font(.system(size: 20, weight: .semibold))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Text(desc).font(.system(size: 11)).foregroundColor(.textSecondary)
                }
                Spacer()
                if granted {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.accentGreen).font(.title3)
                } else {
                    Button(action: action) {
                        Text("Allow").font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white).padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color.accentPurple).clipShape(Capsule())
                    }
                }
            }.padding(16)
        }
    }
}

// MARK: - Page 5: Ready
private struct ReadyPage: View {
    let onDone: () -> Void
    @State private var animating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.accentPurple.opacity(0.08 - Double(i) * 0.02))
                        .frame(width: CGFloat(160 + i * 60), height: CGFloat(160 + i * 60))
                        .scaleEffect(animating ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever().delay(Double(i) * 0.3), value: animating)
                }
                Text("💜").font(.system(size: 72))
                    .scaleEffect(animating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(), value: animating)
            }
            .padding(.bottom, 40)

            Text("You're In!").font(.system(size: 36, weight: .heavy)).foregroundColor(.white)
            Text("Welcome to The 99 Percent Club")
                .font(.system(size: 17, weight: .semibold)).foregroundColor(.accentPurple)
                .padding(.bottom, 16)
            Text("Your journey to the best version of yourself starts now. The 1% difference is showing up every single day.")
                .font(.system(size: 15)).foregroundColor(.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)

            Spacer()
            GradientButton(title: "Start My Journey 🚀", action: onDone)
                .padding(.horizontal, 24).padding(.bottom, 48)
        }
        .onAppear { animating = true }
    }
}
