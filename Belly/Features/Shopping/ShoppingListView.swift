//
//  ShoppingListView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject private var shoppingViewModel = ShoppingViewModel()
    @State private var showingBulkAdd = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Simple header
                HStack {
                    Text("Shopping List")
                        .font(.largeTitle.weight(.bold))
                    Spacer()
                }
                .padding()
                
                // Notes-style list
                ScrollView {
                    LazyVStack(spacing: 4) {
                        // Unpurchased items (top)
                        ForEach(shoppingViewModel.unpurchasedItems) { item in
                            SimpleShoppingRow(
                                item: item,
                                onTogglePurchased: { shoppingViewModel.togglePurchased(item) },
                                onUpdate: { newText in shoppingViewModel.updateItem(item, text: newText) },
                                onDelete: { shoppingViewModel.deleteItem(item) }
                            )
                        }
                        
                        // New item row (always at bottom of unpurchased)
                        NewItemRow { text in
                            shoppingViewModel.addItem(text)
                        }
                        
                        // Purchased items (bottom, visually separated)
                        if !shoppingViewModel.purchasedItems.isEmpty {
                            Divider()
                                .padding(.vertical, 8)
                            
                            ForEach(shoppingViewModel.purchasedItems) { item in
                                SimpleShoppingRow(
                                    item: item,
                                    onTogglePurchased: { shoppingViewModel.togglePurchased(item) },
                                    onUpdate: { newText in shoppingViewModel.updateItem(item, text: newText) },
                                    onDelete: { shoppingViewModel.deleteItem(item) }
                                )
                            }
                        }
                    }
                    .padding()
                }
                
                // Bulk add button (only when purchased items exist)
                if !shoppingViewModel.purchasedItems.isEmpty {
                    VStack {
                        Divider()
                        Button("Add \(shoppingViewModel.purchasedItems.count) Items to Fridge") {
                            showingBulkAdd = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding()
                    }
                    .background(Color(.systemBackground))
                }
            }
        }
        .sheet(isPresented: $showingBulkAdd) {
            TwoPhaseAddToFridgeView(
                purchasedItems: shoppingViewModel.purchasedItems,
                onComplete: { addedItems in
                    shoppingViewModel.removePurchasedItems(addedItems)
                }
            )
        }
    }
}

#Preview {
    ShoppingListView()
}
