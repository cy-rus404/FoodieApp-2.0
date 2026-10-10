import SwiftUI

let currency = "$"

func money(_ value: Double) -> String {
    currency + String(format: "%.2f", value)
}

enum FoodCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case burgers = "Burgers"
    case pizza = "Pizza"
    case asian = "Asian"
    case african = "African"
    case salads = "Salads"
    case desserts = "Desserts"
    case drinks = "Drinks"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .all: return "🍽️"
        case .burgers: return "🍔"
        case .pizza: return "🍕"
        case .asian: return "🍜"
        case .african: return "🍛"
        case .salads: return "🥗"
        case .desserts: return "🍰"
        case .drinks: return "🥤"
        }
    }
}

struct FoodItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let restaurant: String
    let emoji: String
    let category: FoodCategory
    let price: Double
    let rating: Double
    let minutes: Int
    let kcal: Int
    let tint: UInt32

    var priceText: String { money(price) }
}

struct PromoBanner: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let emoji: String
    let colors: [UInt32]
}

enum MenuData {
    static func item(_ id: Int) -> FoodItem? {
        items.first { $0.id == id }
    }

    static let promos: [PromoBanner] = [
        PromoBanner(title: "Free delivery on your first order", subtitle: "Use code FOODIE", emoji: "🍔", colors: [0xFF5A36, 0xFF8A4C]),
        PromoBanner(title: "Buy 1 pizza, get 1 half off", subtitle: "This weekend only", emoji: "🍕", colors: [0x6A3FD1, 0xB05AE0]),
        PromoBanner(title: "Fresh bowls, 20% off", subtitle: "Healthy never tasted better", emoji: "🥗", colors: [0x2E8B57, 0x7BC47F])
    ]

    static let items: [FoodItem] = [
        FoodItem(id: 1, name: "Smash Burger", restaurant: "Burger Lab", emoji: "🍔", category: .burgers, price: 12.90, rating: 4.8, minutes: 15, kcal: 540, tint: 0xE2572B),
        FoodItem(id: 2, name: "Double Cheese", restaurant: "Burger Lab", emoji: "🍔", category: .burgers, price: 14.50, rating: 4.7, minutes: 18, kcal: 720, tint: 0xD9A441),
        FoodItem(id: 3, name: "Hot Dog Combo", restaurant: "Street Grill", emoji: "🌭", category: .burgers, price: 9.80, rating: 4.5, minutes: 12, kcal: 480, tint: 0xB8561F),
        FoodItem(id: 4, name: "Loaded Fries", restaurant: "Burger Lab", emoji: "🍟", category: .burgers, price: 5.20, rating: 4.6, minutes: 10, kcal: 410, tint: 0xE0A22B),
        FoodItem(id: 5, name: "Margherita", restaurant: "Napoli Oven", emoji: "🍕", category: .pizza, price: 14.50, rating: 4.7, minutes: 20, kcal: 680, tint: 0xD9362B),
        FoodItem(id: 6, name: "Pepperoni Feast", restaurant: "Napoli Oven", emoji: "🍕", category: .pizza, price: 16.90, rating: 4.9, minutes: 22, kcal: 810, tint: 0xC8461F),
        FoodItem(id: 7, name: "Veggie Garden", restaurant: "Napoli Oven", emoji: "🍕", category: .pizza, price: 15.20, rating: 4.4, minutes: 20, kcal: 620, tint: 0x5E9E3A),
        FoodItem(id: 8, name: "Salmon Nigiri", restaurant: "Sakura Sushi", emoji: "🍣", category: .asian, price: 18.00, rating: 4.9, minutes: 25, kcal: 350, tint: 0xE86A5F),
        FoodItem(id: 9, name: "Dragon Roll", restaurant: "Sakura Sushi", emoji: "🍱", category: .asian, price: 21.50, rating: 4.8, minutes: 28, kcal: 520, tint: 0x3F8F9E),
        FoodItem(id: 10, name: "Ramen Bowl", restaurant: "Sakura Sushi", emoji: "🍜", category: .asian, price: 13.90, rating: 4.6, minutes: 18, kcal: 590, tint: 0xD9A441),
        FoodItem(id: 11, name: "Jollof & Chicken", restaurant: "Mama's Kitchen", emoji: "🍛", category: .african, price: 11.50, rating: 4.9, minutes: 20, kcal: 760, tint: 0xE0892B),
        FoodItem(id: 12, name: "Fried Rice Combo", restaurant: "Mama's Kitchen", emoji: "🍚", category: .african, price: 10.80, rating: 4.5, minutes: 18, kcal: 700, tint: 0xC9A227),
        FoodItem(id: 13, name: "Grilled Tilapia", restaurant: "Mama's Kitchen", emoji: "🐟", category: .african, price: 16.00, rating: 4.8, minutes: 30, kcal: 640, tint: 0x2E8B8B),
        FoodItem(id: 14, name: "Kelewele Bites", restaurant: "Mama's Kitchen", emoji: "🍌", category: .african, price: 5.50, rating: 4.7, minutes: 12, kcal: 320, tint: 0xB8861F),
        FoodItem(id: 15, name: "Caesar Salad", restaurant: "Green Bowl", emoji: "🥗", category: .salads, price: 9.90, rating: 4.4, minutes: 10, kcal: 280, tint: 0x4FA84F),
        FoodItem(id: 16, name: "Avocado Bowl", restaurant: "Green Bowl", emoji: "🥑", category: .salads, price: 11.20, rating: 4.6, minutes: 12, kcal: 390, tint: 0x6BAE3D),
        FoodItem(id: 17, name: "Fruit Bowl", restaurant: "Green Bowl", emoji: "🍓", category: .salads, price: 7.40, rating: 4.3, minutes: 8, kcal: 210, tint: 0xD94A6B),
        FoodItem(id: 18, name: "Choco Lava Cake", restaurant: "Sweet Spot", emoji: "🍰", category: .desserts, price: 6.50, rating: 4.9, minutes: 14, kcal: 450, tint: 0x8B4A2B),
        FoodItem(id: 19, name: "Ice Cream Trio", restaurant: "Sweet Spot", emoji: "🍨", category: .desserts, price: 6.90, rating: 4.6, minutes: 10, kcal: 380, tint: 0xE58FB0),
        FoodItem(id: 20, name: "Glazed Donuts", restaurant: "Sweet Spot", emoji: "🍩", category: .desserts, price: 5.80, rating: 4.5, minutes: 10, kcal: 420, tint: 0xE0A24B),
        FoodItem(id: 21, name: "Bubble Tea", restaurant: "Sip Co.", emoji: "🧋", category: .drinks, price: 5.20, rating: 4.7, minutes: 8, kcal: 260, tint: 0xC48A5A),
        FoodItem(id: 22, name: "Berry Smoothie", restaurant: "Sip Co.", emoji: "🥤", category: .drinks, price: 5.90, rating: 4.6, minutes: 8, kcal: 230, tint: 0x9B4FD1)
    ]
}

final class AppStore: ObservableObject {
    @Published private(set) var quantities: [Int: Int] = [:]
    @Published private(set) var favorites: Set<Int> = []

    var count: Int {
        quantities.values.reduce(0, +)
    }

    var total: Double {
        quantities.reduce(0.0) { sum, pair in
            sum + (MenuData.item(pair.key)?.price ?? 0) * Double(pair.value)
        }
    }

    func quantity(of item: FoodItem) -> Int {
        quantities[item.id, default: 0]
    }

    func add(_ item: FoodItem) {
        quantities[item.id, default: 0] += 1
    }
    
    func add(_ item: FoodItem, quantity: Int) {
        quantities[item.id, default: 0] += quantity
    }

    func remove(_ item: FoodItem) {
        guard let q = quantities[item.id] else { return }
        quantities[item.id] = q <= 1 ? nil : q - 1
    }

    func isFavorite(_ item: FoodItem) -> Bool {
        favorites.contains(item.id)
    }

    func toggleFavorite(_ item: FoodItem) {
        if favorites.contains(item.id) {
            favorites.remove(item.id)
        } else {
            favorites.insert(item.id)
        }
    }
    
    @Published private(set) var appliedCode: String?

    private let promoCodes: [String: (percent: Double, freeDelivery: Bool)] = [
        "FOODIE": (0, true),
        "SAVE10": (0.10, false)
    ]

    var lines: [(FoodItem, Int)] {
        quantities
            .compactMap { pair in MenuData.item(pair.key).map { ($0, pair.value) } }
            .sorted { $0.0.id < $1.0.id }
    }

    var discount: Double {
        guard let code = appliedCode, let promo = promoCodes[code] else { return 0 }
        return total * promo.percent
    }

    var deliveryFee: Double {
        if total == 0 { return 0 }
        if let code = appliedCode, promoCodes[code]?.freeDelivery == true { return 0 }
        return 2.50
    }

    var grandTotal: Double {
        total - discount + deliveryFee
    }

    func removeAll(_ item: FoodItem) {
        quantities[item.id] = nil
    }

    func clear() {
        quantities = [:]
        appliedCode = nil
    }

    func applyPromo(_ raw: String) -> Bool {
        let code = raw.trimmingCharacters(in: .whitespaces).uppercased()
        guard promoCodes[code] != nil else { return false }
        appliedCode = code
        return true
    }

    func removePromo() {
        appliedCode = nil
    }
}
