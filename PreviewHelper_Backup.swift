//
//  PreviewHelper.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import CoreData

/// Helper for creating SwiftUI preview contexts that work reliably
struct PreviewHelper {
    
    /// Create a lightweight preview context for SwiftUI previews
    static func createPreviewContext() -> NSManagedObjectContext {
        // Create a simple in-memory container
        let container = NSPersistentContainer(name: "BellyDataModel")
        
        // Configure for in-memory store
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        
        // Load store synchronously for preview
        try? container.loadPersistentStore()
        
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        // Add minimal sample data
        addMinimalSampleData(to: context)
        
        return context
    }
    
    /// Add just enough sample data to make previews meaningful
    private static func addMinimalSampleData(to context: NSManagedObjectContext) {
        // Add a few food items
        let foodItems = [
            ("Preview Apple", FoodCategory.fruits, 2.0, FoodUnit.pieces, 5),
            ("Preview Milk", FoodCategory.dairy, 1.0, FoodUnit.cartons, 2),
            ("Preview Bread", FoodCategory.pantry, 1.0, FoodUnit.packages, -1)
        ]
        
        for (name, category, quantity, unit, daysFromNow) in foodItems {
            let expirationDate = Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
            _ = FoodItem.create(
                in: context,
                name: name,
                category: category,
                quantity: quantity,
                unit: unit,
                expirationDate: expirationDate,
                storage: "Refrigerator"
            )
        }
        
        // Add a few grocery items
        let groceryItems = [
            ("Preview Bananas", FoodCategory.fruits, false),
            ("Preview Yogurt", FoodCategory.dairy, true)
        ]
        
        for (name, category, isPurchased) in groceryItems {
            _ = GroceryItem.create(
                in: context,
                name: name,
                category: category,
                isPurchased: isPurchased
            )
        }
        
        // Save the context
        try? context.save()
    }
}

/// Extension to make persistent container loading synchronous for previews
extension NSPersistentContainer {
    func loadPersistentStore() throws {
        var loadError: Error?
        
        loadPersistentStores { _, error in
            loadError = error
        }
        
        if let error = loadError {
            throw error
        }
    }
}
