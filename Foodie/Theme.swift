import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static let ink = Color(hex: 0x1B1814)
    static let coral = Color(hex: 0xE8442E)
    static let lime = Color(hex: 0xC8F169)
    static let blush = Color(hex: 0xFFE9DF)
    static let amber = Color(hex: 0xF5A623)

    static let paper = Color(hex: 0xFAF6F0)
    static let card = Color.white
    static let stroke = Color(hex: 0xEBE4DA)
    static let muted = Color(hex: 0x8C857B)
    static let textMain = Color(hex: 0x1E1B16)
}
