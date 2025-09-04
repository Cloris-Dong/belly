//
//  FridgeModels.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation
import SwiftUI

// MARK: - Removal Reasons

/// Removal reasons for analytics and tracking
enum RemovalReason: String, CaseIterable, Identifiable {
    case consumed = "Used it up"
    case wasted = "Had to toss it"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .consumed: return "checkmark.circle.fill"
        case .wasted: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .consumed: return .sageGreen
        case .wasted: return .softCoral
        }
    }
}

// MARK: - Item Updates

/// Structure for item updates
struct ItemUpdate {
    let name: String?
    let category: FoodCategory?
    let quantity: Double?
    let unit: FoodUnit?
    let expirationDate: Date?
    let zoneTag: String?
    let storage: String?
    
    init(
        name: String? = nil,
        category: FoodCategory? = nil,
        quantity: Double? = nil,
        unit: FoodUnit? = nil,
        expirationDate: Date? = nil,
        zoneTag: String? = nil,
        storage: String? = nil
    ) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.expirationDate = expirationDate
        self.zoneTag = zoneTag
        self.storage = storage
    }
}

// MARK: - Filter Options

/// Filter options for fridge items
enum FridgeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case expiring = "Expiring"
    case expired = "Expired"
    case fresh = "Fresh"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
    
    var sfSymbol: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .expiring: return "clock.badge.exclamationmark"
        case .expired: return "exclamationmark.triangle"
        case .fresh: return "checkmark.circle"
        }
    }
}

// MARK: - Mock Data Types

/// Mock data types for testing different states
enum MockDataType: String, CaseIterable {
    case comprehensive = "Comprehensive"
    case minimal = "Minimal"
    case fresh = "Fresh Only"
    case empty = "Empty"
}


