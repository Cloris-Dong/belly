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
    @State private var animatingItems: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Navigation title
                Text("Shopping List")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.md)
                
                // Main content with coordinated animations
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // TO BUY SECTION (Always visible with add item at bottom)
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(
                                title: "To Buy",
                                count: shoppingViewModel.unpurchasedItems.count,
                                color: .primaryText
                            )
                            
                            VStack(spacing: 8) {
                                // Existing unchecked items
                                ForEach(shoppingViewModel.unpurchasedItems) { item in
                                    ModernShoppingRow(
                                        item: item,
                                        onTogglePurchased: {
                                            animateItemTransition(item)
                                        },
                                        onUpdate: { name, quantity, unit in
                                            shoppingViewModel.updateItem(item, name: name, quantity: quantity, unit: unit)
                                        },
                                        onDelete: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                shoppingViewModel.deleteItem(item)
                                            }
                                        }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .move(edge: .bottom).combined(with: .opacity)
                                    ))
                                    .animation(.easeInOut(duration: 0.4), value: item.isPurchased)
                                    .scaleEffect(animatingItems.contains(item.id) ? 0.95 : 1.0)
                                    .opacity(animatingItems.contains(item.id) ? 0.7 : 1.0)
                                }
                                
                                // Add new item input (always at bottom)
                                NewItemRow { name, quantity, unit in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        shoppingViewModel.addItem(name, quantity: quantity, unit: unit)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(Color.lightSageGreen)
                        )
                        .padding(.horizontal)
                        
                        // PURCHASED SECTION
                        if !shoppingViewModel.purchasedItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                                            SectionHeader(
                                title: "Purchased",
                                count: shoppingViewModel.purchasedItems.count,
                                color: .primaryText
                            )
                                
                                VStack(spacing: 8) {
                                    ForEach(shoppingViewModel.purchasedItems) { item in
                                        ModernShoppingRow(
                                            item: item,
                                            onTogglePurchased: {
                                                animateItemTransition(item)
                                            },
                                            onUpdate: { name, quantity, unit in
                                                shoppingViewModel.updateItem(item, name: name, quantity: quantity, unit: unit)
                                            },
                                            onDelete: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    shoppingViewModel.deleteItem(item)
                                                }
                                            }
                                        )
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .top).combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                        .animation(.easeInOut(duration: 0.4), value: item.isPurchased)
                                        .scaleEffect(animatingItems.contains(item.id) ? 0.95 : 1.0)
                                        .opacity(animatingItems.contains(item.id) ? 0.7 : 1.0)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Bulk add button (only when purchased items exist)
                if !shoppingViewModel.purchasedItems.isEmpty {
                    VStack {
                        Button("Add \(shoppingViewModel.purchasedItems.count) Items to Fridge") {
                            showingBulkAdd = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.oceanBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding()
                    }
                    .background(Color.appBackground)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: shoppingViewModel.purchasedItems.isEmpty)
                }
            }
            .background(Color.appBackground)
            .onTapGesture {
                // Dismiss keyboard when tapping outside text fields
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .sheet(isPresented: $showingBulkAdd) {
            TwoPhaseAddToFridgeView(
                purchasedItems: shoppingViewModel.purchasedItems,
                onComplete: { addedItems in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        shoppingViewModel.removePurchasedItems(addedItems)
                    }
                }
            )
        }
    }
    
    // MARK: - Animation Helpers
    
    private func animateItemTransition(_ item: GroceryItem) {
        // Add item to animating set
        animatingItems.insert(item.id)
        
        // Start the transition animation
        withAnimation(.easeInOut(duration: 0.4)) {
            // Toggle the purchased state
            shoppingViewModel.togglePurchased(item)
        }
        
        // Remove from animating set after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animatingItems.remove(item.id)
        }
    }
}

#Preview {
    ShoppingListView()
}
