//
//  Color+Extensions.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

extension Color {
    
    // MARK: - App Color Palette
    
    /// Ocean blue #339AF0 - Primary action color
    static let oceanBlue = Color(hex: "339AF0")
    
    /// Soft coral #FF6B6B - Warning/alert color
    static let softCoral = Color(hex: "FF6B6B")
    
    /// Warm amber #FFB84D - Warning/attention color
    static let warmAmber = Color(hex: "FFB84D")
    
    /// Sage green #51CF66 - Success/fresh color
    static let sageGreen = Color(hex: "51CF66")
    
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
    
    /// Background color for main views
    static let appBackground = Color(.systemBackground)
    
    /// Secondary background for cards/sections
    static let cardBackground = Color(.secondarySystemBackground)
    
    /// Tertiary background for subtle elements
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    /// Text color for primary content
    static let primaryText = Color(.label)
    
    /// Text color for secondary content
    static let secondaryText = Color(.secondaryLabel)
    
    /// Text color for tertiary content
    static let tertiaryText = Color(.tertiaryLabel)
    
    /// Border color for UI elements
    static let borderColor = Color(.separator)
    
    /// Grouped background color
    static let groupedBackground = Color(.systemGroupedBackground)
    
    // MARK: - Status Colors
    
    /// Fresh food status color
    static let freshFood = sageGreen
    
    /// Expiring soon food status color
    static let expiringSoon = warmAmber
    
    /// Expired food status color
    static let expiredFood = softCoral
    
    /// Purchased grocery item color
    static let purchased = Color(.systemGray)
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
    
    /// Color that adapts to light/dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
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
