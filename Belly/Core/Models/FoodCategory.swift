//
//  FoodCategory.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Enum representing different food categories for organization and filtering
public enum FoodCategory: String, CaseIterable, Identifiable {
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case meat = "Meat"
    case dairy = "Dairy"
    case beverages = "Beverages"
    case pantry = "Pantry"
    case frozen = "Frozen"
    case leftovers = "Leftovers"
    case condiments = "Condiments"
    case other = "Other"
    
    public var id: String { rawValue }
}

// MARK: - Display Properties
extension FoodCategory {
    
    /// Human-readable display name
    public var displayName: String {
        return rawValue
    }
    
    /// Emoji icon for the category
    public var emoji: String {
        switch self {
        case .vegetables:
            return "🥕"
        case .fruits:
            return "🍎"
        case .meat:
            return "🥩"
        case .dairy:
            return "🥛"
        case .beverages:
            return "🥤"
        case .pantry:
            return "🏺"
        case .frozen:
            return "🧊"
        case .leftovers:
            return "🍽️"
        case .condiments:
            return "🧂"
        case .other:
            return "📦"
        }
    }
    
    /// SF Symbol name for the category
    public var sfSymbolName: String {
        switch self {
        case .vegetables:
            return "leaf"
        case .fruits:
            return "apple.logo"
        case .meat:
            return "flame"
        case .dairy:
            return "drop"
        case .beverages:
            return "cup.and.saucer"
        case .pantry:
            return "cabinet"
        case .frozen:
            return "snowflake"
        case .leftovers:
            return "fork.knife"
        case .condiments:
            return "drop.triangle"
        case .other:
            return "questionmark.folder"
        }
    }
    
    /// Color hex string for the category
    public var colorHex: String {
        switch self {
        case .vegetables:
            return "#51CF66" // Sage green
        case .fruits:
            return "#FF6B6B" // Soft coral
        case .meat:
            return "#FF8787" // Light coral
        case .dairy:
            return "#74C0FC" // Light blue
        case .beverages:
            return "#339AF0" // Ocean blue
        case .pantry:
            return "#FFB84D" // Warm amber
        case .frozen:
            return "#91A7FF" // Light purple
        case .leftovers:
            return "#FFD43B" // Yellow
        case .condiments:
            return "#FFA8A8" // Light pink
        case .other:
            return "#868E96" // Gray
        }
    }
}

// MARK: - Storage Recommendations
extension FoodCategory {
    
    /// Recommended storage locations for this category
    public var recommendedStorageLocations: [String] {
        switch self {
        case .vegetables:
            return ["Refrigerator", "Pantry", "Counter"]
        case .fruits:
            return ["Refrigerator", "Counter", "Pantry"]
        case .meat:
            return ["Refrigerator", "Freezer"]
        case .dairy:
            return ["Refrigerator"]
        case .beverages:
            return ["Refrigerator", "Pantry", "Counter"]
        case .pantry:
            return ["Pantry", "Cabinet"]
        case .frozen:
            return ["Freezer"]
        case .leftovers:
            return ["Refrigerator", "Freezer"]
        case .condiments:
            return ["Refrigerator", "Pantry", "Cabinet"]
        case .other:
            return ["Refrigerator", "Pantry", "Cabinet", "Counter", "Freezer"]
        }
    }
    
    /// Default storage location for this category
    public var defaultStorage: String {
        return recommendedStorageLocations.first ?? "Refrigerator"
    }
    
    /// Typical shelf life in days for items in this category
    public var typicalShelfLifeDays: Int {
        switch self {
        case .vegetables:
            return 7
        case .fruits:
            return 5
        case .meat:
            return 3
        case .dairy:
            return 7
        case .beverages:
            return 30
        case .pantry:
            return 365
        case .frozen:
            return 90
        case .leftovers:
            return 3
        case .condiments:
            return 180
        case .other:
            return 7
        }
    }
}

// MARK: - Grouping and Sorting
extension FoodCategory {
    
    /// Categories grouped by storage type
    public static var categoriesByStorage: [String: [FoodCategory]] {
        return [
            "Refrigerator": [.vegetables, .fruits, .meat, .dairy, .leftovers, .condiments],
            "Freezer": [.frozen, .meat],
            "Pantry": [.pantry, .beverages, .condiments],
            "Counter": [.fruits, .vegetables]
        ]
    }
    
    /// Categories sorted by frequency of use (most common first)
    public static var sortedByFrequency: [FoodCategory] {
        return [
            .vegetables,
            .fruits,
            .dairy,
            .meat,
            .leftovers,
            .beverages,
            .condiments,
            .pantry,
            .frozen,
            .other
        ]
    }
    
    /// Perishable categories (items that expire quickly)
    public static var perishableCategories: [FoodCategory] {
        return [.vegetables, .fruits, .meat, .dairy, .leftovers]
    }
    
    /// Non-perishable categories (items with long shelf life)
    public static var nonPerishableCategories: [FoodCategory] {
        return [.pantry, .condiments, .frozen]
    }
}

// MARK: - Search and Filtering
extension FoodCategory {
    
    /// Find category by partial name match
    public static func findCategory(containing searchText: String) -> [FoodCategory] {
        let lowercaseSearch = searchText.lowercased()
        return allCases.filter { category in
            category.rawValue.lowercased().contains(lowercaseSearch) ||
            category.emoji.contains(searchText)
        }
    }
    
    /// Get category from string, with fallback to .other
    public static func from(string: String) -> FoodCategory {
        return FoodCategory(rawValue: string) ?? .other
    }
}
