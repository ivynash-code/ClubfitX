import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name        = ""
    @State private var gender      = "Male"
    @State private var heightCm    = 170.0
    @State private var weightKg    = 75.0
    @State private var goalWeight  = 70.0
    @State private var calGoal     = 2000
    @State private var dob         = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var fitnessLevel = "Beginner"
    @State private var primaryGoal  = "Lose Weight"
    @State private var waterGoalL   = 2.5
    @State private var sleepGoalHrs = 8.0
    @State private var weeklyWorkoutGoal = 5
    let genders = ["Male","Female","Other"]
    let levels  = ["Beginner","Intermediate","Advanced"]
    let goals   = ["Lose Weight","Build Muscle","Stay Fit","Improve Stamina","Manage Stress"]

    var liveBMI: Double {
        let h = heightCm/100; return h>0 ? weightKg/(h*h) : 0
    }
    var bmiCat: BMICategory { BMICategory.from(bmi: liveBMI) }

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Live BMI card
                        CardView {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("BMI").font(.system(size: 11, weight: .bold)).foregroundColor(.textTertiary)
                                    Text(String(format: "%.1f", liveBMI))
                                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                                        .foregroundColor(Color(bmiCat.colorName))
                                    Text(bmiCat.rawValue + " " + bmiCat.emoji)
                                        .font(.system(size: 13, weight: .bold)).foregroundColor(Color(bmiCat.colorName))
                                }
                                Spacer()
                                BMIScaleBarView(bmi: liveBMI).frame(width: 120)
                            }.padding(16)
                        }

                        cardSection("Personal Details") {
                            VStack(spacing: 12) {
                                InputField(label: "Name", text: $name, placeholder: "Your name")
                                HStack(spacing: 8) {
                                    ForEach(genders, id:\.self) { g in
                                        Button { gender = g } label: {
                                            Text(g).font(.system(size:13,weight:.bold))
                                                .foregroundColor(gender==g ? .white : .textSecondary)
                                                .frame(maxWidth:.infinity).padding(.vertical,10)
                                                .background(gender==g ? Color.accentPurple : Color.bgCard2)
                                                .clipShape(RoundedRectangle(cornerRadius:10,style:.continuous))
                                        }
                                    }
                                }
                                VStack(alignment:.leading,spacing:4) {
                                    Text("DATE OF BIRTH").font(.system(size:10,weight:.bold)).foregroundColor(.textTertiary)
                                    DatePicker("", selection:$dob, in: ...Date(), displayedComponents:.date)
                                        .datePickerStyle(.compact).labelsHidden().colorScheme(.dark)
                                }
                            }
                        }

                        cardSection("Body Measurements") {
                            VStack(spacing:12) {
                                sliderRow("Height", value: $heightCm, range: 100...220, step: 1,
                                          display: String(format:"%.0f cm",heightCm), color: .accentPurple)
                                sliderRow("Current Weight", value: $weightKg, range: 30...200, step: 0.5,
                                          display: String(format:"%.1f kg",weightKg), color: .accentGreen)
                                sliderRow("Goal Weight", value: $goalWeight, range: 30...150, step: 0.5,
                                          display: String(format:"%.1f kg",goalWeight), color: .accentOrange)
                            }
                        }

                        cardSection("Fitness") {
                            VStack(spacing:12) {
                                VStack(alignment:.leading,spacing:6) {
                                    Text("FITNESS LEVEL").font(.system(size:10,weight:.bold)).foregroundColor(.textTertiary)
                                    HStack(spacing:8) {
                                        ForEach(levels,id:\.self) { l in
                                            Button { fitnessLevel=l } label: {
                                                Text(l).font(.system(size:12,weight:.bold))
                                                    .foregroundColor(fitnessLevel==l ? .white : .textSecondary)
                                                    .frame(maxWidth:.infinity).padding(.vertical,8)
                                                    .background(fitnessLevel==l ? Color.accentPurple : Color.bgCard2)
                                                    .clipShape(RoundedRectangle(cornerRadius:8,style:.continuous))
                                            }
                                        }
                                    }
                                }
                                VStack(alignment:.leading,spacing:6) {
                                    Text("PRIMARY GOAL").font(.system(size:10,weight:.bold)).foregroundColor(.textTertiary)
                                    ForEach(goals,id:\.self) { g in
                                        Button { primaryGoal=g } label: {
                                            HStack {
                                                Text(g).font(.system(size:14,weight:.semibold))
                                                    .foregroundColor(primaryGoal==g ? .white : .textSecondary)
                                                Spacer()
                                                if primaryGoal==g { Image(systemName:"checkmark.circle.fill").foregroundColor(.accentPurple) }
                                            }
                                            .padding(10)
                                            .background(primaryGoal==g ? Color.accentPurple.opacity(0.2) : Color.bgCard2)
                                            .clipShape(RoundedRectangle(cornerRadius:10,style:.continuous))
                                        }
                                    }
                                }
                            }
                        }

                        cardSection("Daily Goals") {
                            VStack(spacing:12) {
                                sliderRow("Calorie Goal", value: Binding(get:{Double(calGoal)}, set:{calGoal=Int($0)}),
                                          range: 1200...4000, step:50, display:"\(calGoal) kcal", color:.accentPurple)
                                sliderRow("Water Goal", value: $waterGoalL, range: 1...5, step:0.25,
                                          display:String(format:"%.2f L",waterGoalL), color:.accentTeal)
                                sliderRow("Sleep Goal", value: $sleepGoalHrs, range:5...12, step:0.5,
                                          display:String(format:"%.1f hrs",sleepGoalHrs), color:.accentPurple)
                                sliderRow("Weekly Workouts", value: Binding(get:{Double(weeklyWorkoutGoal)}, set:{weeklyWorkoutGoal=Int($0)}),
                                          range:1...14, step:1, display:"\(weeklyWorkoutGoal) sessions", color:.accentGreen)
                            }
                        }

                        GradientButton(title:"Save Profile", action: {
                            vm.updateProfile(
                                name: name.isEmpty ? "User" : name,
                                gender: gender, heightCm: heightCm,
                                dateOfBirth: dob, calGoal: calGoal,
                                proteinGoal: Int(weightKg*1.6),
                                carbsGoal: 250, fatGoal: 65,
                                goalWeight: goalWeight, startWeight: weightKg,
                                weeklyWorkoutGoal: weeklyWorkoutGoal,
                                fitnessLevel: fitnessLevel, primaryGoal: primaryGoal,
                                waterGoalL: waterGoalL, sleepGoalHrs: sleepGoalHrs
                            )
                            dismiss()
                        }, icon:"checkmark.circle.fill")
                        Spacer(minLength:80)
                    }.padding(.horizontal,16)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement:.navigationBarLeading) {
                Button("Cancel") { dismiss() }.foregroundColor(.textSecondary)
            }}
            .onAppear {
                if let p = vm.userProfile {
                    name=p.name; gender=p.gender; heightCm=p.heightCm
                    weightKg=p.startWeightKg; goalWeight=p.goalWeightKg
                    calGoal=Int(p.dailyCalorieGoal); dob=p.dateOfBirth ?? dob
                    fitnessLevel=p.fitnessLevel; primaryGoal=p.primaryGoal
                    waterGoalL=p.dailyWaterGoalL; sleepGoalHrs=p.dailySleepGoalHrs
                    weeklyWorkoutGoal=Int(p.weeklyWorkoutGoal)
                }
            }
        }
    }

    func cardSection<V:View>(_ title:String, @ViewBuilder content: ()->V) -> some View {
        CardView {
            VStack(alignment:.leading,spacing:12) {
                Text(title.uppercased()).font(.system(size:11,weight:.bold)).foregroundColor(.textTertiary).kerning(0.5)
                content()
            }.padding(16)
        }
    }

    func sliderRow(_ label:String, value:Binding<Double>, range:ClosedRange<Double>, step:Double, display:String, color:Color) -> some View {
        VStack(spacing:6) {
            HStack {
                Text(label).font(.system(size:13,weight:.semibold)).foregroundColor(.textSecondary)
                Spacer()
                Text(display).font(.system(size:14,weight:.heavy,design:.rounded)).foregroundColor(color)
            }
            Slider(value: value, in: range, step: step).tint(color)
        }
    }
}

// MARK: - Workout View (simplified for space — full version same as FitTrack)
struct WorkoutView: View {
    @EnvironmentObject var vm: AppViewModel
    @EnvironmentObject var hk: HealthKitManager
    @State private var showLog   = false
    @State private var shareItem: WorkoutEntry? = nil

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing:16) {
                        // Weekly summary
                        CardView {
                            HStack {
                                VStack(alignment:.leading) {
                                    Text("This Week").font(.system(size:14,weight:.bold)).foregroundColor(.textSecondary)
                                    Text("\(vm.weekWorkouts().count) Workouts")
                                        .font(.system(size:24,weight:.heavy)).foregroundColor(.white)
                                }
                                Spacer()
                                VStack(alignment:.trailing) {
                                    Text("Burned").font(.system(size:12)).foregroundColor(.textSecondary)
                                    Text("\(Int(vm.weeklyCaloriesBurned())) kcal")
                                        .font(.system(size:20,weight:.heavy)).foregroundColor(.accentOrange)
                                }
                            }.padding(16)
                        }

                        // Import from HealthKit
                        if hk.isAuthorized && !hk.recentWorkouts.isEmpty {
                            SectionHeader(title: "Import from Apple Health / Watch")
                            ForEach(hk.recentWorkouts.prefix(5), id:\.uuid) { w in
                                let imp = hk.workoutData(from: w)
                                let alreadyImported = vm.workouts.contains { $0.healthKitID == imp.healthKitID }
                                CardView {
                                    HStack(spacing:12) {
                                        Text(imp.emoji).font(.title2)
                                            .frame(width:44,height:44)
                                            .background(Color.accentPurple.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius:12,style:.continuous))
                                        VStack(alignment:.leading,spacing:2) {
                                            Text(imp.type).font(.system(size:14,weight:.bold)).foregroundColor(.white)
                                            Text("\(imp.durationMinutes) min · \(shortDate(imp.date))")
                                                .font(.system(size:11)).foregroundColor(.textSecondary)
                                            if imp.distanceKm > 0 {
                                                Text(String(format:"%.2f km",imp.distanceKm))
                                                    .font(.system(size:11)).foregroundColor(.accentTeal)
                                            }
                                        }
                                        Spacer()
                                        if alreadyImported {
                                            Image(systemName:"checkmark.circle.fill").foregroundColor(.accentGreen)
                                        } else {
                                            Button { vm.importFromHealthKit(imp) } label: {
                                                Label("Import", systemImage:"arrow.down.circle.fill")
                                                    .font(.system(size:12,weight:.bold)).foregroundColor(.white)
                                                    .padding(.horizontal,10).padding(.vertical,6)
                                                    .background(Color.accentPurple).clipShape(Capsule())
                                            }
                                        }
                                    }.padding(12)
                                }
                            }
                        }

                        GradientButton(title:"Log Workout", action: { showLog=true }, icon:"plus")

                        if vm.workouts.isEmpty {
                            EmptyStateView(icon:"figure.run", message:"No workouts yet.\nLog your first or import from Apple Health!")
                        } else {
                            SectionHeader(title:"All Workouts")
                            ForEach(vm.workouts) { w in
                                workoutRow(w)
                                    .swipeActions(edge:.trailing) {
                                        Button(role:.destructive) { vm.deleteWorkout(w) } label: { Label("Delete",systemImage:"trash") }
                                    }
                                    .swipeActions(edge:.leading) {
                                        Button { shareItem=w } label: { Label("Share",systemImage:"square.and.arrow.up") }.tint(.accentPurple)
                                    }
                            }
                        }
                        Spacer(minLength:100)
                    }.padding(.horizontal,16).padding(.top,4)
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showLog) { LogWorkoutSheet() }
            .sheet(item: $shareItem) { w in WorkoutShareSheet(workout: w).environmentObject(vm) }
        }
    }

    func workoutRow(_ w: WorkoutEntry) -> some View {
        CardView {
            HStack(spacing:12) {
                Text(w.emoji).font(.title2)
                    .frame(width:48,height:48)
                    .background(Color.accentPurple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius:13,style:.continuous))
                VStack(alignment:.leading,spacing:3) {
                    Text(w.type).font(.system(size:15,weight:.bold)).foregroundColor(.white)
                    HStack(spacing:6) {
                        Text(formatDate(w.date,style:.medium)).font(.system(size:11)).foregroundColor(.textTertiary)
                        if w.source != "Manual" {
                            Image(systemName:"applewatch").foregroundColor(.accentTeal).font(.system(size:10))
                        }
                    }
                    if w.distanceKm > 0 {
                        Text(String(format:"%.2f km",w.distanceKm)).font(.system(size:11)).foregroundColor(.accentTeal)
                    }
                }
                Spacer()
                VStack(alignment:.trailing,spacing:2) {
                    Text("\(Int(w.caloriesBurned))").font(.system(size:18,weight:.heavy,design:.rounded)).foregroundColor(.accentOrange)
                    Text("kcal").font(.system(size:10)).foregroundColor(.textTertiary)
                    Text("\(w.durationMinutes) min").font(.system(size:11)).foregroundColor(.textSecondary)
                    if w.avgHeartRate > 0 {
                        HStack(spacing:2) {
                            Image(systemName:"heart.fill").foregroundColor(.accentRed).font(.system(size:9))
                            Text("\(w.avgHeartRate)").font(.system(size:10)).foregroundColor(.accentRed)
                        }
                    }
                }
            }.padding(14)
        }
    }
}

// MARK: - Log Workout Sheet
struct LogWorkoutSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedType = WorkoutType.all[0]
    @State private var duration: Double = 30
    @State private var notes = ""
    var estimatedCalories: Int { Int(selectedType.caloriesPerMinute * duration) }

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing:20) {
                        Text("Select Workout").font(.system(size:14,weight:.semibold)).foregroundColor(.textSecondary).frame(maxWidth:.infinity,alignment:.leading)
                        LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())], spacing:10) {
                            ForEach(WorkoutType.all) { wt in
                                Button { selectedType=wt } label: {
                                    HStack(spacing:8) {
                                        Text(wt.emoji).font(.title3)
                                        Text(wt.name).font(.system(size:13,weight:.semibold)).foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(selectedType.id==wt.id ? Color.accentPurple.opacity(0.3) : Color.bgCard)
                                    .clipShape(RoundedRectangle(cornerRadius:14,style:.continuous))
                                    .overlay(RoundedRectangle(cornerRadius:14,style:.continuous)
                                        .stroke(selectedType.id==wt.id ? Color.accentPurple : Color.white.opacity(0.07), lineWidth: selectedType.id==wt.id ? 1.5 : 0.5))
                                }
                            }
                        }
                        CardView {
                            VStack(spacing:10) {
                                HStack {
                                    Text("Duration").font(.system(size:14,weight:.semibold)).foregroundColor(.textSecondary)
                                    Spacer()
                                    Text("\(Int(duration)) min").font(.system(size:18,weight:.heavy,design:.rounded)).foregroundColor(.accentPurple)
                                }
                                Slider(value:$duration, in:5...180, step:5).tint(.accentPurple)
                            }.padding(16)
                        }
                        CardView {
                            HStack {
                                Image(systemName:"flame.fill").foregroundColor(.accentOrange)
                                Text("Estimated Burn").font(.system(size:14,weight:.semibold)).foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(estimatedCalories) kcal").font(.system(size:18,weight:.heavy,design:.rounded)).foregroundColor(.accentOrange)
                            }.padding(16)
                        }
                        CardView {
                            VStack(alignment:.leading,spacing:8) {
                                Text("Notes").font(.system(size:13,weight:.semibold)).foregroundColor(.textSecondary)
                                TextField("How did it go?", text:$notes).font(.system(size:15)).foregroundColor(.white)
                            }.padding(16)
                        }
                        GradientButton(title:"Save Workout", action: {
                            vm.addWorkout(type:selectedType.name, emoji:selectedType.emoji,
                                          durationMinutes:Int(duration), caloriesBurned:Double(estimatedCalories),
                                          notes:notes.isEmpty ? nil : notes)
                            dismiss()
                        }, icon:"checkmark.circle.fill")
                        Spacer(minLength:40)
                    }.padding(20)
                }
            }
            .navigationTitle("Log Workout").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.navigationBarLeading) { Button("Cancel"){ dismiss() }.foregroundColor(.textSecondary) } }
        }
    }
}

// MARK: - Workout Share Card (Strava-style)
struct WorkoutShareCard: View {
    let workout: WorkoutEntry; let profile: UserProfile?
    var body: some View {
        ZStack {
            LinearGradient(colors:[Color(red:0.05,green:0.05,blue:0.15),Color(red:0.2,green:0.1,blue:0.4)],
                           startPoint:.topLeading, endPoint:.bottomTrailing)
            Circle().fill(Color.accentPurple.opacity(0.12)).frame(width:300,height:300).offset(x:80,y:-80)
            VStack(alignment:.leading,spacing:0) {
                HStack {
                    HStack(spacing:6) {
                        Image(systemName:"bolt.heart.fill").foregroundColor(.accentPurple).font(.system(size:13,weight:.bold))
                        Text("ClubFitX").font(.system(size:13,weight:.heavy)).foregroundColor(.white)
                        Text("by The 99 Percent Club").font(.system(size:10)).foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    Text(shortDate(workout.date)).font(.system(size:11)).foregroundColor(.white.opacity(0.5))
                }.padding(.bottom,18)
                HStack(spacing:12) {
                    Text(workout.emoji).font(.system(size:40))
                    VStack(alignment:.leading,spacing:2) {
                        Text(workout.type).font(.system(size:24,weight:.heavy)).foregroundColor(.white)
                        if let name=profile?.name { Text(name).font(.system(size:12)).foregroundColor(.white.opacity(0.6)) }
                    }
                }.padding(.bottom,22)
                HStack(spacing:0) {
                    statCol(value:"\(workout.durationMinutes)", unit:"MIN", label:"Duration", color:.accentPurple)
                    Divider().frame(height:44).background(Color.white.opacity(0.15))
                    statCol(value:"\(Int(workout.caloriesBurned))", unit:"KCAL", label:"Burned", color:.accentOrange)
                    if workout.distanceKm>0 {
                        Divider().frame(height:44).background(Color.white.opacity(0.15))
                        statCol(value:String(format:"%.1f",workout.distanceKm), unit:"KM", label:"Distance", color:.accentGreen)
                    }
                    if workout.avgHeartRate>0 {
                        Divider().frame(height:44).background(Color.white.opacity(0.15))
                        statCol(value:"\(workout.avgHeartRate)", unit:"BPM", label:"Avg HR", color:.accentRed)
                    }
                }.padding(.bottom,18)
                GeometryReader { geo in
                    ZStack(alignment:.leading) {
                        Capsule().fill(Color.white.opacity(0.1)).frame(height:6)
                        Capsule().fill(LinearGradient(colors:[.accentPurple,.accentGreen],startPoint:.leading,endPoint:.trailing)).frame(width:geo.size.width,height:6)
                    }
                }.frame(height:6)
                Text("#ClubFitX #The99PercentClub #\(workout.type.replacingOccurrences(of: " ", with: ""))")
                    .font(.system(size:10)).foregroundColor(.white.opacity(0.35)).padding(.top,14)
            }.padding(24)
        }
        .frame(width:360,height:500).clipShape(RoundedRectangle(cornerRadius:24,style:.continuous))
    }
    func statCol(value:String,unit:String,label:String,color:Color) -> some View {
        VStack(spacing:2) {
            HStack(alignment:.lastTextBaseline,spacing:2) {
                Text(value).font(.system(size:26,weight:.heavy,design:.rounded)).foregroundColor(.white)
                Text(unit).font(.system(size:9,weight:.bold)).foregroundColor(color)
            }
            Text(label).font(.system(size:9)).foregroundColor(.white.opacity(0.5))
        }.frame(maxWidth:.infinity)
    }
}

// MARK: - Workout Share Sheet
struct WorkoutShareSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    let workout: WorkoutEntry
    @State private var shareImage: UIImage?
    @State private var showShare = false

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView(showsIndicators:false) {
                    VStack(spacing:20) {
                        Text("Share Your Workout 🎉").font(.system(size:22,weight:.heavy)).foregroundColor(.white).padding(.top,8)
                        WorkoutShareCard(workout: workout, profile: vm.userProfile)
                            .shadow(color: Color.accentPurple.opacity(0.4), radius: 24, x: 0, y: 8)
                        VStack(spacing:12) {
                            shareBtn(icon:"square.and.arrow.up", label:"Share via WhatsApp / AirDrop", color:.accentGreen) { renderAndShare() }
                            shareBtn(icon:"camera.fill", label:"Share to Instagram / Stories", color:Color(red:0.87,green:0.24,blue:0.58)) { renderAndShare() }
                        }.padding(.horizontal,4)
                        Spacer(minLength:60)
                    }.padding(.horizontal,20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.navigationBarLeading) { Button("Close"){ dismiss() }.foregroundColor(.textSecondary) } }
            .sheet(isPresented:$showShare) { if let img=shareImage { ShareSheet(items:[img]) } }
        }
    }

    func shareBtn(icon:String,label:String,color:Color,action:@escaping()->Void) -> some View {
        Button(action:action) {
            HStack(spacing:14) {
                ZStack {
                    Circle().fill(color.opacity(0.2)).frame(width:44,height:44)
                    Image(systemName:icon).font(.system(size:16,weight:.semibold)).foregroundColor(color)
                }
                Text(label).font(.system(size:14,weight:.semibold)).foregroundColor(.white)
                Spacer()
                Image(systemName:"chevron.right").font(.caption).foregroundColor(.textTertiary)
            }
            .padding(14).background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius:16,style:.continuous))
        }
    }

    @MainActor func renderAndShare() {
        let card = WorkoutShareCard(workout:workout, profile:vm.userProfile).environmentObject(vm)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        shareImage = renderer.uiImage
        showShare = true
    }
}
