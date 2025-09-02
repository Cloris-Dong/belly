//
//  FridgeViewModel.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation
import SwiftUI

/// ViewModel for managing fridge data and business logic
final class FridgeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedFilter: FridgeFilter = .all
    @Published var isSelectionMode = false
    @Published var selectedItems: Set<UUID> = []
    @Published var isGeneratingRecipes = false
    
    // MARK: - Initialization
    
    init() {
        loadMockData()
    }
    
    // MARK: - Data Loading
    
    /// Load mock data for development
    func loadMockData() {
        isLoading = true
        
        // Simulate brief loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.foodItems = MockDataManager.shared.generateMockFoodItems()
            self?.isLoading = false
        }
    }
    
    /// Load different mock data sets for testing
    func loadMockData(type: MockDataType) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            switch type {
            case .comprehensive:
                self?.foodItems = MockDataManager.shared.generateMockFoodItems()
            case .minimal:
                self?.foodItems = MockDataManager.shared.generateMinimalMockData()
            case .fresh:
                self?.foodItems = MockDataManager.shared.generateFreshMockData()
            case .empty:
                self?.foodItems = MockDataManager.shared.generateEmptyMockData()
            }
            self?.isLoading = false
        }
    }
    
    // MARK: - Computed Properties
    
    /// Items that have expired, sorted by expiration date (most recently expired first)
    var expiredItems: [FoodItem] {
        foodItems
            .filter { $0.isExpired }
            .sorted { $0.expirationDate > $1.expirationDate }
    }
    
    /// Items expiring within 3 days (but not expired), sorted by expiration date
    var expiringItems: [FoodItem] {
        foodItems
            .filter { $0.isExpiringSoon && !$0.isExpired }
            .sorted { $0.expirationDate < $1.expirationDate }
    }
    
    /// Items grouped by category with counts (excludes expired and expiring items)
    var itemsByCategory: [FoodCategory: [FoodItem]] {
        let allCategories = FoodCategory.allCases
        var result: [FoodCategory: [FoodItem]] = [:]
        
        // Initialize all categories with empty arrays
        for category in allCategories {
            result[category] = []
        }
        
        // Group items by category (only fresh items)
        let freshItems = foodItems.filter { !$0.isExpired && !$0.isExpiringSoon }
        for item in freshItems {
            result[item.category, default: []].append(item)
        }
        
        // Sort items within each category by expiration date
        for category in allCategories {
            result[category] = result[category]?.sorted { $0.expirationDate < $1.expirationDate }
        }
        
        return result
    }
    
    /// Categories that have items, sorted by category name
    var categoriesWithItems: [FoodCategory] {
        itemsByCategory
            .filter { !$0.value.isEmpty }
            .keys
            .sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Items filtered by current search and filter
    var filteredItems: [FoodItem] {
        var items = foodItems
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                item.storage.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .expiring:
            items = items.filter { $0.isExpiringSoon }
        case .expired:
            items = items.filter { $0.isExpired }
        case .fresh:
            items = items.filter { !$0.isExpiringSoon && !$0.isExpired }
        }
        
        return items
    }
    
    // MARK: - Statistics
    
    /// Total number of items
    var totalItemsCount: Int {
        foodItems.count
    }
    
    /// Number of expiring items
    var expiringItemsCount: Int {
        expiringItems.count
    }
    
    /// Number of expired items
    var expiredItemsCount: Int {
        foodItems.filter { $0.isExpired }.count
    }
    
    /// Number of fresh items
    var freshItemsCount: Int {
        foodItems.filter { !$0.isExpiringSoon && !$0.isExpired }.count
    }
    
    // MARK: - Helper Methods
    
    /// Get count of items in a specific category
    func itemCount(for category: FoodCategory) -> Int {
        itemsByCategory[category]?.count ?? 0
    }
    
    /// Get items for a specific category
    func items(for category: FoodCategory) -> [FoodItem] {
        itemsByCategory[category] ?? []
    }
    
    /// Refresh data
    func refresh() {
        loadMockData()
    }
    
    /// Clear search
    func clearSearch() {
        searchText = ""
    }
    
    /// Set filter
    func setFilter(_ filter: FridgeFilter) {
        selectedFilter = filter
    }
    
    // MARK: - CRUD Operations
    
    /// Update an existing item
    func updateItem(_ item: FoodItem, with updates: ItemUpdate) {
        guard let index = foodItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        var updatedItem = item
        
        if let name = updates.name { updatedItem.name = name }
        if let category = updates.category { updatedItem.category = category }
        if let quantity = updates.quantity { updatedItem.quantity = quantity }
        if let unit = updates.unit { updatedItem.unit = unit }
        if let expirationDate = updates.expirationDate { updatedItem.expirationDate = expirationDate }
        if let zoneTag = updates.zoneTag { updatedItem.zoneTag = zoneTag }
        if let storage = updates.storage { updatedItem.storage = storage }
        
        foodItems[index] = updatedItem
        saveChanges()
    }
    
    /// Validate item data
    func validateItemData(_ item: FoodItem) -> Bool {
        return !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               item.quantity > 0
    }
    
    /// Remove a single item
    func removeItem(_ item: FoodItem, reason: RemovalReason) {
        foodItems.removeAll { $0.id == item.id }
        saveChanges()
        
        // Here you could track analytics for removal reasons
        print("Item '\(item.name)' removed: \(reason.rawValue)")
    }
    
    /// Remove multiple items
    func removeItems(_ items: [FoodItem], reason: RemovalReason) {
        let itemIds = Set(items.map { $0.id })
        foodItems.removeAll { itemIds.contains($0.id) }
        clearSelection()
        saveChanges()
        
        print("\(items.count) items removed: \(reason.rawValue)")
    }
    
    /// Remove selected items
    func removeSelectedItems(reason: RemovalReason) {
        let itemsToRemove = foodItems.filter { selectedItems.contains($0.id) }
        removeItems(itemsToRemove, reason: reason)
    }
    
    // MARK: - Selection Management
    
    /// Toggle selection for an item
    func toggleSelection(for item: FoodItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
        
        // Exit selection mode if no items selected
        if selectedItems.isEmpty {
            isSelectionMode = false
        }
    }
    
    /// Clear all selections
    func clearSelection() {
        selectedItems.removeAll()
        isSelectionMode = false
    }
    
    /// Select all items
    func selectAll() {
        selectedItems = Set(foodItems.map { $0.id })
    }
    
    /// Enter selection mode
    func enterSelectionMode() {
        isSelectionMode = true
    }
    
    /// Check if item is selected
    func isSelected(_ item: FoodItem) -> Bool {
        return selectedItems.contains(item.id)
    }
    
    /// Get selected items count
    var selectedItemsCount: Int {
        return selectedItems.count
    }
    
    // MARK: - Recipe Generation
    
    /// Generate recipes from expiring items
    func generateRecipes() -> [Recipe] {
        let expiringIngredients = expiringItems.map { $0.name }
        
        // Mock recipe generation - would use AI/API in production
        return RecipeGenerator.generateRecipes(from: expiringIngredients)
    }
    
    /// Start recipe generation process
    func startRecipeGeneration() {
        isGeneratingRecipes = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isGeneratingRecipes = false
        }
    }
    
    // MARK: - Data Persistence
    
    /// Save changes (mock implementation)
    private func saveChanges() {
        // In production, this would save to Core Data
        // For now, changes persist in memory during session
        print("Changes saved to mock data store")
    }
}

// MARK: - Supporting Types

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

/// Mock data types for testing different states
enum MockDataType: String, CaseIterable {
    case comprehensive = "Comprehensive"
    case minimal = "Minimal"
    case fresh = "Fresh Only"
    case empty = "Empty"
}

/// Removal reasons for analytics
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
