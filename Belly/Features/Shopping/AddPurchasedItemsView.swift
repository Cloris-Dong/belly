//
//  AddPurchasedItemsView.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct AddPurchasedItemsView: View {
    let purchasedItems: [GroceryItem]
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingCamera = false
    @State private var showingManualEntry = false
    @StateObject private var fridgeViewModel = FridgeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add \(purchasedItems.count) purchased items to your fridge")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Show purchased items list
                List {
                    ForEach(purchasedItems) { item in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("\(item.name) \(item.quantity, specifier: "%.0f") \(item.unit)")
                            Spacer()
                        }
                    }
                }
                .frame(maxHeight: 200)
                
                VStack(spacing: 12) {
                    Button("Take Photo to Identify") {
                        showingCamera = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("Add Manually") {
                        // Navigate to manual entry for each item
                        addManually()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("Skip for Now") {
                        onComplete()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Add to Fridge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            // Integrate with existing camera flow
            AddItemView()
        }
        .sheet(isPresented: $showingManualEntry) {
            // Show manual entry for purchased items
            ManualEntryForPurchasedView(purchasedItems: purchasedItems) {
                onComplete()
                dismiss()
            }
        }
    }
    
    private func addManually() {
        showingManualEntry = true
    }
}

// Manual entry view specifically for purchased items
struct ManualEntryForPurchasedView: View {
    let purchasedItems: [GroceryItem]
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var fridgeViewModel = FridgeViewModel()
    @State private var currentItemIndex = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if currentItemIndex < purchasedItems.count {
                    let item = purchasedItems[currentItemIndex]
                    
                    VStack(spacing: 16) {
                        Text("Add to Fridge")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Item \(currentItemIndex + 1) of \(purchasedItems.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("\(item.name) \(item.quantity, specifier: "%.0f") \(item.unit)")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Quick add button
                        Button("Add to Fridge") {
                            addItemToFridge(item)
                            nextItem()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        // Skip button
                        Button("Skip") {
                            nextItem()
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    // All items processed
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.green)
                        
                        Text("All items processed!")
                            .font(.headline)
                        
                        Text("Your purchased items have been added to the fridge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Done") {
                            onComplete()
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addItemToFridge(_ groceryItem: GroceryItem) {
        // Smart category detection based on item name
        let detectedCategory = detectCategoryFromName(groceryItem.name)
        
        // Convert GroceryItem to FoodItem and add to fridge
        let foodItem = FoodItem(
            name: groceryItem.name,
            category: detectedCategory,
            quantity: groceryItem.quantity,
            unit: FoodUnit.allCases.first { $0.rawValue == groceryItem.unit } ?? .pieces,
            expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            dateAdded: Date(),
            zoneTag: "Shopping List",
            storage: "Refrigerator"
        )
        
        // Add to fridge view model
        fridgeViewModel.foodItems.append(foodItem)
        
        print("🎯 Auto-selected category: \(detectedCategory.rawValue) for shopping item: \(groceryItem.name)")
        print("Added to fridge: \(groceryItem.name) \(groceryItem.quantity) \(groceryItem.unit)")
    }
    
    // MARK: - Smart Category Detection
    
    private func detectCategoryFromName(_ name: String) -> FoodCategory {
        let itemName = name.lowercased()
        
        // Dairy products
        if itemName.contains("milk") || itemName.contains("yogurt") || itemName.contains("cheese") || 
           itemName.contains("butter") || itemName.contains("cream") || itemName.contains("sour cream") ||
           itemName.contains("cottage") || itemName.contains("mozzarella") || itemName.contains("cheddar") ||
           itemName.contains("feta") || itemName.contains("parmesan") || itemName.contains("ricotta") {
            return .dairy
        }
        // Fruits
        else if itemName.contains("apple") || itemName.contains("banana") || itemName.contains("fruit") ||
                itemName.contains("orange") || itemName.contains("lemon") || itemName.contains("lime") ||
                itemName.contains("grape") || itemName.contains("strawberry") || itemName.contains("blueberry") ||
                itemName.contains("raspberry") || itemName.contains("peach") || itemName.contains("pear") ||
                itemName.contains("plum") || itemName.contains("cherry") || itemName.contains("kiwi") ||
                itemName.contains("mango") || itemName.contains("pineapple") || itemName.contains("avocado") {
            return .fruits
        }
        // Vegetables
        else if itemName.contains("lettuce") || itemName.contains("spinach") || itemName.contains("vegetable") ||
                itemName.contains("carrot") || itemName.contains("celery") || itemName.contains("onion") ||
                itemName.contains("garlic") || itemName.contains("tomato") || itemName.contains("cucumber") ||
                itemName.contains("pepper") || itemName.contains("broccoli") || itemName.contains("cauliflower") ||
                itemName.contains("cabbage") || itemName.contains("potato") || itemName.contains("sweet potato") ||
                itemName.contains("mushroom") || itemName.contains("zucchini") || itemName.contains("eggplant") ||
                itemName.contains("asparagus") || itemName.contains("green bean") || itemName.contains("corn") {
            return .vegetables
        }
        // Meat
        else if itemName.contains("chicken") || itemName.contains("beef") || itemName.contains("pork") ||
                itemName.contains("lamb") || itemName.contains("turkey") || itemName.contains("ham") ||
                itemName.contains("bacon") || itemName.contains("sausage") || itemName.contains("fish") ||
                itemName.contains("salmon") || itemName.contains("tuna") || itemName.contains("shrimp") ||
                itemName.contains("crab") || itemName.contains("lobster") || itemName.contains("meat") {
            return .meat
        }
        // Beverages
        else if itemName.contains("juice") || itemName.contains("soda") || itemName.contains("water") ||
                itemName.contains("beer") || itemName.contains("wine") || itemName.contains("coffee") ||
                itemName.contains("tea") || itemName.contains("smoothie") || itemName.contains("energy drink") ||
                itemName.contains("sports drink") || itemName.contains("coconut water") {
            return .beverages
        }
        // Pantry items
        else if itemName.contains("bread") || itemName.contains("cereal") || itemName.contains("pasta") ||
                itemName.contains("rice") || itemName.contains("flour") || itemName.contains("sugar") ||
                itemName.contains("salt") || itemName.contains("pepper") || itemName.contains("spice") ||
                itemName.contains("herb") || itemName.contains("oil") || itemName.contains("vinegar") ||
                itemName.contains("sauce") || itemName.contains("soup") || itemName.contains("canned") ||
                itemName.contains("jar") || itemName.contains("box") || itemName.contains("bag") {
            return .pantry
        }
        // Frozen items
        else if itemName.contains("frozen") || itemName.contains("ice cream") || itemName.contains("frozen") ||
                itemName.contains("frozen fruit") || itemName.contains("frozen vegetable") ||
                itemName.contains("frozen meal") || itemName.contains("frozen pizza") {
            return .frozen
        }
        // Leftovers
        else if itemName.contains("leftover") || itemName.contains("cooked") || itemName.contains("prepared") ||
                itemName.contains("meal") || itemName.contains("dinner") || itemName.contains("lunch") {
            return .leftovers
        }
        // Condiments
        else if itemName.contains("ketchup") || itemName.contains("mustard") || itemName.contains("mayo") ||
                itemName.contains("mayonnaise") || itemName.contains("relish") || itemName.contains("pickle") ||
                itemName.contains("jam") || itemName.contains("jelly") || itemName.contains("honey") ||
                itemName.contains("syrup") || itemName.contains("dressing") || itemName.contains("salsa") {
            return .condiments
        }
        // Default fallback
        else {
            return .other
        }
    }
    
    private func nextItem() {
        if currentItemIndex < purchasedItems.count - 1 {
            currentItemIndex += 1
        } else {
            // All items processed
            onComplete()
            dismiss()
        }
    }
}

#Preview {
    AddPurchasedItemsView(
        purchasedItems: [
            GroceryItem(name: "Organic Spinach", isPurchased: true),
            GroceryItem(name: "Greek Yogurt", isPurchased: true)
        ],
        onComplete: {}
    )
}
