//
//  FoodUnit.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Units for measuring food quantities
enum FoodUnit: String, CaseIterable, Identifiable, Codable {
    case grams = "g"
    case kilograms = "kg"
    case pieces = "pieces"
    case bottles = "bottles"
    case cartons = "cartons"
    case cans = "cans"
    case packages = "packages"
    
    var id: String { rawValue }
    
    /// Display name for the unit
    var displayName: String {
        switch self {
        case .grams: return "grams"
        case .kilograms: return "kg"
        case .pieces: return "pieces"
        case .bottles: return "bottles"
        case .cartons: return "cartons"
        case .cans: return "cans"
        case .packages: return "packages"
        }
    }
    
    /// Abbreviated form for UI display
    var abbreviation: String {
        return rawValue
    }
    
    /// Whether this is a weight-based unit
    var isWeight: Bool {
        switch self {
        case .grams, .kilograms:
            return true
        default:
            return false
        }
    }
    
    /// Whether this is a count-based unit
    var isCount: Bool {
        return !isWeight
    }
}
