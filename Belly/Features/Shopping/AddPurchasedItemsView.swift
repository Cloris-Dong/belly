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
                List(purchasedItems) { item in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(item.displayText)
                        Spacer()
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
            .navigationTitle("Add to Fridge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
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
                            Text(item.displayText)
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
                            .font(.system(size: 60))
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
        // Convert GroceryItem to FoodItem and add to fridge
        let foodItem = FoodItem(
            name: groceryItem.name,
            category: FoodCategory.allCases.first { $0.rawValue == "Other" } ?? .other,
            quantity: groceryItem.quantity,
            unit: FoodUnit.allCases.first { $0.rawValue == groceryItem.unit } ?? .pieces,
            expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            dateAdded: Date(),
            zoneTag: "Shopping List",
            storage: "Refrigerator"
        )
        
        // Add to fridge view model
        fridgeViewModel.foodItems.append(foodItem)
        
        print("Added to fridge: \(groceryItem.displayText)")
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
            GroceryItem(text: "Organic Spinach", isPurchased: true),
            GroceryItem(text: "Greek Yogurt", isPurchased: true)
        ],
        onComplete: {}
    )
}
