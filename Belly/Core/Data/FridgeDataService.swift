//
//  FridgeDataService.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation
import SwiftUI
import Combine

/// Service for managing fridge data persistence
/// Uses UserDefaults for now, can be easily upgraded to Core Data later
final class FridgeDataService: ObservableObject {
    
    // MARK: - Shared Instance
    
    /// Shared singleton instance for app-wide data consistency
    static let shared = FridgeDataService()
    
    // MARK: - Published Properties
    
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var lastSyncDate: Date?
    
    // MARK: - Constants
    
    private let userDefaults = UserDefaults.standard
    private let foodItemsKey = "belly_fridge_items"
    private let lastSyncKey = "belly_last_sync"
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {
        loadFromStorage()
    }
    
    /// Public initializer for testing purposes only
    static func createForTesting() -> FridgeDataService {
        return FridgeDataService()
    }
    
    // MARK: - Data Loading
    
    /// Load items from persistent storage
    func loadFromStorage() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Simulate slight delay for loading experience
            Thread.sleep(forTimeInterval: 0.1)
            
            let items = self?.loadItems() ?? []
            let lastSync = self?.userDefaults.object(forKey: self?.lastSyncKey ?? "") as? Date
            
            DispatchQueue.main.async {
                self?.foodItems = items
                self?.lastSyncDate = lastSync
                self?.isLoading = false
            }
        }
    }
    
    /// Load items with specific delay (for testing)
    func loadFromStorage(delay: TimeInterval) {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Thread.sleep(forTimeInterval: delay)
            
            let items = self?.loadItems() ?? []
            let lastSync = self?.userDefaults.object(forKey: self?.lastSyncKey ?? "") as? Date
            
            DispatchQueue.main.async {
                self?.foodItems = items
                self?.lastSyncDate = lastSync
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Add a new item to the fridge
    /// - Parameter item: The food item to add
    func addItem(_ item: FoodItem) {
        foodItems.append(item)
        saveToStorage()
        
        print("✅ Added item to fridge: \(item.name)")
    }
    
    /// Add multiple items to the fridge
    /// - Parameter items: Array of food items to add
    func addItems(_ items: [FoodItem]) {
        foodItems.append(contentsOf: items)
        saveToStorage()
        
        print("✅ Added \(items.count) items to fridge")
    }
    
    /// Update an existing item
    /// - Parameters:
    ///   - item: The original item to update
    ///   - updates: The updates to apply
    func updateItem(_ item: FoodItem, with updates: ItemUpdate) {
        guard let index = foodItems.firstIndex(where: { $0.id == item.id }) else {
            print("⚠️ Item not found for update: \(item.name)")
            return
        }
        
        var updatedItem = item
        
        if let name = updates.name { updatedItem.name = name }
        if let category = updates.category { updatedItem.category = category }
        if let quantity = updates.quantity { updatedItem.quantity = quantity }
        if let unit = updates.unit { updatedItem.unit = unit }
        if let expirationDate = updates.expirationDate { updatedItem.expirationDate = expirationDate }
        if let zoneTag = updates.zoneTag { updatedItem.zoneTag = zoneTag }
        if let storage = updates.storage { updatedItem.storage = storage }
        
        foodItems[index] = updatedItem
        saveToStorage()
        
        print("✅ Updated item: \(updatedItem.name)")
    }
    
    /// Remove a single item
    /// - Parameters:
    ///   - item: The item to remove
    ///   - reason: The reason for removal (for analytics)
    func removeItem(_ item: FoodItem, reason: RemovalReason = .consumed) {
        foodItems.removeAll { $0.id == item.id }
        saveToStorage()
        
        print("✅ Removed item: \(item.name) (reason: \(reason.rawValue))")
        
        // Here you could track analytics for removal reasons
        trackRemovalReason(item: item, reason: reason)
    }
    
    /// Remove multiple items
    /// - Parameters:
    ///   - items: Array of items to remove
    ///   - reason: The reason for removal
    func removeItems(_ items: [FoodItem], reason: RemovalReason = .consumed) {
        let itemIds = Set(items.map { $0.id })
        foodItems.removeAll { itemIds.contains($0.id) }
        saveToStorage()
        
        print("✅ Removed \(items.count) items (reason: \(reason.rawValue))")
        
        // Track analytics for bulk removal
        for item in items {
            trackRemovalReason(item: item, reason: reason)
        }
    }
    
    /// Remove items by IDs
    /// - Parameters:
    ///   - itemIds: Set of item IDs to remove
    ///   - reason: The reason for removal
    func removeItems(withIds itemIds: Set<UUID>, reason: RemovalReason = .consumed) {
        let itemsToRemove = foodItems.filter { itemIds.contains($0.id) }
        removeItems(itemsToRemove, reason: reason)
    }
    
    // MARK: - Data Queries
    
    /// Get items by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of items in the specified category
    func items(for category: FoodCategory) -> [FoodItem] {
        return foodItems.filter { $0.category == category }
    }
    
    /// Get expired items
    var expiredItems: [FoodItem] {
        return foodItems
            .filter { $0.isExpired }
            .sorted { $0.expirationDate > $1.expirationDate }
    }
    
    /// Get items expiring soon (within 3 days)
    var expiringItems: [FoodItem] {
        return foodItems
            .filter { $0.isExpiringSoon && !$0.isExpired }
            .sorted { $0.expirationDate < $1.expirationDate }
    }
    
    /// Get fresh items (not expired and not expiring soon)
    var freshItems: [FoodItem] {
        return foodItems.filter { !$0.isExpired && !$0.isExpiringSoon }
    }
    
    // MARK: - Statistics
    
    var totalItemsCount: Int { foodItems.count }
    var expiredItemsCount: Int { expiredItems.count }
    var expiringItemsCount: Int { expiringItems.count }
    var freshItemsCount: Int { freshItems.count }
    
    // MARK: - Data Validation
    
    /// Validate item data before saving
    /// - Parameter item: The item to validate
    /// - Returns: True if the item is valid
    func validateItem(_ item: FoodItem) -> Bool {
        return !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               item.quantity > 0
    }
    
    // MARK: - Data Migration & Maintenance
    
    /// Remove expired items older than specified days
    /// - Parameter days: Number of days after expiration to keep items
    func cleanupExpiredItems(olderThan days: Int = 7) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let itemsToRemove = foodItems.filter { 
            $0.isExpired && $0.expirationDate < cutoffDate 
        }
        
        if !itemsToRemove.isEmpty {
            removeItems(itemsToRemove, reason: .wasted)
            print("🧹 Cleaned up \(itemsToRemove.count) old expired items")
        }
    }
    
    /// Clear all data (for testing or reset)
    func clearAllData() {
        foodItems.removeAll()
        userDefaults.removeObject(forKey: foodItemsKey)
        userDefaults.removeObject(forKey: lastSyncKey)
        lastSyncDate = nil
        
        print("🗑️ Cleared all fridge data")
    }
    
    // MARK: - Private Methods
    
    /// Load items from UserDefaults
    private func loadItems() -> [FoodItem] {
        guard let data = userDefaults.data(forKey: foodItemsKey) else {
            print("📱 No saved fridge data found, starting fresh")
            return []
        }
        
        do {
            let items = try JSONDecoder().decode([FoodItem].self, from: data)
            print("📱 Loaded \(items.count) items from storage")
            return items
        } catch {
            print("❌ Failed to decode fridge items: \(error)")
            return []
        }
    }
    
    /// Save items to UserDefaults
    private func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(foodItems)
            userDefaults.set(data, forKey: foodItemsKey)
            userDefaults.set(Date(), forKey: lastSyncKey)
            lastSyncDate = Date()
            
            print("💾 Saved \(foodItems.count) items to storage")
        } catch {
            print("❌ Failed to save fridge items: \(error)")
        }
    }
    
    /// Track removal reason for analytics
    private func trackRemovalReason(item: FoodItem, reason: RemovalReason) {
        // In a production app, this would send data to analytics service
        let analytics: [String: Any] = [
            "item_name": item.name,
            "category": item.category.rawValue,
            "removal_reason": reason.rawValue,
            "days_in_fridge": Calendar.current.dateComponents([.day], from: item.dateAdded, to: Date()).day ?? 0
        ]
        
        #if DEBUG
        print("📊 Analytics: \(analytics)")
        #endif
    }
}

// MARK: - Demo Data

extension FridgeDataService {
    /// Load demo data for testing
    func loadDemoData() {
        let demoItems = MockDataManager.shared.generateMockFoodItems()
        addItems(demoItems)
        print("🎯 Loaded demo data with \(demoItems.count) items")
    }
    
    /// Clear data and load demo data
    func resetWithDemoData() {
        clearAllData()
        loadDemoData()
    }
}