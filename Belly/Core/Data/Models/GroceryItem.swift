//
//  GroceryItem.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation
import CoreData

@objc(GroceryItem)
public class GroceryItem: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var isPurchased: Bool
    @NSManaged public var category: String
    @NSManaged public var dateAdded: Date
}

// MARK: - Computed Properties
extension GroceryItem {
    
    /// Returns the food category as an enum
    public var foodCategory: FoodCategory {
        get {
            return FoodCategory(rawValue: category) ?? .other
        }
        set {
            category = newValue.rawValue
        }
    }
    
    /// Returns a user-friendly status string
    public var statusText: String {
        return isPurchased ? "Purchased" : "Need to buy"
    }
    
    /// Returns the number of days since the item was added
    public var daysSinceAdded: Int {
        Calendar.current.dateComponents([.day], from: dateAdded, to: Date()).day ?? 0
    }
    
    /// Returns a user-friendly date added string
    public var addedDateText: String {
        let days = daysSinceAdded
        
        if days == 0 {
            return "Added today"
        } else if days == 1 {
            return "Added yesterday"
        } else {
            return "Added \(days) days ago"
        }
    }
}

// MARK: - Core Data Generated accessors
extension GroceryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryItem> {
        return NSFetchRequest<GroceryItem>(entityName: "GroceryItem")
    }
}

// MARK: - Fetch Request Helpers
extension GroceryItem {
    
    /// Fetch all grocery items
    public static func allItemsFetchRequest() -> NSFetchRequest<GroceryItem> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GroceryItem.isPurchased, ascending: true),
            NSSortDescriptor(keyPath: \GroceryItem.dateAdded, ascending: false)
        ]
        return request
    }
    
    /// Fetch unpurchased items only
    public static func unpurchasedFetchRequest() -> NSFetchRequest<GroceryItem> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isPurchased == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GroceryItem.dateAdded, ascending: false)
        ]
        return request
    }
    
    /// Fetch purchased items only
    public static func purchasedFetchRequest() -> NSFetchRequest<GroceryItem> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isPurchased == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GroceryItem.dateAdded, ascending: false)
        ]
        return request
    }
    
    /// Fetch items by category
    public static func itemsByCategory(_ category: FoodCategory) -> NSFetchRequest<GroceryItem> {
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
    
    /// Fetch recently added items (within last 7 days)
    public static func recentlyAddedFetchRequest() -> NSFetchRequest<GroceryItem> {
        let request = fetchRequest()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        request.predicate = NSPredicate(format: "dateAdded >= %@", sevenDaysAgo as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GroceryItem.dateAdded, ascending: false)
        ]
        return request
    }
}

// MARK: - Factory Methods
extension GroceryItem {
    
    /// Create a new GroceryItem with default values
    public static func create(in context: NSManagedObjectContext) -> GroceryItem {
        let item = GroceryItem(context: context)
        item.id = UUID()
        item.dateAdded = Date()
        item.isPurchased = false
        item.category = FoodCategory.other.rawValue
        return item
    }
    
    /// Create a GroceryItem with specific values
    public static func create(
        in context: NSManagedObjectContext,
        name: String,
        category: FoodCategory = .other,
        isPurchased: Bool = false
    ) -> GroceryItem {
        let item = create(in: context)
        item.name = name
        item.foodCategory = category
        item.isPurchased = isPurchased
        return item
    }
}

// MARK: - Instance Methods
extension GroceryItem {
    
    /// Toggle the purchased status
    public func togglePurchased() {
        isPurchased.toggle()
    }
    
    /// Mark the item as purchased
    public func markAsPurchased() {
        isPurchased = true
    }
    
    /// Mark the item as not purchased
    public func markAsNotPurchased() {
        isPurchased = false
    }
    
    /// Check if the item matches a search query
    public func matches(searchQuery: String) -> Bool {
        let query = searchQuery.lowercased()
        return name.lowercased().contains(query) ||
               category.lowercased().contains(query)
    }
    
    /// Convert this grocery item to a food item
    public func convertToFoodItem(
        in context: NSManagedObjectContext,
        quantity: Double = 1.0,
        unit: FoodUnit = .pieces,
        expirationDate: Date,
        storage: String = "Refrigerator"
    ) -> FoodItem {
        let foodItem = FoodItem.create(
            in: context,
            name: name,
            category: foodCategory,
            quantity: quantity,
            unit: unit,
            expirationDate: expirationDate,
            storage: storage
        )
        
        // Mark this grocery item as purchased
        markAsPurchased()
        
        return foodItem
    }
}
