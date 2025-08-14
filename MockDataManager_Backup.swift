//
//  MockDataManager.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation
import CoreData

/// Manages creation of mock data for testing and development
class MockDataManager {
    
    static let shared = MockDataManager()
    
    private init() {}
    
    // MARK: - Main Mock Data Creation
    
    /// Create comprehensive mock data for testing
    func createMockData(in context: NSManagedObjectContext) {
        // Clear existing data first
        clearAllData(in: context)
        
        // Create food items
        createMockFoodItems(in: context)
        
        // Create grocery items
        createMockGroceryItems(in: context)
        
        // Save the context
        do {
            try context.save()
            print("✅ Mock data created successfully")
        } catch {
            print("❌ Error creating mock data: \(error)")
        }
    }
    
    // MARK: - Food Items Mock Data
    
    private func createMockFoodItems(in context: NSManagedObjectContext) {
        let mockFoodItems = [
            // Fresh Items
            MockFoodItem(
                name: "Fresh Apples",
                category: .fruits,
                quantity: 6.0,
                unit: .pieces,
                daysFromNow: 8,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Organic Spinach",
                category: .vegetables,
                quantity: 1.0,
                unit: .packages,
                daysFromNow: 5,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Greek Yogurt",
                category: .dairy,
                quantity: 2.0,
                unit: .cartons,
                daysFromNow: 10,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Whole Wheat Bread",
                category: .pantry,
                quantity: 1.0,
                unit: .packages,
                daysFromNow: 6,
                storage: "Pantry"
            ),
            MockFoodItem(
                name: "Orange Juice",
                category: .beverages,
                quantity: 1.0,
                unit: .cartons,
                daysFromNow: 7,
                storage: "Refrigerator"
            ),
            
            // Expiring Soon Items
            MockFoodItem(
                name: "Milk",
                category: .dairy,
                quantity: 1.0,
                unit: .cartons,
                daysFromNow: 2,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Chicken Breast",
                category: .meat,
                quantity: 0.5,
                unit: .kilograms,
                daysFromNow: 1,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Bananas",
                category: .fruits,
                quantity: 5.0,
                unit: .pieces,
                daysFromNow: 3,
                storage: "Counter"
            ),
            
            // Expired Items
            MockFoodItem(
                name: "Leftover Pizza",
                category: .leftovers,
                quantity: 3.0,
                unit: .pieces,
                daysFromNow: -1,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Expired Yogurt",
                category: .dairy,
                quantity: 1.0,
                unit: .cartons,
                daysFromNow: -3,
                storage: "Refrigerator"
            ),
            
            // Frozen Items
            MockFoodItem(
                name: "Frozen Vegetables",
                category: .frozen,
                quantity: 2.0,
                unit: .packages,
                daysFromNow: 90,
                storage: "Freezer"
            ),
            MockFoodItem(
                name: "Ice Cream",
                category: .frozen,
                quantity: 1.0,
                unit: .cartons,
                daysFromNow: 60,
                storage: "Freezer"
            ),
            
            // Condiments & Pantry
            MockFoodItem(
                name: "Ketchup",
                category: .condiments,
                quantity: 1.0,
                unit: .bottles,
                daysFromNow: 120,
                storage: "Refrigerator"
            ),
            MockFoodItem(
                name: "Pasta",
                category: .pantry,
                quantity: 2.0,
                unit: .packages,
                daysFromNow: 365,
                storage: "Pantry"
            ),
            MockFoodItem(
                name: "Olive Oil",
                category: .condiments,
                quantity: 1.0,
                unit: .bottles,
                daysFromNow: 180,
                storage: "Pantry"
            )
        ]
        
        for mockItem in mockFoodItems {
            let expirationDate = Calendar.current.date(
                byAdding: .day,
                value: mockItem.daysFromNow,
                to: Date()
            ) ?? Date()
            
            _ = FoodItem.create(
                in: context,
                name: mockItem.name,
                category: mockItem.category,
                quantity: mockItem.quantity,
                unit: mockItem.unit,
                expirationDate: expirationDate,
                storage: mockItem.storage
            )
        }
        
        print("📦 Created \(mockFoodItems.count) mock food items")
    }
    
    // MARK: - Grocery Items Mock Data
    
    private func createMockGroceryItems(in context: NSManagedObjectContext) {
        let mockGroceryItems = [
            // Items to buy
            MockGroceryItem(name: "Tomatoes", category: .vegetables, isPurchased: false),
            MockGroceryItem(name: "Ground Beef", category: .meat, isPurchased: false),
            MockGroceryItem(name: "Cheddar Cheese", category: .dairy, isPurchased: false),
            MockGroceryItem(name: "Sandwich Bread", category: .pantry, isPurchased: false),
            MockGroceryItem(name: "Sparkling Water", category: .beverages, isPurchased: false),
            MockGroceryItem(name: "Frozen Berries", category: .frozen, isPurchased: false),
            MockGroceryItem(name: "Mustard", category: .condiments, isPurchased: false),
            MockGroceryItem(name: "Onions", category: .vegetables, isPurchased: false),
            MockGroceryItem(name: "Eggs", category: .dairy, isPurchased: false),
            MockGroceryItem(name: "Rice", category: .pantry, isPurchased: false),
            
            // Already purchased items
            MockGroceryItem(name: "Paper Towels", category: .other, isPurchased: true),
            MockGroceryItem(name: "Dish Soap", category: .other, isPurchased: true),
            MockGroceryItem(name: "Coffee", category: .beverages, isPurchased: true),
            MockGroceryItem(name: "Cereal", category: .pantry, isPurchased: true),
            MockGroceryItem(name: "Butter", category: .dairy, isPurchased: true)
        ]
        
        for mockItem in mockGroceryItems {
            _ = GroceryItem.create(
                in: context,
                name: mockItem.name,
                category: mockItem.category,
                isPurchased: mockItem.isPurchased
            )
        }
        
        print("🛒 Created \(mockGroceryItems.count) mock grocery items")
    }
    
    // MARK: - Quick Test Data
    
    /// Create minimal test data for quick testing
    func createQuickTestData(in context: NSManagedObjectContext) {
        // Create a few food items
        let quickItems = [
            ("Apple", FoodCategory.fruits, 3),
            ("Milk", FoodCategory.dairy, 2),
            ("Bread", FoodCategory.pantry, 5)
        ]
        
        for (name, category, days) in quickItems {
            let expirationDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
            _ = FoodItem.create(
                in: context,
                name: name,
                category: category,
                quantity: 1.0,
                unit: .pieces,
                expirationDate: expirationDate
            )
        }
        
        // Create a few grocery items
        let groceryItems = [
            ("Bananas", FoodCategory.fruits),
            ("Cheese", FoodCategory.dairy),
            ("Pasta", FoodCategory.pantry)
        ]
        
        for (name, category) in groceryItems {
            _ = GroceryItem.create(
                in: context,
                name: name,
                category: category
            )
        }
        
        do {
            try context.save()
            print("✅ Quick test data created")
        } catch {
            print("❌ Error creating quick test data: \(error)")
        }
    }
    
    // MARK: - Data Cleanup
    
    private func clearAllData(in context: NSManagedObjectContext) {
        // Clear food items
        let foodItemFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodItem")
        let foodItemDeleteRequest = NSBatchDeleteRequest(fetchRequest: foodItemFetch)
        
        // Clear grocery items
        let groceryItemFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "GroceryItem")
        let groceryItemDeleteRequest = NSBatchDeleteRequest(fetchRequest: groceryItemFetch)
        
        do {
            try context.execute(foodItemDeleteRequest)
            try context.execute(groceryItemDeleteRequest)
            print("🗑️ Cleared existing data")
        } catch {
            print("❌ Error clearing data: \(error)")
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Check if the database has any data
    func hasData(in context: NSManagedObjectContext) -> Bool {
        let foodItemCount = (try? context.count(for: FoodItem.fetchRequest())) ?? 0
        let groceryItemCount = (try? context.count(for: GroceryItem.fetchRequest())) ?? 0
        
        return foodItemCount > 0 || groceryItemCount > 0
    }
    
    /// Get data counts for debugging
    func getDataCounts(in context: NSManagedObjectContext) -> (foodItems: Int, groceryItems: Int) {
        let foodItemCount = (try? context.count(for: FoodItem.fetchRequest())) ?? 0
        let groceryItemCount = (try? context.count(for: GroceryItem.fetchRequest())) ?? 0
        
        return (foodItemCount, groceryItemCount)
    }
}

// MARK: - Mock Data Structures

private struct MockFoodItem {
    let name: String
    let category: FoodCategory
    let quantity: Double
    let unit: FoodUnit
    let daysFromNow: Int
    let storage: String
}

private struct MockGroceryItem {
    let name: String
    let category: FoodCategory
    let isPurchased: Bool
}

// MARK: - PersistenceController Extension

extension PersistenceController {
    
    /// Create a test instance with mock data
    static let mockData: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        MockDataManager.shared.createMockData(in: controller.viewContext)
        return controller
    }()
    
    /// Create sample data in the shared instance (for development)
    func loadDevelopmentData() {
        if !MockDataManager.shared.hasData(in: viewContext) {
            MockDataManager.shared.createQuickTestData(in: viewContext)
        }
    }
}
