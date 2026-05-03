import SwiftUI

struct TrackingView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTab = 0
    let tabs = ["💧 Water", "😴 Sleep", "⚖️ Weight"]

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Tab picker
                    Picker("", selection: $selectedTab) {
                        ForEach(tabs.indices, id: \.self) { Text(tabs[$0]).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16).padding(.vertical, 10)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            switch selectedTab {
                            case 0: WaterSection()
                            case 1: SleepSection()
                            default: WeightSection()
                            }
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 16).padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Track")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Water Section
private struct WaterSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showCustom = false
    @State private var customML   = ""

    let quickAmounts = [150, 200, 250, 350, 500]

    var body: some View {
        VStack(spacing: 16) {
            // Big water ring
            CardView {
                VStack(spacing: 14) {
                    ZStack {
                        ProgressRing(progress: vm.waterProgress, lineWidth: 14, color: .accentTeal, size: 130)
                        VStack(spacing: 2) {
                            Text("\(vm.todayWaterML)").font(.system(size: 28, weight: .heavy, design: .rounded)).foregroundColor(.white)
                            Text("ml").font(.system(size: 12)).foregroundColor(.textTertiary)
                            Text("of \(vm.waterGoalML) ml").font(.system(size: 11)).foregroundColor(.textSecondary)
                        }
                    }
                    Text(vm.waterProgress >= 1 ? "🎉 Goal Reached!" : "\(vm.waterGoalML - vm.todayWaterML) ml remaining")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(vm.waterProgress >= 1 ? .accentGreen : .textSecondary)
                }.padding(20)
            }

            // Quick add buttons
            SectionHeader(title: "Quick Add")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(quickAmounts, id: \.self) { ml in
                    Button { vm.addWater(ml: ml) } label: {
                        VStack(spacing: 4) {
                            Text("💧").font(.title2)
                            Text("\(ml) ml").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.07), lineWidth: 0.5))
                    }
                }
                Button {
                    showCustom = true
                } label: {
                    VStack(spacing: 4) {
                        Text("✏️").font(.title2)
                        Text("Custom").font(.system(size: 13, weight: .bold)).foregroundColor(.accentPurple)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }

            // Today's log
            if !vm.todayWater.isEmpty {
                SectionHeader(title: "Today's Log")
                ForEach(vm.todayWater) { entry in
                    CardView {
                        HStack {
                            Text("💧").font(.title3)
                            Text("\(entry.amountML) ml").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            Spacer()
                            Text(timeString(entry.date)).font(.system(size: 12)).foregroundColor(.textSecondary)
                        }.padding(14)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { vm.deleteWater(entry) } label: { Label("Delete", systemImage: "trash") }
                    }
                }
            }
        }
        .alert("Custom Amount", isPresented: $showCustom) {
            TextField("Amount in ml", text: $customML).keyboardType(.numberPad)
            Button("Add") { if let ml = Int(customML) { vm.addWater(ml: ml) }; customML = "" }
            Button("Cancel", role: .cancel) { customML = "" }
        }
    }
}

// MARK: - Sleep Section
private struct SleepSection: View {
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var hk: HealthKitManager
    @State private var showLog   = false
    @State private var bedtime   = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date()) ?? Date()
    @State private var wakeTime  = Calendar.current.date(bySettingHour: 6,  minute: 30, second: 0, of: Date().addingTimeInterval(86400)) ?? Date()
    @State private var quality   = "Good"

    let qualities = ["Poor", "Fair", "Good", "Excellent"]

    var duration: Double { wakeTime.timeIntervalSince(bedtime) / 3600 }

    var body: some View {
        VStack(spacing: 16) {
            // Sleep summary
            CardView {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LAST NIGHT").font(.system(size: 10, weight: .bold))
                                .foregroundColor(.textTertiary).kerning(0.5)
                            let hrs = hk.recentSleep > 0 ? hk.recentSleep : (vm.lastNightSleep?.durationHrs ?? 0)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text(String(format: "%.1f", hrs))
                                    .font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundColor(.white)
                                Text("hrs").font(.system(size: 16)).foregroundColor(.textSecondary)
                            }
                            if let s = vm.lastNightSleep {
                                Text("\(timeString(s.bedtime)) → \(timeString(s.wakeTime))")
                                    .font(.system(size: 12)).foregroundColor(.textSecondary)
                            }
                        }
                        Spacer()
                        ProgressRing(progress: vm.sleepProgress, lineWidth: 10, color: .accentPurple, size: 80)
                    }

                    // Quality chips
                    if let s = vm.lastNightSleep {
                        HStack {
                            qualityChip(s.quality)
                            if hk.recentSleep > 0 {
                                Text("· Apple Watch").font(.system(size: 11)).foregroundColor(.textTertiary)
                            }
                            Spacer()
                        }
                    }
                }.padding(16)
            }

            // Sleep goal progress
            if vm.sleepGoalHrs > 0 {
                CardView {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Goal: \(String(format: "%.0f", vm.sleepGoalHrs))h")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(.textSecondary)
                            Spacer()
                            let diff = (hk.recentSleep > 0 ? hk.recentSleep : vm.lastNightSleep?.durationHrs ?? 0) - vm.sleepGoalHrs
                            Text(diff >= 0 ? "+\(String(format: "%.1f", diff))h" : "\(String(format: "%.1f", diff))h")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(diff >= 0 ? .accentGreen : .accentRed)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                                Capsule().fill(Color.accentPurple)
                                    .frame(width: geo.size.width * vm.sleepProgress, height: 8)
                            }
                        }.frame(height: 8)
                    }.padding(14)
                }
            }

            GradientButton(title: "Log Sleep", action: { showLog = true }, icon: "moon.fill", color1: Color(red:0.3,green:0.1,blue:0.7), color2: .accentPurple)

            // Sleep tips
            SectionHeader(title: "Sleep Tips")
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sleepTips, id: \.0) { tip in
                        HStack(alignment: .top, spacing: 10) {
                            Text(tip.0).font(.system(size: 16))
                            Text(tip.1).font(.system(size: 13)).foregroundColor(.textSecondary)
                        }
                    }
                }.padding(16)
            }

            // History
            if !vm.sleepHistory.isEmpty {
                SectionHeader(title: "Sleep History")
                ForEach(vm.sleepHistory.prefix(7)) { entry in
                    CardView {
                        HStack {
                            Text("😴").font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatDate(entry.date, style: .medium))
                                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                Text("\(timeString(entry.bedtime)) → \(timeString(entry.wakeTime))")
                                    .font(.system(size: 11)).foregroundColor(.textSecondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.1fh", entry.durationHrs))
                                    .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.accentPurple)
                                qualityChip(entry.quality)
                            }
                        }.padding(14)
                    }
                    .swipeActions { Button(role: .destructive) { vm.deleteSleep(entry) } label: { Label("Delete", systemImage: "trash") } }
                }
            }
        }
        .sheet(isPresented: $showLog) {
            NavigationView {
                ZStack { Color.bg.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            CardView {
                                VStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("BEDTIME").font(.system(size: 10, weight: .bold)).foregroundColor(.textTertiary)
                                        DatePicker("", selection: $bedtime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.wheel).labelsHidden().colorScheme(.dark)
                                    }
                                    Divider().background(Color.white.opacity(0.08))
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("WAKE TIME").font(.system(size: 10, weight: .bold)).foregroundColor(.textTertiary)
                                        DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.wheel).labelsHidden().colorScheme(.dark)
                                    }
                                }.padding(16)
                            }

                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("SLEEP QUALITY").font(.system(size: 10, weight: .bold)).foregroundColor(.textTertiary)
                                    HStack(spacing: 8) {
                                        ForEach(qualities, id: \.self) { q in
                                            Button { quality = q } label: {
                                                Text(q).font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(quality == q ? .white : .textSecondary)
                                                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                                                    .background(quality == q ? Color.accentPurple : Color.bgCard2)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                            }
                                        }
                                    }
                                }.padding(16)
                            }

                            let dur = max(wakeTime.timeIntervalSince(bedtime) / 3600, 0)
                            Text(String(format: "Duration: %.1f hours", dur))
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.accentPurple)

                            GradientButton(title: "Save Sleep", action: {
                                vm.addSleep(bedtime: bedtime, wakeTime: wakeTime, quality: quality)
                                showLog = false
                            }, icon: "moon.fill")
                        }.padding(20)
                    }
                }
                .navigationTitle("Log Sleep")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showLog = false }.foregroundColor(.textSecondary)
                }}
            }
        }
    }

    func qualityChip(_ q: String) -> some View {
        let color: Color
        switch q {
        case "Excellent": color = .accentGreen
        case "Good":      color = .accentTeal
        case "Fair":      color = .accentOrange
        default:          color = .accentRed
        }
        return Text(q).font(.system(size: 10, weight: .bold)).foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15)).clipShape(Capsule())
    }

    var sleepTips: [(String, String)] {[
        ("🌙", "Avoid screens 30 minutes before bed"),
        ("☕", "Cut caffeine after 2 PM"),
        ("🌡️", "Keep your room cool (18-20°C)"),
        ("📅", "Sleep and wake at the same time daily"),
        ("🧘", "Try 4-7-8 breathing to wind down"),
    ]}
}

// MARK: - Weight Section
private struct WeightSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showLog = false
    @State private var weight  = 70.0
    @State private var notes   = ""

    var liveBMI: Double? { vm.userProfile?.bmi(weightKg: weight) }
    var liveCat: BMICategory { liveBMI.map { BMICategory.from(bmi: $0) } ?? .unknown }

    var body: some View {
        VStack(spacing: 16) {
            // Hero weight + BMI
            CardView {
                VStack(spacing: 14) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(vm.latestWeight.map { String(format: "%.1f", $0) } ?? "--")
                            .font(.system(size: 52, weight: .heavy, design: .rounded)).foregroundColor(.white)
                        Text("kg").font(.system(size: 20)).foregroundColor(.textSecondary)
                    }
                    if let bmi = vm.currentBMI {
                        HStack(spacing: 8) {
                            Text(String(format: "BMI: %.1f", bmi))
                                .font(.system(size: 14, weight: .bold)).foregroundColor(Color(vm.currentBMICategory.colorName))
                            Text("·").foregroundColor(.textTertiary)
                            Text(vm.currentBMICategory.rawValue + " " + vm.currentBMICategory.emoji)
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(Color(vm.currentBMICategory.colorName))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color(vm.currentBMICategory.colorName).opacity(0.12)).clipShape(Capsule())
                    }

                    if let p = vm.userProfile, let current = vm.latestWeight {
                        let progress = p.startWeightKg > p.goalWeightKg
                            ? (p.startWeightKg - current) / (p.startWeightKg - p.goalWeightKg)
                            : 0
                        VStack(spacing: 6) {
                            HStack {
                                Text("Start: \(String(format: "%.1f", p.startWeightKg)) kg").font(.system(size: 11)).foregroundColor(.textTertiary)
                                Spacer()
                                Text("Goal: \(String(format: "%.1f", p.goalWeightKg)) kg").font(.system(size: 11)).foregroundColor(.accentGreen)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                                    Capsule()
                                        .fill(LinearGradient(colors: [.accentPurple, .accentGreen], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * max(0, min(progress, 1)), height: 8)
                                }
                            }.frame(height: 8)
                            Text(String(format: "%.0f%% to goal", min(progress * 100, 100)))
                                .font(.system(size: 12, weight: .semibold)).foregroundColor(.accentPurple)
                        }
                    }
                }.padding(16)
            }

            // Weight chart
            if !vm.weeklyWeightData.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("7-Day Trend").font(.system(size: 13, weight: .bold)).foregroundColor(.textSecondary)
                        WeightMiniChart(data: vm.weeklyWeightData)
                    }.padding(16)
                }
            }

            GradientButton(title: "Log Weight", action: { showLog = true }, icon: "scalemass.fill")

            // History
            if !vm.weightHistory.isEmpty {
                SectionHeader(title: "Weight History")
                ForEach(vm.weightHistory.prefix(10)) { entry in
                    CardView {
                        HStack {
                            Image(systemName: "scalemass.fill").foregroundColor(.accentPurple).font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatDate(entry.date, style: .medium))
                                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                if let bmi = vm.userProfile?.bmi(weightKg: entry.weightKg) {
                                    let cat = BMICategory.from(bmi: bmi)
                                    Text(String(format: "BMI %.1f · %@", bmi, cat.rawValue))
                                        .font(.system(size: 11)).foregroundColor(Color(cat.colorName))
                                }
                            }
                            Spacer()
                            Text(String(format: "%.1f kg", entry.weightKg))
                                .font(.system(size: 17, weight: .heavy, design: .rounded)).foregroundColor(.white)
                        }.padding(14)
                    }
                    .swipeActions { Button(role: .destructive) { vm.deleteWeight(entry) } label: { Label("Delete", systemImage: "trash") } }
                }
            }
        }
        .sheet(isPresented: $showLog) {
            NavigationView {
                ZStack { Color.bg.ignoresSafeArea()
                    VStack(spacing: 20) {
                        CardView {
                            VStack(spacing: 16) {
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text(String(format: "%.1f", weight))
                                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                                        .foregroundColor(.accentPurple).animation(.spring(), value: weight)
                                    Text("kg").font(.system(size: 22)).foregroundColor(.textSecondary)
                                }
                                if let b = liveBMI {
                                    Text(String(format: "BMI: %.1f  %@  %@", b, liveCat.rawValue, liveCat.emoji))
                                        .font(.system(size: 13, weight: .bold)).foregroundColor(Color(liveCat.colorName))
                                }
                                Slider(value: $weight, in: 30...200, step: 0.1).tint(.accentPurple)
                                HStack(spacing: 8) {
                                    ForEach([-1.0, -0.5, -0.1, 0.1, 0.5, 1.0], id: \.self) { d in
                                        Button { weight = max(30, min(200, weight + d)) } label: {
                                            Text(d > 0 ? "+\(String(format:"%.1f",d))" : String(format:"%.1f",d))
                                                .font(.system(size: 11, weight: .bold)).foregroundColor(.accentPurple)
                                                .padding(.horizontal, 8).padding(.vertical, 5)
                                                .background(Color.accentPurple.opacity(0.15)).clipShape(Capsule())
                                        }
                                    }
                                }
                            }.padding(20)
                        }
                        InputField(label: "Notes", text: $notes, placeholder: "Morning, post-workout…")
                        GradientButton(title: "Save Weight", action: {
                            vm.addWeight(kg: weight, notes: notes.isEmpty ? nil : notes)
                            showLog = false
                        }, icon: "checkmark.circle.fill")
                        Spacer()
                    }.padding(16).onAppear { weight = vm.latestWeight ?? 70 }
                }
                .navigationTitle("Log Weight").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showLog = false }.foregroundColor(.textSecondary)
                }}
            }
        }
    }
}

// MARK: - Weight Chart
struct WeightMiniChart: View {
    let data: [(date: Date, weight: Double)]
    var minW: Double { data.map(\.weight).min() ?? 70 }
    var maxW: Double { data.map(\.weight).max() ?? 80 }
    var range: Double { max(maxW - minW, 0.5) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height; let count = data.count
            ZStack(alignment: .bottomLeading) {
                if count > 1 {
                    Path { p in
                        for (i, pt) in data.enumerated() {
                            let x = w * Double(i) / Double(count - 1)
                            let y = h - (h * (pt.weight - minW) / range)
                            i == 0 ? p.move(to: CGPoint(x:x,y:y)) : p.addLine(to: CGPoint(x:x,y:y))
                        }
                    }.stroke(Color.accentPurple, style: StrokeStyle(lineWidth:2.5, lineCap:.round, lineJoin:.round))

                    Path { p in
                        for (i, pt) in data.enumerated() {
                            let x = w * Double(i) / Double(count - 1)
                            let y = h - (h * (pt.weight - minW) / range)
                            if i == 0 { p.move(to:CGPoint(x:0,y:h)); p.addLine(to:CGPoint(x:x,y:y)) }
                            else { p.addLine(to:CGPoint(x:x,y:y)) }
                        }
                        p.addLine(to:CGPoint(x:w,y:h)); p.closeSubpath()
                    }.fill(LinearGradient(colors:[Color.accentPurple.opacity(0.25),.clear], startPoint:.top, endPoint:.bottom))

                    ForEach(data.indices, id:\.self) { i in
                        let x = w * Double(i) / Double(count-1)
                        let y = h - (h * (data[i].weight - minW) / range)
                        Circle().fill(Color.accentPurple).frame(width:6,height:6).position(x:x,y:y)
                        Text(String(format:"%.1f", data[i].weight))
                            .font(.system(size:8,weight:.bold)).foregroundColor(.textSecondary).position(x:x,y:max(y-14,8))
                    }
                }
                HStack {
                    ForEach(data.indices, id:\.self) { i in
                        Text(shortDay(data[i].date)).font(.system(size:9,weight:.semibold)).foregroundColor(.textTertiary).frame(maxWidth:.infinity)
                    }
                }.offset(y: h+4)
            }
        }.frame(height:100).padding(.bottom,18)
    }
}
