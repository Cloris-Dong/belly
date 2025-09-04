//
//  Color+Extensions.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

extension Color {
    
    // MARK: - App Color Palette - Cute & Soft
    
    /// Darker pink #E91E63 - Primary action color (more visible)
    static let oceanBlue = Color(hex: "E91E63")
    
    /// Medium pink #F06292 - Secondary action color (good visibility)
    static let softCoral = Color(hex: "F06292")
    
    /// Warm peach #FF8A65 - Warning/attention color (more visible)
    static let warmAmber = Color(hex: "FF8A65")
    
    /// Teal green #4DB6AC - Success/fresh color (better contrast)
    static let sageGreen = Color(hex: "4DB6AC")
    
    // MARK: - Semantic Colors
    
    /// Primary brand color
    static let primary = oceanBlue
    
    /// Success color for fresh items
    static let success = sageGreen
    
    /// Warning color for expiring items
    static let warning = warmAmber
    
    /// Danger color for expired items
    static let danger = softCoral
    
    // MARK: - UI Colors
    
    /// Background color for main views - Soft cream
    static let appBackground = creamWhite
    
    /// Secondary background for cards/sections - Very soft white
    static let cardBackground = Color.white.opacity(0.95)
    
    /// Tertiary background for subtle elements - Soft gray
    static let tertiaryBackground = Color(hex: "F2F2F7").opacity(0.8)
    
    /// Text color for primary content - darker for better visibility
    static let primaryText = darkPink
    
    /// Text color for secondary content - medium pink
    static let secondaryText = mediumPink
    
    /// Text color for tertiary content - softer but still visible
    static let tertiaryText = Color(hex: "8E8E93").opacity(0.8)
    
    /// Border color for UI elements
    static let borderColor = Color(hex: "C6C6C8")
    
    /// Grouped background color
    static let groupedBackground = Color(hex: "F2F2F7")
    
    // MARK: - Form & Dropdown Colors
    
    /// Dropdown text color - dark for visibility
    static let dropdownText = darkPink
    
    /// Dropdown background color - light but visible
    static let dropdownBackground = Color.white
    
    /// Form field text color
    static let formText = darkPink
    
    /// Form field border color
    static let formBorder = mediumPink.opacity(0.6)
    
    // MARK: - Status Colors
    
    /// Fresh food status color - darker for visibility
    static let freshFood = darkTeal
    
    /// Expiring soon food status color - darker for visibility
    static let expiringSoon = darkOrange
    
    /// Expired food status color - darker for visibility
    static let expiredFood = Color(hex: "D32F2F")
    
    /// Purchased grocery item color
    static let purchased = Color(hex: "8E8E93")
    
    // MARK: - Additional Cute Colors
    
    /// Soft yellow #FFE5B4 - Inspired by the cat's body color
    static let softYellow = Color(hex: "FFE5B4")
    
    /// Light blue #B3D9FF - Inspired by the eraser and sprinkles
    static let lightBlue = Color(hex: "B3D9FF")
    
    /// Warm orange #FFD1A3 - Inspired by the second cat's body color
    static let warmOrange = Color(hex: "FFD1A3")
    
    /// Gentle lavender #E6CCFF - Soft accent color
    static let gentleLavender = Color(hex: "E6CCFF")
    
    /// Cream white #FFF8E1 - Soft background color
    static let creamWhite = Color(hex: "FFF8E1")
    
    /// Light sage green #E8F5E8 - Soft background color that complements cream
    static let lightSageGreen = Color(hex: "E8F5E8")
    
    // MARK: - Text & Dropdown Colors
    
    /// Rich chocolate brown for primary text - good visibility
    static let darkPink = Color(hex: "5D4037")
    
    /// Lighter chocolate brown for secondary text
    static let mediumPink = Color(hex: "8D6E63")
    
    /// Dark teal for success text
    static let darkTeal = Color(hex: "00796B")
    
    /// Dark orange for warning text
    static let darkOrange = Color(hex: "E65100")
}

// MARK: - Hex Color Initializer
extension Color {
    
    /// Initialize Color from hex string
    /// - Parameter hex: Hex string (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Food Category Colors
extension Color {
    
    /// Get color for food category
    static func categoryColor(for category: FoodCategory) -> Color {
        switch category {
        case .vegetables:
            return sageGreen
        case .fruits:
            return softCoral
        case .meat:
            return Color(hex: "FF8787") // Light coral
        case .dairy:
            return Color(hex: "74C0FC") // Light blue
        case .beverages:
            return oceanBlue
        case .pantry:
            return warmAmber
        case .frozen:
            return Color(hex: "91A7FF") // Light purple
        case .leftovers:
            return Color(hex: "FFD43B") // Yellow
        case .condiments:
            return Color(hex: "FFA8A8") // Light pink
        case .other:
            return Color(hex: "868E96") // Gray
        }
    }
}

// MARK: - Dynamic Colors
extension Color {
    
    /// Color that adapts to light/dark mode (disabled - app uses light mode only)
    static func adaptive(light: Color, dark: Color) -> Color {
        // Always return light color since dark mode is disabled
        return light
    }
    
    /// Lighter version of the color by increasing brightness
    func lighter(by percentage: Double = 0.2) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newBrightness = min(brightness + (brightness * percentage), 1.0)
        let newColor = UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        
        return Color(newColor)
    }
    
    /// Darker version of the color by decreasing brightness
    func darker(by percentage: Double = 0.2) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newBrightness = max(brightness * (1.0 - percentage), 0.0)
        let newColor = UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        
        return Color(newColor)
    }
    
    /// Create a semi-transparent version of the color
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}
