//
//  FoodItem.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation
import CoreData

@objc(FoodItem)
public class FoodItem: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String
    @NSManaged public var expirationDate: Date
    @NSManaged public var dateAdded: Date
    @NSManaged public var zoneTag: String?
    @NSManaged public var usageType: String?
    @NSManaged public var dateRemoved: Date?
    @NSManaged public var storage: String
}

// MARK: - Computed Properties
extension FoodItem {
    
    /// Returns true if the item has expired
    public var isExpired: Bool { 
        expirationDate < Date() 
    }
    
    /// Returns the number of days until expiration (negative if expired)
    public var daysUntilExpiration: Int { 
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0 
    }
    
    /// Returns true if the item expires within 3 days
    public var isExpiringSoon: Bool { 
        daysUntilExpiration <= 3 && daysUntilExpiration >= 0 
    }
    
    /// Returns true if the item is fresh (not expired and not expiring soon)
    public var isFresh: Bool {
        return !isExpired && !isExpiringSoon
    }
    
    /// Returns the food category as an enum
    public var foodCategory: FoodCategory {
        get {
            return FoodCategory(rawValue: category) ?? .other
        }
        set {
            category = newValue.rawValue
        }
    }
    
    /// Returns the food unit as an enum
    public var foodUnit: FoodUnit {
        get {
            return FoodUnit(rawValue: unit) ?? .pieces
        }
        set {
            unit = newValue.rawValue
        }
    }
    
    /// Returns a formatted quantity string with unit
    public var formattedQuantity: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = quantity.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
        let quantityString = formatter.string(from: NSNumber(value: quantity)) ?? "\(quantity)"
        return "\(quantityString) \(unit)"
    }
    
    /// Returns the status color based on expiration
    public var statusColor: String {
        if isExpired {
            return "softCoral" // #FF6B6B
        } else if isExpiringSoon {
            return "warmAmber" // #FFB84D
        } else {
            return "sageGreen" // #51CF66
        }
    }
    
    /// Returns days until expiration as a user-friendly string
    public var expirationStatus: String {
        let days = daysUntilExpiration
        
        if days < 0 {
            let expiredDays = abs(days)
            return expiredDays == 1 ? "Expired 1 day ago" : "Expired \(expiredDays) days ago"
        } else if days == 0 {
            return "Expires today"
        } else if days == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(days) days"
        }
    }
}

// MARK: - Core Data Generated accessors
extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }
}

// MARK: - Fetch Request Helpers
extension FoodItem {
    
    /// Fetch all active food items (not removed)
    public static func allItemsFetchRequest() -> NSFetchRequest<FoodItem> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "dateRemoved == nil")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodItem.expirationDate, ascending: true),
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
        return request
    }
    
    /// Fetch items expiring soon (within 3 days)
    public static func expiringSoonFetchRequest() -> NSFetchRequest<FoodItem> {
        let request = fetchRequest()
        let now = Date()
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now
        
        request.predicate = NSPredicate(
            format: "expirationDate <= %@ AND expirationDate >= %@ AND dateRemoved == nil",
            threeDaysFromNow as NSDate,
            now as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodItem.expirationDate, ascending: true)]
        return request
    }
    
    /// Fetch expired items
    public static func expiredFetchRequest() -> NSFetchRequest<FoodItem> {
        let request = fetchRequest()
        let now = Date()
        
        request.predicate = NSPredicate(
            format: "expirationDate < %@ AND dateRemoved == nil",
            now as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodItem.expirationDate, ascending: true)]
        return request
    }
    
    /// Fetch fresh items (not expired and not expiring soon)
    public static func freshFetchRequest() -> NSFetchRequest<FoodItem> {
        let request = fetchRequest()
        let now = Date()
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now
        
        request.predicate = NSPredicate(
            format: "expirationDate > %@ AND dateRemoved == nil",
            threeDaysFromNow as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodItem.expirationDate, ascending: true),
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
        return request
    }
    
    /// Fetch items by category
    public static func itemsByCategory(_ category: FoodCategory) -> NSFetchRequest<FoodItem> {
        let request = allItemsFetchRequest()
        let categoryPredicate = NSPredicate(format: "category == %@", category.rawValue)
        
        if let existingPredicate = request.predicate {
            request.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [existingPredicate, categoryPredicate]
            )
        } else {
            request.predicate = categoryPredicate
        }
        
        return request
    }
    
    /// Fetch items by storage location
    public static func itemsByStorage(_ storage: String) -> NSFetchRequest<FoodItem> {
        let request = allItemsFetchRequest()
        let storagePredicate = NSPredicate(format: "storage == %@", storage)
        
        if let existingPredicate = request.predicate {
            request.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [existingPredicate, storagePredicate]
            )
        } else {
            request.predicate = storagePredicate
        }
        
        return request
    }
}

// MARK: - Factory Methods
extension FoodItem {
    
    /// Create a new FoodItem with default values
    public static func create(in context: NSManagedObjectContext) -> FoodItem {
        let item = FoodItem(context: context)
        item.id = UUID()
        item.dateAdded = Date()
        item.quantity = 1.0
        item.unit = FoodUnit.pieces.rawValue
        item.category = FoodCategory.other.rawValue
        item.storage = "Refrigerator"
        return item
    }
    
    /// Create a FoodItem with specific values
    public static func create(
        in context: NSManagedObjectContext,
        name: String,
        category: FoodCategory,
        quantity: Double = 1.0,
        unit: FoodUnit = .pieces,
        expirationDate: Date,
        storage: String = "Refrigerator",
        zoneTag: String? = nil,
        usageType: String? = nil
    ) -> FoodItem {
        let item = create(in: context)
        item.name = name
        item.foodCategory = category
        item.quantity = quantity
        item.foodUnit = unit
        item.expirationDate = expirationDate
        item.storage = storage
        item.zoneTag = zoneTag
        item.usageType = usageType
        return item
    }
}

// MARK: - Instance Methods
extension FoodItem {
    
    /// Mark the item as removed
    public func markAsRemoved() {
        dateRemoved = Date()
    }
    
    /// Restore a removed item
    public func restore() {
        dateRemoved = nil
    }
    
    /// Update the quantity by a delta amount
    public func updateQuantity(by delta: Double) {
        quantity = max(0, quantity + delta)
    }
    
    /// Check if the item matches a search query
    public func matches(searchQuery: String) -> Bool {
        let query = searchQuery.lowercased()
        return name.lowercased().contains(query) ||
               category.lowercased().contains(query) ||
               storage.lowercased().contains(query) ||
               (zoneTag?.lowercased().contains(query) ?? false)
    }
}
