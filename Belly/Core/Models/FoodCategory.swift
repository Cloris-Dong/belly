//
//  FoodCategory.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation
import SwiftUI

/// Food categories for organizing items in the fridge
enum FoodCategory: String, CaseIterable, Identifiable, Codable {
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
    
    var id: String { rawValue }
    
    /// Display emoji for each category
    var emoji: String {
        switch self {
        case .vegetables: return "🥬"
        case .fruits: return "🍎"
        case .meat: return "🥩"
        case .dairy: return "🥛"
        case .beverages: return "🥤"
        case .pantry: return "🥫"
        case .frozen: return "🧊"
        case .leftovers: return "🍽️"
        case .condiments: return "🧂"
        case .other: return "📦"
        }
    }
    
    /// SF Symbol for each category
    var sfSymbol: String {
        switch self {
        case .vegetables: return "leaf.fill"
        case .fruits: return "apple.logo"
        case .meat: return "fish.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .beverages: return "wineglass.fill"
        case .pantry: return "archivebox.fill"
        case .frozen: return "snowflake"
        case .leftovers: return "fork.knife"
        case .condiments: return "drop.fill"
        case .other: return "shippingbox.fill"
        }
    }
    
    /// Color for category using app design system
    var color: Color {
        switch self {
        case .vegetables: return .sageGreen
        case .fruits: return .warmAmber
        case .meat: return .softCoral
        case .dairy: return Color(.systemBlue)
        case .beverages: return .oceanBlue
        case .pantry: return Color(.systemBrown)
        case .frozen: return Color(.systemTeal)
        case .leftovers: return Color(.systemOrange)
        case .condiments: return Color(.systemYellow)
        case .other: return Color(.systemGray)
        }
    }
}
