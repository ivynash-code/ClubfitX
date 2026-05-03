import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showAddFood = false
    let meals = ["Breakfast","Lunch","Dinner","Snacks"]

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Calorie ring + macros
                        CardView {
                            VStack(spacing: 14) {
                                HStack(spacing: 20) {
                                    ZStack {
                                        ProgressRing(progress: vm.todayCaloriesConsumed / vm.calGoal,
                                                     lineWidth: 12, color: .accentPurple, size: 100)
                                        VStack(spacing: 0) {
                                            Text("\(Int(vm.todayCaloriesConsumed))")
                                                .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundColor(.white)
                                            Text("kcal").font(.system(size: 9)).foregroundColor(.textTertiary)
                                            Text("eaten").font(.system(size: 9)).foregroundColor(.textTertiary)
                                        }
                                    }
                                    VStack(spacing: 8) {
                                        nutStat(label: "Goal",      value: "\(Int(vm.calGoal)) kcal",                     color: .textSecondary)
                                        nutStat(label: "Burned",    value: "\(Int(vm.todayCaloriesBurned)) kcal",          color: .accentOrange)
                                        nutStat(label: "Remaining", value: "\(Int(max(0, vm.calGoal - vm.todayCaloriesConsumed))) kcal", color: .accentGreen)
                                    }.frame(maxWidth: .infinity)
                                }
                                Divider().background(Color.white.opacity(0.08))
                                VStack(spacing: 10) {
                                    MacroBar(label: "Protein", current: vm.todayProtein, goal: vm.proteinGoal, color: .accentRed)
                                    MacroBar(label: "Carbs",   current: vm.todayCarbs,   goal: vm.carbsGoal,   color: .accentOrange)
                                    MacroBar(label: "Fat",     current: vm.todayFat,     goal: vm.fatGoal,     color: .accentPurple)
                                    MacroBar(label: "Fiber",   current: vm.todayFiber,   goal: 30,             color: .accentGreen)
                                }
                            }.padding(16)
                        }

                        GradientButton(title: "Add Food", action: { showAddFood = true }, icon: "plus.circle.fill")

                        // Meal sections
                        ForEach(meals, id: \.self) { meal in
                            let entries = vm.nutritionEntries(for: meal)
                            if !entries.isEmpty { MealSectionView(mealType: meal, entries: entries) }
                        }

                        if vm.todayNutrition.isEmpty {
                            EmptyStateView(icon: "fork.knife",
                                           message: "No food logged today.\nSearch from 130+ Indian foods!")
                        }
                        Spacer(minLength: 100)
                    }.padding(.horizontal, 16).padding(.top, 4)
                }
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddFood) { AddFoodSheet() }
        }
    }

    func nutStat(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(.textTertiary)
            Spacer()
            Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(color)
        }
    }
}

// MARK: - Meal Section
struct MealSectionView: View {
    @EnvironmentObject var vm: AppViewModel
    let mealType: String
    let entries: [NutritionEntry]
    var totalCal: Double { entries.reduce(0) { $0 + $1.calories } }

    var mealIcon: String {
        switch mealType {
        case "Breakfast": return "☀️"
        case "Lunch":     return "🌤"
        case "Dinner":    return "🌙"
        default:          return "🍎"
        }
    }

    var body: some View {
        CardView {
            VStack(spacing: 0) {
                HStack {
                    Text(mealIcon).font(.title3)
                    Text(mealType).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Text("\(Int(totalCal)) kcal").font(.system(size: 13, weight: .bold)).foregroundColor(.accentPurple)
                }.padding(14)
                Divider().background(Color.white.opacity(0.07))
                ForEach(entries) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.foodName).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            Text("\(entry.servingSize) · \(String(format: "%.1f", entry.quantity))x")
                                .font(.system(size: 11)).foregroundColor(.textSecondary)
                            HStack(spacing: 6) {
                                macroChip("P", "\(Int(entry.protein))g", .accentRed)
                                macroChip("C", "\(Int(entry.carbs))g",   .accentOrange)
                                macroChip("F", "\(Int(entry.fat))g",     .accentPurple)
                            }
                        }
                        Spacer()
                        Text("\(Int(entry.calories))").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.white)
                        Text("kcal").font(.system(size: 10)).foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { vm.deleteNutritionEntry(entry) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    if entry.id != entries.last?.id {
                        Divider().background(Color.white.opacity(0.05)).padding(.horizontal, 14)
                    }
                }
            }
        }
    }

    func macroChip(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 2) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(color)
            Text(value).font(.system(size: 9, weight: .semibold)).foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 5).padding(.vertical, 2)
        .background(color.opacity(0.12)).clipShape(Capsule())
    }
}

// MARK: - Add Food Sheet
struct AddFoodSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText       = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var selectedMeal     = "Breakfast"
    @State private var selectedFood: IndianFoodItem?  = nil
    @State private var showCustom       = false
    let meals = ["Breakfast","Lunch","Dinner","Snacks"]

    var filteredFoods: [IndianFoodItem] {
        var list = selectedCategory == nil ? IndianFoodDatabase.allFoods : IndianFoodDatabase.byCategory(selectedCategory!)
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            list = IndianFoodDatabase.search(query: searchText)
        }
        return list
    }

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Meal", selection: $selectedMeal) {
                        ForEach(meals, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented).padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundColor(.textTertiary)
                        TextField("Search 130+ Indian foods…", text: $searchText).foregroundColor(.white)
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.textTertiary)
                            }
                        }
                    }
                    .padding(12).background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 16).padding(.bottom, 8)

                    if searchText.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                categoryChip("All", selectedCategory == nil) { selectedCategory = nil }
                                ForEach(FoodCategory.allCases, id: \.self) { cat in
                                    categoryChip(cat.rawValue, selectedCategory == cat) {
                                        selectedCategory = selectedCategory == cat ? nil : cat
                                    }
                                }
                            }.padding(.horizontal, 16)
                        }.padding(.bottom, 8)
                    }

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            Button { showCustom = true } label: {
                                HStack {
                                    Image(systemName: "square.and.pencil").foregroundColor(.accentPurple)
                                    Text("Add Custom Food").font(.system(size: 14, weight: .semibold)).foregroundColor(.accentPurple)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.textTertiary)
                                }.padding(.horizontal, 16).padding(.vertical, 12)
                            }
                            Divider().background(Color.white.opacity(0.05))

                            ForEach(filteredFoods) { food in
                                Button { selectedFood = food } label: {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(food.name).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                            HStack(spacing: 6) {
                                                Text(food.category.rawValue).font(.system(size: 10)).foregroundColor(.accentPurple)
                                                if let r = food.region { Text("· \(r)").font(.system(size: 10)).foregroundColor(.textTertiary) }
                                                Text("· \(food.servingSize)").font(.system(size: 10)).foregroundColor(.textTertiary)
                                            }
                                            HStack(spacing: 6) {
                                                macroMini("P", "\(Int(food.proteinPerServing))g", .accentRed)
                                                macroMini("C", "\(Int(food.carbsPerServing))g",   .accentOrange)
                                                macroMini("F", "\(Int(food.fatPerServing))g",     .accentPurple)
                                            }
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("\(Int(food.caloriesPerServing))").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundColor(.white)
                                            Text("kcal").font(.system(size: 10)).foregroundColor(.textTertiary)
                                        }
                                    }.padding(.horizontal, 16).padding(.vertical, 12)
                                }
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Food").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundColor(.textSecondary) } }
            .sheet(item: $selectedFood) { food in FoodDetailSheet(food: food, mealType: selectedMeal) }
            .sheet(isPresented: $showCustom) { CustomFoodSheet(mealType: selectedMeal) }
        }
    }

    func categoryChip(_ label: String, _ selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 12, weight: .semibold))
                .foregroundColor(selected ? .white : .textSecondary)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(selected ? Color.accentPurple : Color.bgCard)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.07), lineWidth: 0.5))
        }
    }

    func macroMini(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 2) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(color)
            Text(value).font(.system(size: 9)).foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 4).padding(.vertical, 2)
        .background(color.opacity(0.1)).clipShape(Capsule())
    }
}

// MARK: - Food Detail Sheet
struct FoodDetailSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let food: IndianFoodItem
    let mealType: String
    @State private var quantity: Double = 1.0

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                VStack(spacing: 20) {
                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(food.name).font(.system(size: 20, weight: .heavy)).foregroundColor(.white)
                            Text(food.category.rawValue + (food.region.map { " · \($0)" } ?? ""))
                                .font(.system(size: 13)).foregroundColor(.accentPurple)
                            Text("Per serving: \(food.servingSize) (\(Int(food.servingGrams))g)")
                                .font(.system(size: 12)).foregroundColor(.textSecondary)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
                    }

                    CardView {
                        VStack(spacing: 6) {
                            nutRow100g("Calories",  food.caloriesPer100g, "kcal", .accentOrange)
                            nutRow100g("Protein",   food.proteinPer100g,  "g",    .accentRed)
                            nutRow100g("Carbs",     food.carbsPer100g,    "g",    .accentOrange)
                            nutRow100g("Fat",       food.fatPer100g,      "g",    .accentPurple)
                            nutRow100g("Fiber",     food.fiberPer100g,    "g",    .accentGreen)
                        }.padding(14)
                    }

                    CardView {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Servings").font(.system(size: 14, weight: .semibold)).foregroundColor(.textSecondary)
                                Spacer()
                                Text(String(format: "%.2f", quantity))
                                    .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundColor(.accentPurple)
                            }
                            Slider(value: $quantity, in: 0.25...5, step: 0.25).tint(.accentPurple)
                            HStack(spacing: 16) {
                                liveMacro(food.caloriesPerServing * quantity, "kcal", .white)
                                liveMacro(food.proteinPerServing  * quantity, "P",    .accentRed)
                                liveMacro(food.carbsPerServing    * quantity, "C",    .accentOrange)
                                liveMacro(food.fatPerServing      * quantity, "F",    .accentPurple)
                            }
                        }.padding(16)
                    }

                    GradientButton(title: "Add to \(mealType)", action: {
                        vm.addNutritionEntry(food: food, mealType: mealType, quantity: quantity)
                        dismiss()
                    }, icon: "plus.circle.fill")
                    Spacer()
                }.padding(16)
            }
            .navigationTitle("Add Food").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Back") { dismiss() }.foregroundColor(.textSecondary) } }
        }
    }

    func nutRow100g(_ label: String, _ value: Double, _ unit: String, _ color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(.textSecondary)
            Spacer()
            Text(String(format: "%.1f", value)).font(.system(size: 13, weight: .bold)).foregroundColor(color)
            Text("\(unit) / 100g").font(.system(size: 11)).foregroundColor(.textTertiary)
        }.padding(.vertical, 3)
    }

    func liveMacro(_ value: Double, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 1) {
            Text(String(format: "%.0f", value)).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(color)
            Text(label).font(.system(size: 10)).foregroundColor(.textTertiary)
        }.frame(maxWidth: .infinity)
    }
}

// MARK: - Custom Food Sheet
struct CustomFoodSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let mealType: String
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    var body: some View {
        NavigationView {
            ZStack { Color.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        CardView {
                            VStack(spacing: 14) {
                                InputField(label: "Food Name", text: $name, placeholder: "e.g. Homemade Dal Fry")
                                InputField(label: "Calories (kcal)", text: $calories, placeholder: "0", keyboardType: .numberPad)
                                InputField(label: "Protein (g)", text: $protein, placeholder: "0", keyboardType: .decimalPad)
                                InputField(label: "Carbs (g)", text: $carbs, placeholder: "0", keyboardType: .decimalPad)
                                InputField(label: "Fat (g)", text: $fat, placeholder: "0", keyboardType: .decimalPad)
                            }.padding(16)
                        }
                        GradientButton(title: "Add to \(mealType)", action: {
                            guard !name.isEmpty, let cal = Double(calories) else { return }
                            vm.addCustomNutrition(name: name, mealType: mealType, calories: cal,
                                                  protein: Double(protein) ?? 0,
                                                  carbs: Double(carbs) ?? 0,
                                                  fat: Double(fat) ?? 0)
                            dismiss()
                        }, icon: "plus.circle.fill")
                    }.padding(16)
                }
            }
            .navigationTitle("Custom Food").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundColor(.textSecondary) } }
        }
    }
}
