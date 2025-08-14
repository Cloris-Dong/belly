//
//  ShoppingViewModel.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

class ShoppingViewModel: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Start with some sample items
        groceryItems = [
            GroceryItem(text: "Milk 2 liters"),
            GroceryItem(text: "5 apples", isPurchased: true),
            GroceryItem(text: "Bread 1 loaf"),
        ]
    }
    
    func addItem(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newItem = GroceryItem(text: trimmed)
        groceryItems.append(newItem)
    }
    
    func updateItem(_ item: GroceryItem, text: String) {
        item.updateFromText(text)
    }
    
    func togglePurchased(_ item: GroceryItem) {
        item.isPurchased.toggle()
    }
    
    func deleteItem(_ item: GroceryItem) {
        groceryItems.removeAll { $0.id == item.id }
    }
    
    func removePurchasedItems(_ itemsToRemove: [GroceryItem]) {
        for item in itemsToRemove {
            groceryItems.removeAll { $0.id == item.id }
        }
    }
    
    // Computed properties for clean separation
    var unpurchasedItems: [GroceryItem] {
        groceryItems.filter { !$0.isPurchased }
    }
    
    var purchasedItems: [GroceryItem] {
        groceryItems.filter { $0.isPurchased }
    }
}

// Update GroceryItem to handle natural language input
class GroceryItem: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var quantity: Double
    @Published var unit: String
    @Published var isPurchased: Bool
    let dateAdded: Date
    
    init(text: String, isPurchased: Bool = false) {
        let parsed = Self.parseItemText(text)
        self.name = parsed.name
        self.quantity = parsed.quantity
        self.unit = parsed.unit
        self.isPurchased = isPurchased
        self.dateAdded = Date()
    }
    
    var displayText: String {
        if quantity == 1.0 && unit == "pieces" {
            return name
        } else if quantity == floor(quantity) {
            return "\(name) \(Int(quantity)) \(unit)"
        } else {
            return "\(name) \(String(format: "%.1f", quantity)) \(unit)"
        }
    }
    
    func updateFromText(_ text: String) {
        let parsed = Self.parseItemText(text)
        self.name = parsed.name
        self.quantity = parsed.quantity
        self.unit = parsed.unit
    }
    
    // Smart parsing of natural language input
    private static func parseItemText(_ text: String) -> (name: String, quantity: Double, unit: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Common patterns: "Milk 2 liters", "5 apples", "Bread 1 loaf"
        let patterns = [
            // "ItemName Quantity Unit" (e.g., "Milk 2 liters")
            #"^(.+?)\s+(\d+(?:\.\d+)?)\s+(kg|g|liters?|bottles?|packs?|loaves?|pieces?)s?$"#,
            // "Quantity Unit ItemName" (e.g., "2 kg chicken")
            #"^(\d+(?:\.\d+)?)\s+(kg|g|liters?|bottles?|packs?|loaves?)\s+(.+)$"#,
            // "Quantity ItemName" (e.g., "5 apples")
            #"^(\d+(?:\.\d+)?)\s+(.+)$"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
                
                if pattern.contains("^(.+?)\\s+") { // Pattern 1: Name Quantity Unit
                    let name = String(trimmed[Range(match.range(at: 1), in: trimmed)!])
                    let quantityStr = String(trimmed[Range(match.range(at: 2), in: trimmed)!])
                    let unit = String(trimmed[Range(match.range(at: 3), in: trimmed)!])
                    
                    return (name, Double(quantityStr) ?? 1.0, unit)
                    
                } else if pattern.contains("^(\\d+") && pattern.contains("(.+)$") { // Pattern 2 & 3
                    let quantityStr = String(trimmed[Range(match.range(at: 1), in: trimmed)!])
                    
                    if match.numberOfRanges == 4 { // Pattern 2: Quantity Unit Name
                        let unit = String(trimmed[Range(match.range(at: 2), in: trimmed)!])
                        let name = String(trimmed[Range(match.range(at: 3), in: trimmed)!])
                        return (name, Double(quantityStr) ?? 1.0, unit)
                    } else { // Pattern 3: Quantity Name
                        let name = String(trimmed[Range(match.range(at: 2), in: trimmed)!])
                        return (name, Double(quantityStr) ?? 1.0, "pieces")
                    }
                }
            }
        }
        
        // Default: treat as simple item name
        return (trimmed, 1.0, "pieces")
    }
}
