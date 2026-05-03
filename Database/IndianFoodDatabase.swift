import Foundation

// MARK: - Indian Food Database
// Nutritional values per 100g unless noted in servingSize
// Sources: ICMR-NIN Nutritive Value of Indian Foods, NIN Food Composition Tables

struct IndianFoodItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: FoodCategory
    let servingSize: String      // e.g. "1 piece", "1 cup (240ml)", "100g"
    let servingGrams: Double     // grams per 1 serving
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
    let region: String?

    // Computed per serving
    var caloriesPerServing: Double { caloriesPer100g * servingGrams / 100 }
    var proteinPerServing: Double  { proteinPer100g  * servingGrams / 100 }
    var carbsPerServing: Double    { carbsPer100g    * servingGrams / 100 }
    var fatPerServing: Double      { fatPer100g      * servingGrams / 100 }
    var fiberPerServing: Double    { fiberPer100g    * servingGrams / 100 }

    init(name: String, category: FoodCategory, servingSize: String, servingGrams: Double,
         cal: Double, protein: Double, carbs: Double, fat: Double, fiber: Double, region: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.servingSize = servingSize
        self.servingGrams = servingGrams
        self.caloriesPer100g = cal
        self.proteinPer100g = protein
        self.carbsPer100g = carbs
        self.fatPer100g = fat
        self.fiberPer100g = fiber
        self.region = region
    }
}

enum FoodCategory: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case breadsRoti = "Breads & Roti"
    case rice = "Rice & Grains"
    case dal = "Dal & Lentils"
    case curry = "Curries & Sabzi"
    case snacks = "Snacks & Chaat"
    case dairy = "Dairy"
    case fruits = "Fruits"
    case drinks = "Drinks & Beverages"
    case sweets = "Sweets & Mithai"
    case streetFood = "Street Food"
    case nonVeg = "Non-Veg"
    case rice_dishes = "Rice Dishes"
    case southIndian = "South Indian"
    case salads = "Salads & Raita"
}

// MARK: - Database
struct IndianFoodDatabase {

    static let allFoods: [IndianFoodItem] = breads + riceGrains + dals + curries + breakfastFoods +
        snacks + dairy + fruits + drinks + sweets + nonVeg + riceDishes + southIndian + salads

    // MARK: Breads & Roti
    static let breads: [IndianFoodItem] = [
        IndianFoodItem(name: "Chapati / Roti (Wheat)", category: .breadsRoti,
                       servingSize: "1 medium roti", servingGrams: 40,
                       cal: 297, protein: 9.7, carbs: 57.8, fat: 3.4, fiber: 3.5),
        IndianFoodItem(name: "Phulka (thin roti)", category: .breadsRoti,
                       servingSize: "1 phulka", servingGrams: 30,
                       cal: 297, protein: 9.7, carbs: 57.8, fat: 3.4, fiber: 3.5),
        IndianFoodItem(name: "Paratha (plain)", category: .breadsRoti,
                       servingSize: "1 paratha", servingGrams: 80,
                       cal: 326, protein: 8.2, carbs: 52.4, fat: 10.5, fiber: 2.8),
        IndianFoodItem(name: "Aloo Paratha", category: .breadsRoti,
                       servingSize: "1 paratha", servingGrams: 120,
                       cal: 263, protein: 6.0, carbs: 41.0, fat: 9.2, fiber: 3.2),
        IndianFoodItem(name: "Naan (tandoor)", category: .breadsRoti,
                       servingSize: "1 naan", servingGrams: 90,
                       cal: 310, protein: 10.2, carbs: 55.0, fat: 6.2, fiber: 2.1),
        IndianFoodItem(name: "Puri", category: .breadsRoti,
                       servingSize: "1 puri", servingGrams: 30,
                       cal: 408, protein: 7.8, carbs: 48.0, fat: 20.6, fiber: 1.8),
        IndianFoodItem(name: "Bhatura", category: .breadsRoti,
                       servingSize: "1 bhatura", servingGrams: 70,
                       cal: 378, protein: 8.5, carbs: 50.2, fat: 15.8, fiber: 1.5),
        IndianFoodItem(name: "Kulcha", category: .breadsRoti,
                       servingSize: "1 kulcha", servingGrams: 80,
                       cal: 285, protein: 8.0, carbs: 51.0, fat: 5.5, fiber: 1.6),
        IndianFoodItem(name: "Missi Roti", category: .breadsRoti,
                       servingSize: "1 roti", servingGrams: 50,
                       cal: 328, protein: 14.5, carbs: 51.0, fat: 7.0, fiber: 5.0),
    ]

    // MARK: Rice & Grains
    static let riceGrains: [IndianFoodItem] = [
        IndianFoodItem(name: "White Rice (cooked)", category: .rice,
                       servingSize: "1 cup cooked", servingGrams: 180,
                       cal: 130, protein: 2.7, carbs: 28.0, fat: 0.3, fiber: 0.4),
        IndianFoodItem(name: "Brown Rice (cooked)", category: .rice,
                       servingSize: "1 cup cooked", servingGrams: 195,
                       cal: 112, protein: 2.6, carbs: 23.5, fat: 0.9, fiber: 1.8),
        IndianFoodItem(name: "Basmati Rice (cooked)", category: .rice,
                       servingSize: "1 cup cooked", servingGrams: 180,
                       cal: 150, protein: 3.5, carbs: 32.4, fat: 0.4, fiber: 0.5),
        IndianFoodItem(name: "Poha (flattened rice, cooked)", category: .rice,
                       servingSize: "1 plate (1.5 cups)", servingGrams: 200,
                       cal: 180, protein: 3.5, carbs: 35.0, fat: 4.5, fiber: 1.2),
        IndianFoodItem(name: "Upma", category: .breakfast,
                       servingSize: "1 plate", servingGrams: 200,
                       cal: 132, protein: 3.8, carbs: 22.5, fat: 3.8, fiber: 2.2),
        IndianFoodItem(name: "Semolina / Suji", category: .rice,
                       servingSize: "100g", servingGrams: 100,
                       cal: 360, protein: 10.8, carbs: 73.3, fat: 1.1, fiber: 2.5),
        IndianFoodItem(name: "Oats (cooked)", category: .rice,
                       servingSize: "1 bowl", servingGrams: 240,
                       cal: 68, protein: 2.4, carbs: 12.0, fat: 1.4, fiber: 1.7),
        IndianFoodItem(name: "Daliya (broken wheat, cooked)", category: .rice,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 83, protein: 2.8, carbs: 18.0, fat: 0.6, fiber: 2.8),
    ]

    // MARK: Dal & Lentils
    static let dals: [IndianFoodItem] = [
        IndianFoodItem(name: "Dal Tadka (yellow moong)", category: .dal,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 70, protein: 4.5, carbs: 10.5, fat: 1.8, fiber: 2.5),
        IndianFoodItem(name: "Dal Makhani", category: .dal,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 145, protein: 7.0, carbs: 16.0, fat: 6.5, fiber: 4.5),
        IndianFoodItem(name: "Masoor Dal (red lentil, cooked)", category: .dal,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 116, protein: 9.0, carbs: 20.0, fat: 0.4, fiber: 7.9),
        IndianFoodItem(name: "Chana Dal", category: .dal,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 164, protein: 10.0, carbs: 27.0, fat: 2.5, fiber: 7.6),
        IndianFoodItem(name: "Urad Dal (cooked)", category: .dal,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 105, protein: 7.0, carbs: 18.0, fat: 0.6, fiber: 3.5),
        IndianFoodItem(name: "Rajma (Kidney beans, cooked)", category: .dal,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 127, protein: 8.7, carbs: 22.8, fat: 0.5, fiber: 6.4),
        IndianFoodItem(name: "Chole / Chickpea curry", category: .dal,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 150, protein: 8.0, carbs: 22.0, fat: 4.5, fiber: 6.0),
        IndianFoodItem(name: "Lobiya / Black-eyed peas (cooked)", category: .dal,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 116, protein: 7.8, carbs: 20.5, fat: 0.5, fiber: 6.6),
    ]

    // MARK: Curries & Sabzi
    static let curries: [IndianFoodItem] = [
        IndianFoodItem(name: "Aloo Gobi (dry)", category: .curry,
                       servingSize: "1 serving", servingGrams: 150,
                       cal: 95, protein: 2.5, carbs: 14.0, fat: 4.0, fiber: 3.2),
        IndianFoodItem(name: "Palak Paneer", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 150, protein: 9.0, carbs: 8.0, fat: 10.0, fiber: 2.5),
        IndianFoodItem(name: "Paneer Butter Masala", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 220, protein: 9.5, carbs: 12.0, fat: 15.5, fiber: 2.0),
        IndianFoodItem(name: "Bhindi Masala (okra)", category: .curry,
                       servingSize: "1 serving", servingGrams: 150,
                       cal: 85, protein: 2.0, carbs: 10.0, fat: 4.5, fiber: 3.5),
        IndianFoodItem(name: "Baingan Bharta (roasted eggplant)", category: .curry,
                       servingSize: "1 serving", servingGrams: 150,
                       cal: 70, protein: 1.8, carbs: 9.5, fat: 3.5, fiber: 3.8),
        IndianFoodItem(name: "Matar Paneer", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 175, protein: 8.5, carbs: 14.0, fat: 10.5, fiber: 3.0),
        IndianFoodItem(name: "Aloo Matar", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 110, protein: 3.5, carbs: 18.0, fat: 3.5, fiber: 3.5),
        IndianFoodItem(name: "Kadai Paneer", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 210, protein: 9.5, carbs: 10.5, fat: 15.0, fiber: 2.0),
        IndianFoodItem(name: "Shahi Paneer", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 250, protein: 9.0, carbs: 14.0, fat: 18.0, fiber: 1.5),
        IndianFoodItem(name: "Saag Aloo", category: .curry,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 100, protein: 3.0, carbs: 14.5, fat: 4.0, fiber: 4.0),
        IndianFoodItem(name: "Lauki Sabzi (bottle gourd)", category: .curry,
                       servingSize: "1 serving", servingGrams: 150,
                       cal: 45, protein: 1.0, carbs: 7.5, fat: 1.5, fiber: 2.5),
    ]

    // MARK: Breakfast Foods
    static let breakfastFoods: [IndianFoodItem] = [
        IndianFoodItem(name: "Idli (plain)", category: .southIndian,
                       servingSize: "2 idlis", servingGrams: 100,
                       cal: 132, protein: 3.4, carbs: 26.5, fat: 0.5, fiber: 1.2),
        IndianFoodItem(name: "Masala Dosa", category: .southIndian,
                       servingSize: "1 dosa", servingGrams: 200,
                       cal: 168, protein: 3.8, carbs: 28.0, fat: 5.5, fiber: 2.0),
        IndianFoodItem(name: "Plain Dosa", category: .southIndian,
                       servingSize: "1 dosa", servingGrams: 100,
                       cal: 133, protein: 3.2, carbs: 22.5, fat: 3.8, fiber: 1.0),
        IndianFoodItem(name: "Medu Vada", category: .southIndian,
                       servingSize: "2 vadas", servingGrams: 80,
                       cal: 312, protein: 8.0, carbs: 30.0, fat: 18.0, fiber: 2.5),
        IndianFoodItem(name: "Uttapam (plain)", category: .southIndian,
                       servingSize: "1 uttapam", servingGrams: 120,
                       cal: 145, protein: 3.5, carbs: 24.0, fat: 4.0, fiber: 1.5),
        IndianFoodItem(name: "Poha (cooked)", category: .breakfast,
                       servingSize: "1 plate", servingGrams: 200,
                       cal: 180, protein: 3.5, carbs: 35.0, fat: 4.5, fiber: 1.2),
        IndianFoodItem(name: "Upma (semolina)", category: .breakfast,
                       servingSize: "1 plate", servingGrams: 200,
                       cal: 132, protein: 3.8, carbs: 22.5, fat: 3.8, fiber: 2.2),
        IndianFoodItem(name: "Besan Chilla (chickpea crepe)", category: .breakfast,
                       servingSize: "2 chillas", servingGrams: 100,
                       cal: 190, protein: 9.5, carbs: 27.0, fat: 5.0, fiber: 4.5),
        IndianFoodItem(name: "Moong Dal Chilla", category: .breakfast,
                       servingSize: "2 chillas", servingGrams: 100,
                       cal: 175, protein: 11.0, carbs: 24.0, fat: 3.5, fiber: 3.8),
        IndianFoodItem(name: "Sabudana Khichdi", category: .breakfast,
                       servingSize: "1 plate", servingGrams: 200,
                       cal: 253, protein: 2.5, carbs: 48.0, fat: 7.0, fiber: 0.8),
        IndianFoodItem(name: "Paratha with Curd", category: .breakfast,
                       servingSize: "2 parathas + 100g curd", servingGrams: 260,
                       cal: 285, protein: 8.5, carbs: 42.0, fat: 9.5, fiber: 2.5),
    ]

    // MARK: Snacks & Chaat
    static let snacks: [IndianFoodItem] = [
        IndianFoodItem(name: "Samosa (potato)", category: .snacks,
                       servingSize: "1 samosa", servingGrams: 80,
                       cal: 262, protein: 3.5, carbs: 30.0, fat: 14.0, fiber: 2.0),
        IndianFoodItem(name: "Pakora (onion/vegetable)", category: .snacks,
                       servingSize: "4-5 pieces", servingGrams: 80,
                       cal: 225, protein: 4.5, carbs: 24.0, fat: 12.5, fiber: 2.5),
        IndianFoodItem(name: "Pani Puri / Gol Gappa", category: .streetFood,
                       servingSize: "6 puris with filling", servingGrams: 100,
                       cal: 175, protein: 2.8, carbs: 26.0, fat: 7.0, fiber: 2.0),
        IndianFoodItem(name: "Bhel Puri", category: .streetFood,
                       servingSize: "1 plate", servingGrams: 150,
                       cal: 155, protein: 4.0, carbs: 28.0, fat: 3.5, fiber: 2.5),
        IndianFoodItem(name: "Pav Bhaji", category: .streetFood,
                       servingSize: "2 pav + bhaji", servingGrams: 300,
                       cal: 250, protein: 6.5, carbs: 42.0, fat: 7.5, fiber: 4.5),
        IndianFoodItem(name: "Aloo Tikki", category: .streetFood,
                       servingSize: "2 tikkis", servingGrams: 120,
                       cal: 208, protein: 3.5, carbs: 28.0, fat: 9.5, fiber: 2.8),
        IndianFoodItem(name: "Kachori", category: .snacks,
                       servingSize: "1 kachori", servingGrams: 70,
                       cal: 298, protein: 5.5, carbs: 32.0, fat: 16.5, fiber: 3.5),
        IndianFoodItem(name: "Dhokla (steamed)", category: .snacks,
                       servingSize: "4 pieces", servingGrams: 120,
                       cal: 112, protein: 5.5, carbs: 18.0, fat: 2.0, fiber: 2.2, region: "Gujarat"),
        IndianFoodItem(name: "Chaat (papdi chaat)", category: .streetFood,
                       servingSize: "1 plate", servingGrams: 150,
                       cal: 248, protein: 6.0, carbs: 36.0, fat: 9.5, fiber: 3.0),
        IndianFoodItem(name: "Khakhra", category: .snacks,
                       servingSize: "2 pieces", servingGrams: 30,
                       cal: 350, protein: 9.5, carbs: 60.0, fat: 7.5, fiber: 5.0, region: "Gujarat"),
        IndianFoodItem(name: "Murukku", category: .snacks,
                       servingSize: "5-6 pieces", servingGrams: 30,
                       cal: 450, protein: 6.0, carbs: 58.0, fat: 22.0, fiber: 2.0),
        IndianFoodItem(name: "Roasted Makhana (fox nuts)", category: .snacks,
                       servingSize: "1 cup", servingGrams: 30,
                       cal: 347, protein: 9.7, carbs: 76.9, fat: 0.1, fiber: 14.5),
        IndianFoodItem(name: "Roasted Chana", category: .snacks,
                       servingSize: "1 handful (30g)", servingGrams: 30,
                       cal: 364, protein: 19.3, carbs: 61.0, fat: 5.0, fiber: 17.4),
        IndianFoodItem(name: "Sprouts (mixed, raw)", category: .salads,
                       servingSize: "1 cup", servingGrams: 100,
                       cal: 62, protein: 4.3, carbs: 11.8, fat: 0.4, fiber: 3.6),
    ]

    // MARK: Dairy
    static let dairy: [IndianFoodItem] = [
        IndianFoodItem(name: "Whole Milk (gai ka doodh)", category: .dairy,
                       servingSize: "1 glass (250ml)", servingGrams: 258,
                       cal: 61, protein: 3.2, carbs: 4.8, fat: 3.2, fiber: 0.0),
        IndianFoodItem(name: "Toned Milk (low fat)", category: .dairy,
                       servingSize: "1 glass (250ml)", servingGrams: 258,
                       cal: 47, protein: 3.5, carbs: 4.9, fat: 1.5, fiber: 0.0),
        IndianFoodItem(name: "Curd / Dahi (full fat)", category: .dairy,
                       servingSize: "1 bowl (200g)", servingGrams: 200,
                       cal: 98, protein: 3.3, carbs: 4.7, fat: 6.0, fiber: 0.0),
        IndianFoodItem(name: "Low-fat Dahi", category: .dairy,
                       servingSize: "1 bowl (200g)", servingGrams: 200,
                       cal: 60, protein: 4.0, carbs: 5.5, fat: 1.5, fiber: 0.0),
        IndianFoodItem(name: "Paneer (full fat)", category: .dairy,
                       servingSize: "100g", servingGrams: 100,
                       cal: 265, protein: 18.3, carbs: 1.2, fat: 20.8, fiber: 0.0),
        IndianFoodItem(name: "Low-fat Paneer", category: .dairy,
                       servingSize: "100g", servingGrams: 100,
                       cal: 168, protein: 18.0, carbs: 2.0, fat: 9.5, fiber: 0.0),
        IndianFoodItem(name: "Lassi (sweet, full fat)", category: .drinks,
                       servingSize: "1 glass (300ml)", servingGrams: 310,
                       cal: 127, protein: 3.5, carbs: 20.5, fat: 4.0, fiber: 0.0),
        IndianFoodItem(name: "Buttermilk / Chaas (salted)", category: .drinks,
                       servingSize: "1 glass (250ml)", servingGrams: 255,
                       cal: 40, protein: 1.5, carbs: 4.8, fat: 1.2, fiber: 0.0),
        IndianFoodItem(name: "Ghee", category: .dairy,
                       servingSize: "1 tsp", servingGrams: 5,
                       cal: 898, protein: 0.0, carbs: 0.0, fat: 99.7, fiber: 0.0),
        IndianFoodItem(name: "Khoa / Mawa", category: .dairy,
                       servingSize: "50g", servingGrams: 50,
                       cal: 421, protein: 10.5, carbs: 26.7, fat: 31.2, fiber: 0.0),
        IndianFoodItem(name: "Raita (boondi/cucumber)", category: .salads,
                       servingSize: "1 bowl (150g)", servingGrams: 150,
                       cal: 72, protein: 3.0, carbs: 8.0, fat: 3.0, fiber: 0.8),
    ]

    // MARK: Fruits
    static let fruits: [IndianFoodItem] = [
        IndianFoodItem(name: "Mango (Alphonso/Dashehari)", category: .fruits,
                       servingSize: "1 medium mango", servingGrams: 150,
                       cal: 60, protein: 0.8, carbs: 14.9, fat: 0.4, fiber: 1.6),
        IndianFoodItem(name: "Banana (medium)", category: .fruits,
                       servingSize: "1 banana", servingGrams: 100,
                       cal: 89, protein: 1.1, carbs: 22.8, fat: 0.3, fiber: 2.6),
        IndianFoodItem(name: "Guava (amrood)", category: .fruits,
                       servingSize: "1 medium guava", servingGrams: 150,
                       cal: 68, protein: 2.6, carbs: 14.3, fat: 1.0, fiber: 5.4),
        IndianFoodItem(name: "Papaya", category: .fruits,
                       servingSize: "1 cup cubed (145g)", servingGrams: 145,
                       cal: 43, protein: 0.5, carbs: 10.8, fat: 0.3, fiber: 1.7),
        IndianFoodItem(name: "Apple (Shimla)", category: .fruits,
                       servingSize: "1 medium apple", servingGrams: 150,
                       cal: 52, protein: 0.3, carbs: 13.8, fat: 0.2, fiber: 2.4),
        IndianFoodItem(name: "Pomegranate (anar)", category: .fruits,
                       servingSize: "½ cup arils (87g)", servingGrams: 87,
                       cal: 83, protein: 1.7, carbs: 18.7, fat: 1.2, fiber: 4.0),
        IndianFoodItem(name: "Chikoo / Sapota", category: .fruits,
                       servingSize: "1 medium", servingGrams: 100,
                       cal: 83, protein: 0.4, carbs: 19.9, fat: 1.1, fiber: 5.3),
        IndianFoodItem(name: "Amla (Indian gooseberry)", category: .fruits,
                       servingSize: "2 medium", servingGrams: 50,
                       cal: 44, protein: 0.9, carbs: 10.2, fat: 0.1, fiber: 4.3),
        IndianFoodItem(name: "Watermelon (tarbooj)", category: .fruits,
                       servingSize: "2 cups cubed (280g)", servingGrams: 280,
                       cal: 30, protein: 0.6, carbs: 7.6, fat: 0.2, fiber: 0.4),
    ]

    // MARK: Drinks & Beverages
    static let drinks: [IndianFoodItem] = [
        IndianFoodItem(name: "Masala Chai (with milk & sugar)", category: .drinks,
                       servingSize: "1 cup (150ml)", servingGrams: 155,
                       cal: 55, protein: 1.8, carbs: 8.0, fat: 1.8, fiber: 0.0),
        IndianFoodItem(name: "Filter Coffee (with milk & sugar)", category: .drinks,
                       servingSize: "1 cup (150ml)", servingGrams: 155,
                       cal: 50, protein: 1.5, carbs: 7.5, fat: 1.5, fiber: 0.0),
        IndianFoodItem(name: "Nimbu Pani (lemonade, sweetened)", category: .drinks,
                       servingSize: "1 glass (250ml)", servingGrams: 258,
                       cal: 48, protein: 0.2, carbs: 12.0, fat: 0.0, fiber: 0.1),
        IndianFoodItem(name: "Coconut Water (nariyal pani)", category: .drinks,
                       servingSize: "1 glass (240ml)", servingGrams: 250,
                       cal: 46, protein: 1.8, carbs: 8.9, fat: 0.5, fiber: 2.6),
        IndianFoodItem(name: "Aam Panna", category: .drinks,
                       servingSize: "1 glass (200ml)", servingGrams: 205,
                       cal: 80, protein: 0.5, carbs: 20.0, fat: 0.2, fiber: 0.5),
        IndianFoodItem(name: "Rose Sherbet (rooh afza)", category: .drinks,
                       servingSize: "1 glass (200ml)", servingGrams: 210,
                       cal: 105, protein: 0.1, carbs: 26.5, fat: 0.0, fiber: 0.0),
    ]

    // MARK: Sweets & Mithai
    static let sweets: [IndianFoodItem] = [
        IndianFoodItem(name: "Gulab Jamun", category: .sweets,
                       servingSize: "2 pieces", servingGrams: 80,
                       cal: 387, protein: 4.0, carbs: 55.0, fat: 17.5, fiber: 0.5),
        IndianFoodItem(name: "Rasgulla", category: .sweets,
                       servingSize: "2 pieces", servingGrams: 100,
                       cal: 186, protein: 4.5, carbs: 35.5, fat: 4.0, fiber: 0.0),
        IndianFoodItem(name: "Kheer (rice pudding)", category: .sweets,
                       servingSize: "1 bowl (200g)", servingGrams: 200,
                       cal: 185, protein: 5.5, carbs: 30.5, fat: 5.5, fiber: 0.3),
        IndianFoodItem(name: "Halwa (sooji/semolina)", category: .sweets,
                       servingSize: "1 serving (100g)", servingGrams: 100,
                       cal: 320, protein: 4.0, carbs: 48.0, fat: 13.0, fiber: 1.0),
        IndianFoodItem(name: "Jalebi", category: .sweets,
                       servingSize: "3 pieces", servingGrams: 60,
                       cal: 375, protein: 3.0, carbs: 70.0, fat: 10.0, fiber: 0.5),
        IndianFoodItem(name: "Ladoo (besan)", category: .sweets,
                       servingSize: "1 ladoo", servingGrams: 50,
                       cal: 460, protein: 8.0, carbs: 55.0, fat: 24.0, fiber: 2.5),
        IndianFoodItem(name: "Barfi (plain milk barfi)", category: .sweets,
                       servingSize: "2 pieces", servingGrams: 60,
                       cal: 378, protein: 9.0, carbs: 48.0, fat: 17.0, fiber: 0.0),
    ]

    // MARK: Non-Veg
    static let nonVeg: [IndianFoodItem] = [
        IndianFoodItem(name: "Chicken Curry (with bones)", category: .nonVeg,
                       servingSize: "2 pieces + gravy", servingGrams: 200,
                       cal: 155, protein: 15.0, carbs: 5.0, fat: 9.0, fiber: 1.0),
        IndianFoodItem(name: "Chicken Tikka Masala", category: .nonVeg,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 185, protein: 18.0, carbs: 8.0, fat: 10.0, fiber: 1.5),
        IndianFoodItem(name: "Tandoori Chicken (half)", category: .nonVeg,
                       servingSize: "2 pieces", servingGrams: 150,
                       cal: 180, protein: 24.0, carbs: 3.5, fat: 8.0, fiber: 0.5),
        IndianFoodItem(name: "Mutton Curry", category: .nonVeg,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 205, protein: 16.0, carbs: 5.5, fat: 14.0, fiber: 1.0),
        IndianFoodItem(name: "Egg Bhurji (scrambled egg curry)", category: .nonVeg,
                       servingSize: "2 eggs prepared", servingGrams: 120,
                       cal: 180, protein: 12.0, carbs: 4.5, fat: 13.0, fiber: 0.5),
        IndianFoodItem(name: "Boiled Egg", category: .nonVeg,
                       servingSize: "1 egg", servingGrams: 50,
                       cal: 155, protein: 13.0, carbs: 1.1, fat: 11.0, fiber: 0.0),
        IndianFoodItem(name: "Omelette (2-egg, with onion & tomato)", category: .nonVeg,
                       servingSize: "1 omelette", servingGrams: 120,
                       cal: 185, protein: 13.0, carbs: 3.5, fat: 14.0, fiber: 0.5),
        IndianFoodItem(name: "Fish Curry (Indian style)", category: .nonVeg,
                       servingSize: "1 piece + gravy", servingGrams: 200,
                       cal: 135, protein: 16.5, carbs: 4.5, fat: 6.0, fiber: 1.0),
        IndianFoodItem(name: "Prawn/Shrimp Masala", category: .nonVeg,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 130, protein: 18.0, carbs: 5.0, fat: 5.0, fiber: 1.5),
        IndianFoodItem(name: "Keema Matar (minced meat)", category: .nonVeg,
                       servingSize: "1 bowl", servingGrams: 200,
                       cal: 215, protein: 17.0, carbs: 10.0, fat: 13.0, fiber: 2.5),
    ]

    // MARK: Rice Dishes
    static let riceDishes: [IndianFoodItem] = [
        IndianFoodItem(name: "Biryani (chicken)", category: .rice_dishes,
                       servingSize: "1 plate (350g)", servingGrams: 350,
                       cal: 210, protein: 10.5, carbs: 28.0, fat: 7.5, fiber: 1.5),
        IndianFoodItem(name: "Biryani (mutton)", category: .rice_dishes,
                       servingSize: "1 plate (350g)", servingGrams: 350,
                       cal: 225, protein: 11.0, carbs: 27.0, fat: 9.0, fiber: 1.5),
        IndianFoodItem(name: "Vegetable Biryani", category: .rice_dishes,
                       servingSize: "1 plate (300g)", servingGrams: 300,
                       cal: 175, protein: 4.5, carbs: 32.0, fat: 4.5, fiber: 3.5),
        IndianFoodItem(name: "Jeera Rice", category: .rice_dishes,
                       servingSize: "1 plate (200g)", servingGrams: 200,
                       cal: 148, protein: 3.0, carbs: 29.5, fat: 2.5, fiber: 0.5),
        IndianFoodItem(name: "Khichdi (moong dal rice)", category: .rice_dishes,
                       servingSize: "1 bowl (250g)", servingGrams: 250,
                       cal: 100, protein: 4.5, carbs: 18.0, fat: 2.0, fiber: 2.5),
        IndianFoodItem(name: "Pulao (vegetable)", category: .rice_dishes,
                       servingSize: "1 plate (250g)", servingGrams: 250,
                       cal: 162, protein: 3.5, carbs: 30.0, fat: 3.5, fiber: 2.5),
        IndianFoodItem(name: "Curd Rice (thayir sadam)", category: .rice_dishes,
                       servingSize: "1 bowl (250g)", servingGrams: 250,
                       cal: 110, protein: 3.5, carbs: 20.0, fat: 2.5, fiber: 0.5, region: "South India"),
        IndianFoodItem(name: "Lemon Rice", category: .rice_dishes,
                       servingSize: "1 plate (200g)", servingGrams: 200,
                       cal: 155, protein: 2.8, carbs: 28.0, fat: 4.0, fiber: 1.0),
    ]

    // MARK: South Indian
    static let southIndian: [IndianFoodItem] = [
        IndianFoodItem(name: "Sambhar", category: .southIndian,
                       servingSize: "1 bowl (200ml)", servingGrams: 200,
                       cal: 55, protein: 2.8, carbs: 9.0, fat: 1.5, fiber: 3.0, region: "Tamil Nadu"),
        IndianFoodItem(name: "Coconut Chutney", category: .southIndian,
                       servingSize: "2 tbsp (30g)", servingGrams: 30,
                       cal: 130, protein: 1.5, carbs: 4.5, fat: 12.0, fiber: 2.0),
        IndianFoodItem(name: "Rasam", category: .southIndian,
                       servingSize: "1 cup (200ml)", servingGrams: 200,
                       cal: 30, protein: 1.2, carbs: 5.5, fat: 0.8, fiber: 1.5),
        IndianFoodItem(name: "Pongal (ven pongal)", category: .southIndian,
                       servingSize: "1 plate (250g)", servingGrams: 250,
                       cal: 145, protein: 4.5, carbs: 24.5, fat: 4.0, fiber: 2.0, region: "Tamil Nadu"),
        IndianFoodItem(name: "Pesarattu (moong dosa)", category: .southIndian,
                       servingSize: "2 dosas", servingGrams: 120,
                       cal: 142, protein: 9.0, carbs: 22.0, fat: 2.5, fiber: 4.0, region: "Andhra Pradesh"),
        IndianFoodItem(name: "Appam (Kerala)", category: .southIndian,
                       servingSize: "2 appams", servingGrams: 100,
                       cal: 147, protein: 3.2, carbs: 29.0, fat: 2.5, fiber: 0.8, region: "Kerala"),
        IndianFoodItem(name: "Puttu (Kerala)", category: .southIndian,
                       servingSize: "1 cylinder (100g)", servingGrams: 100,
                       cal: 151, protein: 2.6, carbs: 33.0, fat: 0.5, fiber: 1.2, region: "Kerala"),
        IndianFoodItem(name: "Bisi Bele Bath", category: .southIndian,
                       servingSize: "1 bowl (250g)", servingGrams: 250,
                       cal: 130, protein: 5.0, carbs: 22.0, fat: 3.5, fiber: 3.0, region: "Karnataka"),
    ]

    // MARK: Salads & Raita
    static let salads: [IndianFoodItem] = [
        IndianFoodItem(name: "Kachumber Salad", category: .salads,
                       servingSize: "1 bowl (150g)", servingGrams: 150,
                       cal: 35, protein: 1.5, carbs: 7.0, fat: 0.3, fiber: 2.5),
        IndianFoodItem(name: "Boondi Raita", category: .salads,
                       servingSize: "1 bowl (150g)", servingGrams: 150,
                       cal: 95, protein: 3.5, carbs: 10.0, fat: 4.5, fiber: 0.5),
        IndianFoodItem(name: "Cucumber Raita", category: .salads,
                       servingSize: "1 bowl (150g)", servingGrams: 150,
                       cal: 55, protein: 2.5, carbs: 6.5, fat: 2.0, fiber: 0.8),
        IndianFoodItem(name: "Mixed Sprouts Salad", category: .salads,
                       servingSize: "1 bowl (150g)", servingGrams: 150,
                       cal: 72, protein: 5.5, carbs: 13.5, fat: 0.5, fiber: 4.2),
        IndianFoodItem(name: "Moong Sprouts Chaat", category: .salads,
                       servingSize: "1 bowl (150g)", servingGrams: 150,
                       cal: 98, protein: 6.5, carbs: 16.0, fat: 1.5, fiber: 4.5),
    ]

    // MARK: Search & Filter
    static func search(query: String) -> [IndianFoodItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return allFoods }
        let q = query.lowercased()
        return allFoods.filter {
            $0.name.lowercased().contains(q) ||
            $0.category.rawValue.lowercased().contains(q) ||
            ($0.region?.lowercased().contains(q) ?? false)
        }
    }

    static func byCategory(_ category: FoodCategory) -> [IndianFoodItem] {
        allFoods.filter { $0.category == category }
    }
}
