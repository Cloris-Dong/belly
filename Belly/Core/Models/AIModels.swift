//
//  AIModels.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation

// MARK: - Detected Food Model
struct DetectedFood: Identifiable, Codable {
    let id = UUID()
    var name: String
    var category: String
    var shelfLifeDays: Int
    var storage: String
    var location: String // Add explicit location property
    var confidence: Double
    
    // ADD quantity and unit properties
    var quantity: Double = 1.0
    var unit: String = "pieces"
    
    // Stored expiration date that can be modified by DatePicker
    var expirationDate: Date
    
    // MARK: - Initializer
    
    init(name: String, category: String, shelfLifeDays: Int, storage: String = "Refrigerator", location: String = "Middle Shelf", confidence: Double, quantity: Double = 1.0, unit: String = "pieces") {
        self.name = name
        self.category = category
        self.shelfLifeDays = shelfLifeDays
        self.storage = storage
        self.location = location
        self.confidence = confidence
        self.quantity = quantity
        self.unit = unit
        
        // Calculate initial expiration date based on shelf life
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self.expirationDate = calendar.date(byAdding: .day, value: shelfLifeDays, to: today) ?? today
    }
    
    // Computed properties for UI
    var categoryEnum: FoodCategory {
        FoodCategory.allCases.first { $0.rawValue == category } ?? .other
    }
    
    var storageEnum: StorageLocation {
        StorageLocation.allCases.first { $0.rawValue == storage } ?? .refrigerator
    }
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
    
    var confidenceColor: String {
        switch confidence {
        case 0.8...:
            return "High"
        case 0.6..<0.8:
            return "Medium"
        default:
            return "Low"
        }
    }
}

// MARK: - Recipe Model (using existing Recipe struct)
// The Recipe model is already defined in Core/Models/Recipe.swift
// This extension adds AI-specific computed properties
extension Recipe {
    // Computed properties for UI
    var ingredientCount: Int {
        ingredients.count
    }
    
    var stepCount: Int {
        instructions.count
    }
    
    var formattedIngredients: String {
        ingredients.joined(separator: ", ")
    }
}

// MARK: - Storage Location Enum
enum StorageLocation: String, CaseIterable, Codable {
    case refrigerator = "Refrigerator"
    case freezer = "Freezer"
    case pantry = "Pantry"
    case counter = "Counter"
    
    var icon: String {
        switch self {
        case .refrigerator:
            return "thermometer.snowflake"
        case .freezer:
            return "thermometer.snowflake.circle"
        case .pantry:
            return "cabinet"
        case .counter:
            return "table"
        }
    }
    
    var color: String {
        switch self {
        case .refrigerator:
            return "blue"
        case .freezer:
            return "cyan"
        case .pantry:
            return "orange"
        case .counter:
            return "yellow"
        }
    }
}

// MARK: - AI Processing State
enum AIProcessingState {
    case idle
    case processing
    case completed([DetectedFood])
    case failed(String)
    
    var isLoading: Bool {
        if case .processing = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .failed(let message) = self {
            return message
        }
        return nil
    }
    
    var detectedItems: [DetectedFood] {
        if case .completed(let items) = self {
            return items
        }
        return []
    }
}

// MARK: - Error Types for AI Operations
enum AIError: LocalizedError {
    case noItemsDetected
    case networkError
    case processingError
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .noItemsDetected:
            return "No food items could be identified in this image"
        case .networkError:
            return "Network connection error"
        case .processingError:
            return "Error processing image"
        case .invalidImage:
            return "Invalid image format"
        }
    }
}
