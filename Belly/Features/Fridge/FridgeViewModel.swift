//
//  FridgeViewModel.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation
import SwiftUI
import Combine

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
    
    // MARK: - Data Service
    
    @ObservedObject private var dataService = FridgeDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupDataServiceBinding()
        loadData()
    }
    
    /// Initialize with custom data service (for testing)
    init(dataService: FridgeDataService) {
        self.dataService = dataService
        setupDataServiceBinding()
        loadData()
    }
    
    // MARK: - Private Setup
    
    private func setupDataServiceBinding() {
        // Bind data service properties to published properties
        dataService.$foodItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.foodItems, on: self)
            .store(in: &cancellables)
        
        dataService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    /// Load data from storage
    func loadData() {
        dataService.loadFromStorage()
    }
    
    /// Load demo data for development
    func loadDemoData() {
        dataService.loadDemoData()
    }
    
    /// Load different mock data sets for testing
    func loadMockData(type: MockDataType) {
        switch type {
        case .comprehensive:
            dataService.addItems(MockDataManager.shared.generateMockFoodItems())
        case .minimal:
            dataService.addItems(MockDataManager.shared.generateMinimalMockData())
        case .fresh:
            dataService.addItems(MockDataManager.shared.generateFreshMockData())
        case .empty:
            dataService.clearAllData()
        }
    }
    
    /// Reset with demo data
    func resetWithDemoData() {
        dataService.resetWithDemoData()
    }
    
    // MARK: - Computed Properties
    
    /// Items that have expired, sorted by expiration date (most recently expired first)
    var expiredItems: [FoodItem] {
        dataService.expiredItems
    }
    
    /// Items expiring within 3 days (but not expired), sorted by expiration date
    var expiringItems: [FoodItem] {
        dataService.expiringItems
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
        let freshItems = dataService.freshItems
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
        dataService.totalItemsCount
    }
    
    /// Number of expiring items
    var expiringItemsCount: Int {
        dataService.expiringItemsCount
    }
    
    /// Number of expired items
    var expiredItemsCount: Int {
        dataService.expiredItemsCount
    }
    
    /// Number of fresh items
    var freshItemsCount: Int {
        dataService.freshItemsCount
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
        dataService.loadFromStorage()
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
    
    /// Add a new item to the fridge
    func addItem(_ item: FoodItem) {
        dataService.addItem(item)
    }
    
    /// Add multiple items to the fridge
    func addItems(_ items: [FoodItem]) {
        dataService.addItems(items)
    }
    
    /// Update an existing item
    func updateItem(_ item: FoodItem, with updates: ItemUpdate) {
        dataService.updateItem(item, with: updates)
    }
    
    /// Validate item data
    func validateItemData(_ item: FoodItem) -> Bool {
        return dataService.validateItem(item)
    }
    
    /// Remove a single item
    func removeItem(_ item: FoodItem, reason: RemovalReason) {
        dataService.removeItem(item, reason: reason)
    }
    
    /// Remove multiple items
    func removeItems(_ items: [FoodItem], reason: RemovalReason) {
        dataService.removeItems(items, reason: reason)
        clearSelection()
    }
    
    /// Remove selected items
    func removeSelectedItems(reason: RemovalReason) {
        dataService.removeItems(withIds: selectedItems, reason: reason)
        clearSelection()
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
    
}
