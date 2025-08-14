//
//  ShoppingViewModel.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI
import Combine

class ShoppingViewModel: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Start with some sample items
        groceryItems = [
            GroceryItem(name: "Milk", quantity: 2.0, unit: "liters"),
            GroceryItem(name: "Apples", quantity: 5.0, unit: "pieces", isPurchased: true),
            GroceryItem(name: "Bread", quantity: 1.0, unit: "loaf"),
        ]
    }
    
    func addItem(_ name: String, quantity: Double = 1.0, unit: String = "pieces") {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newItem = GroceryItem(name: trimmed, quantity: quantity, unit: unit)
        groceryItems.append(newItem)
    }
    
    func updateItem(_ item: GroceryItem, name: String, quantity: Double, unit: String) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index].name = name
            groceryItems[index].quantity = quantity
            groceryItems[index].unit = unit
            objectWillChange.send()
        }
    }
    
    func togglePurchased(_ item: GroceryItem) {
        // Find the item and update it directly in the array
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index].isPurchased.toggle()
            // Force UI update
            objectWillChange.send()
        }
    }
    
    func deleteItem(_ item: GroceryItem) {
        groceryItems.removeAll { $0.id == item.id }
    }
    
    func removePurchasedItems(_ itemsToRemove: [GroceryItem]) {
        for item in itemsToRemove {
            groceryItems.removeAll { $0.id == item.id }
        }
    }
    
    // Computed properties for sections
    var unpurchasedItems: [GroceryItem] {
        groceryItems.filter { !$0.isPurchased }
    }
    
    var purchasedItems: [GroceryItem] {
        groceryItems.filter { $0.isPurchased }
    }
}

// Updated GroceryItem
struct GroceryItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    var isPurchased: Bool
    let dateAdded: Date
    
    init(name: String, quantity: Double = 1.0, unit: String = "pieces", isPurchased: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isPurchased = isPurchased
        self.dateAdded = Date()
    }
}
