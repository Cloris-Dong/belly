//
//  MockDataManager.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Provides comprehensive mock data for development and testing
final class MockDataManager {
    
    /// Shared instance for consistent mock data across the app
    static let shared = MockDataManager()
    
    private init() {}
    
    /// Generate comprehensive mock food items for fridge dashboard
    func generateMockFoodItems() -> [FoodItem] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            // EXPIRED ITEMS (1-2 items)
            FoodItem(
                name: "Greek Yogurt",
                category: .dairy,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: -2, to: today)!,
                zoneTag: "Middle shelf",
                storage: "Refrigerator"
            ),
            
            // EXPIRING TODAY/TOMORROW (3-4 items)
            FoodItem(
                name: "Organic Spinach",
                category: .vegetables,
                quantity: 200,
                unit: .grams,
                expirationDate: calendar.date(byAdding: .day, value: 0, to: today)!,
                zoneTag: "Crisper drawer",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Chicken Breast",
                category: .meat,
                quantity: 0.8,
                unit: .kilograms,
                expirationDate: calendar.date(byAdding: .day, value: 1, to: today)!,
                zoneTag: "Bottom shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Leftover Pizza",
                category: .leftovers,
                quantity: 3,
                unit: .pieces,
                expirationDate: calendar.date(byAdding: .day, value: 1, to: today)!,
                zoneTag: "Top shelf",
                storage: "Refrigerator"
            ),
            
            // EXPIRING SOON (2-3 days)
            FoodItem(
                name: "Fresh Blueberries",
                category: .fruits,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                zoneTag: "Crisper drawer",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Whole Milk",
                category: .dairy,
                quantity: 1,
                unit: .cartons,
                expirationDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                zoneTag: "Door shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Sourdough Bread",
                category: .pantry,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                zoneTag: "Counter",
                storage: "Pantry"
            ),
            
            // FRESH ITEMS (4+ days)
            FoodItem(
                name: "Red Bell Peppers",
                category: .vegetables,
                quantity: 3,
                unit: .pieces,
                expirationDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                zoneTag: "Crisper drawer",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Honeycrisp Apples",
                category: .fruits,
                quantity: 6,
                unit: .pieces,
                expirationDate: calendar.date(byAdding: .day, value: 7, to: today)!,
                zoneTag: "Crisper drawer",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Sharp Cheddar Cheese",
                category: .dairy,
                quantity: 300,
                unit: .grams,
                expirationDate: calendar.date(byAdding: .day, value: 14, to: today)!,
                zoneTag: "Middle shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Ground Turkey",
                category: .meat,
                quantity: 0.5,
                unit: .kilograms,
                expirationDate: calendar.date(byAdding: .day, value: 4, to: today)!,
                zoneTag: "Bottom shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Orange Juice",
                category: .beverages,
                quantity: 1,
                unit: .cartons,
                expirationDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                zoneTag: "Door shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Canned Tomatoes",
                category: .pantry,
                quantity: 2,
                unit: .cans,
                expirationDate: calendar.date(byAdding: .month, value: 18, to: today)!,
                zoneTag: "Pantry shelf",
                storage: "Pantry"
            ),
            
            FoodItem(
                name: "Frozen Peas",
                category: .frozen,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .month, value: 6, to: today)!,
                zoneTag: "Freezer drawer",
                storage: "Freezer"
            ),
            
            FoodItem(
                name: "Dijon Mustard",
                category: .condiments,
                quantity: 1,
                unit: .bottles,
                expirationDate: calendar.date(byAdding: .month, value: 12, to: today)!,
                zoneTag: "Door shelf",
                storage: "Refrigerator"
            ),
            
            // ADDITIONAL VARIETY
            FoodItem(
                name: "Baby Carrots",
                category: .vegetables,
                quantity: 500,
                unit: .grams,
                expirationDate: calendar.date(byAdding: .day, value: 8, to: today)!,
                zoneTag: "Crisper drawer",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Bananas",
                category: .fruits,
                quantity: 5,
                unit: .pieces,
                expirationDate: calendar.date(byAdding: .day, value: 4, to: today)!,
                zoneTag: "Counter",
                storage: "Counter"
            ),
            
            FoodItem(
                name: "Salmon Fillets",
                category: .meat,
                quantity: 2,
                unit: .pieces,
                expirationDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                zoneTag: "Bottom shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Cream Cheese",
                category: .dairy,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: 12, to: today)!,
                zoneTag: "Middle shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Sparkling Water",
                category: .beverages,
                quantity: 6,
                unit: .bottles,
                expirationDate: calendar.date(byAdding: .month, value: 6, to: today)!,
                zoneTag: "Bottom shelf",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Pasta Sauce",
                category: .pantry,
                quantity: 1,
                unit: .bottles,
                expirationDate: calendar.date(byAdding: .month, value: 8, to: today)!,
                zoneTag: "Pantry shelf",
                storage: "Pantry"
            ),
            
            FoodItem(
                name: "Ice Cream",
                category: .frozen,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .month, value: 3, to: today)!,
                zoneTag: "Freezer top",
                storage: "Freezer"
            ),
            
            FoodItem(
                name: "Olive Oil",
                category: .condiments,
                quantity: 1,
                unit: .bottles,
                expirationDate: calendar.date(byAdding: .year, value: 2, to: today)!,
                zoneTag: "Pantry shelf",
                storage: "Pantry"
            ),
            
            FoodItem(
                name: "Mixed Greens",
                category: .vegetables,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: 6, to: today)!,
                zoneTag: "Crisper drawer",
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Strawberries",
                category: .fruits,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                zoneTag: "Top shelf",
                storage: "Refrigerator"
            )
        ]
    }
    
    /// Generate minimal mock data for testing
    func generateMinimalMockData() -> [FoodItem] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            FoodItem(
                name: "Test Apple",
                category: .fruits,
                quantity: 1,
                unit: .pieces,
                expirationDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Test Milk",
                category: .dairy,
                quantity: 1,
                unit: .cartons,
                expirationDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                storage: "Refrigerator"
            )
        ]
    }
    
    /// Generate mock data with no expiring items (for empty state testing)
    func generateFreshMockData() -> [FoodItem] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            FoodItem(
                name: "Fresh Vegetables",
                category: .vegetables,
                quantity: 1,
                unit: .packages,
                expirationDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                storage: "Refrigerator"
            ),
            
            FoodItem(
                name: "Long-life Milk",
                category: .dairy,
                quantity: 1,
                unit: .cartons,
                expirationDate: calendar.date(byAdding: .month, value: 1, to: today)!,
                storage: "Pantry"
            )
        ]
    }
    
    /// Generate empty mock data (for empty state testing)
    func generateEmptyMockData() -> [FoodItem] {
        return []
    }
}
