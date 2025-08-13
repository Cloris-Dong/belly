//
//  FoodUnit.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Enum representing different units of measurement for food items
public enum FoodUnit: String, CaseIterable, Identifiable {
    case grams = "g"
    case kilograms = "kg"
    case pieces = "pieces"
    case bottles = "bottles"
    case cartons = "cartons"
    case cans = "cans"
    case packages = "packages"
    
    public var id: String { rawValue }
}

// MARK: - Display Properties
extension FoodUnit {
    
    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .grams:
            return "Grams"
        case .kilograms:
            return "Kilograms"
        case .pieces:
            return "Pieces"
        case .bottles:
            return "Bottles"
        case .cartons:
            return "Cartons"
        case .cans:
            return "Cans"
        case .packages:
            return "Packages"
        }
    }
    
    /// Short abbreviation for the unit
    public var abbreviation: String {
        return rawValue
    }
    
    /// Plural form of the unit
    public var pluralForm: String {
        switch self {
        case .grams:
            return "grams"
        case .kilograms:
            return "kilograms"
        case .pieces:
            return "pieces"
        case .bottles:
            return "bottles"
        case .cartons:
            return "cartons"
        case .cans:
            return "cans"
        case .packages:
            return "packages"
        }
    }
    
    /// Singular form of the unit
    public var singularForm: String {
        switch self {
        case .grams:
            return "gram"
        case .kilograms:
            return "kilogram"
        case .pieces:
            return "piece"
        case .bottles:
            return "bottle"
        case .cartons:
            return "carton"
        case .cans:
            return "can"
        case .packages:
            return "package"
        }
    }
}

// MARK: - Unit Categories
extension FoodUnit {
    
    /// Units that are weight-based
    public static var weightUnits: [FoodUnit] {
        return [.grams, .kilograms]
    }
    
    /// Units that are count-based
    public static var countUnits: [FoodUnit] {
        return [.pieces, .bottles, .cartons, .cans, .packages]
    }
    
    /// Check if this unit is weight-based
    public var isWeightUnit: Bool {
        return Self.weightUnits.contains(self)
    }
    
    /// Check if this unit is count-based
    public var isCountUnit: Bool {
        return Self.countUnits.contains(self)
    }
}

// MARK: - Unit Conversion
extension FoodUnit {
    
    /// Convert value to base unit (grams for weight, pieces for count)
    public func toBaseUnit(_ value: Double) -> Double {
        switch self {
        case .grams:
            return value
        case .kilograms:
            return value * 1000
        case .pieces, .bottles, .cartons, .cans, .packages:
            return value
        }
    }
    
    /// Convert from base unit to this unit
    public func fromBaseUnit(_ value: Double) -> Double {
        switch self {
        case .grams:
            return value
        case .kilograms:
            return value / 1000
        case .pieces, .bottles, .cartons, .cans, .packages:
            return value
        }
    }
    
    /// Get conversion factor to another unit (if compatible)
    public func conversionFactor(to otherUnit: FoodUnit) -> Double? {
        // Only allow conversion within the same category (weight or count)
        if isWeightUnit && otherUnit.isWeightUnit {
            let baseValue = toBaseUnit(1.0)
            return otherUnit.fromBaseUnit(baseValue)
        } else if isCountUnit && otherUnit.isCountUnit {
            // Count units are generally not convertible to each other
            return self == otherUnit ? 1.0 : nil
        }
        return nil
    }
}

// MARK: - Formatting
extension FoodUnit {
    
    /// Format a quantity with this unit
    public func formatQuantity(_ quantity: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = quantity.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
        let quantityString = formatter.string(from: NSNumber(value: quantity)) ?? "\(quantity)"
        
        // Use singular or plural form based on quantity
        let unitString = quantity == 1.0 ? singularForm : pluralForm
        
        return "\(quantityString) \(unitString)"
    }
    
    /// Format a quantity with abbreviation
    public func formatQuantityShort(_ quantity: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = quantity.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
        let quantityString = formatter.string(from: NSNumber(value: quantity)) ?? "\(quantity)"
        
        return "\(quantityString) \(abbreviation)"
    }
}

// MARK: - Recommended Units by Category
extension FoodUnit {
    
    /// Get recommended units for a specific food category
    public static func recommendedUnits(for category: FoodCategory) -> [FoodUnit] {
        switch category {
        case .vegetables:
            return [.pieces, .kilograms, .grams, .packages]
        case .fruits:
            return [.pieces, .kilograms, .grams, .packages]
        case .meat:
            return [.kilograms, .grams, .pieces, .packages]
        case .dairy:
            return [.bottles, .cartons, .packages, .grams, .kilograms]
        case .beverages:
            return [.bottles, .cans, .cartons, .packages]
        case .pantry:
            return [.packages, .cans, .kilograms, .grams, .pieces]
        case .frozen:
            return [.packages, .pieces, .kilograms, .grams]
        case .leftovers:
            return [.pieces, .packages, .grams, .kilograms]
        case .condiments:
            return [.bottles, .packages, .cans, .grams]
        case .other:
            return allCases
        }
    }
    
    /// Get the most common unit for a category
    public static func defaultUnit(for category: FoodCategory) -> FoodUnit {
        return recommendedUnits(for: category).first ?? .pieces
    }
}

// MARK: - Search and Filtering
extension FoodUnit {
    
    /// Find units by partial name match
    public static func findUnits(containing searchText: String) -> [FoodUnit] {
        let lowercaseSearch = searchText.lowercased()
        return allCases.filter { unit in
            unit.rawValue.lowercased().contains(lowercaseSearch) ||
            unit.displayName.lowercased().contains(lowercaseSearch) ||
            unit.singularForm.lowercased().contains(lowercaseSearch) ||
            unit.pluralForm.lowercased().contains(lowercaseSearch)
        }
    }
    
    /// Get unit from string, with fallback to .pieces
    public static func from(string: String) -> FoodUnit {
        return FoodUnit(rawValue: string) ?? .pieces
    }
}
