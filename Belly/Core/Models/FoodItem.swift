//
//  FoodItem.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Mock FoodItem model for development (will be replaced with Core Data entity)
struct FoodItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var category: FoodCategory
    var quantity: Double
    var unit: FoodUnit
    var expirationDate: Date
    var dateAdded: Date
    var zoneTag: String?
    var storage: String
    
    init(
        name: String,
        category: FoodCategory,
        quantity: Double,
        unit: FoodUnit,
        expirationDate: Date,
        dateAdded: Date = Date(),
        zoneTag: String? = nil,
        storage: String = "Refrigerator"
    ) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.expirationDate = expirationDate
        self.dateAdded = dateAdded
        self.zoneTag = zoneTag
        self.storage = storage
    }
}

// MARK: - Computed Properties
extension FoodItem {
    
    /// Returns true if the item has expired
    var isExpired: Bool {
        expirationDate < Date()
    }
    
    /// Returns the number of days until expiration (negative if expired)
    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }
    
    /// Returns true if the item is expiring soon (within 3 days)
    var isExpiringSoon: Bool {
        daysUntilExpiration <= 3 && daysUntilExpiration >= 0
    }
    
    /// Human-readable expiration status
    var expirationStatus: String {
        if isExpired {
            let daysExpired = abs(daysUntilExpiration)
            return daysExpired == 1 ? "Expired 1 day ago" : "Expired \(daysExpired) days ago"
        } else if daysUntilExpiration == 0 {
            return "Expires today"
        } else if daysUntilExpiration == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(daysUntilExpiration) days"
        }
    }
    
    /// Formatted quantity display
    var quantityDisplay: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit.abbreviation)"
        } else {
            return String(format: "%.1f \(unit.abbreviation)", quantity)
        }
    }
}
