//
//  ShoppingView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import CoreData

struct ShoppingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GroceryItem.isPurchased, ascending: true),
            NSSortDescriptor(keyPath: \GroceryItem.dateAdded, ascending: false)
        ],
        animation: .default)
    private var groceryItems: FetchedResults<GroceryItem>
    
    @State private var showingAddSheet = false
    @State private var newItemName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.oceanBlue)
                
                Text("Shopping List")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("Manage your grocery shopping list")
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Shopping stats
                HStack(spacing: 20) {
                    ShoppingStatCard(
                        title: "Total Items",
                        value: groceryItems.count,
                        color: .oceanBlue
                    )
                    
                    ShoppingStatCard(
                        title: "Need to Buy",
                        value: groceryItems.filter { !$0.isPurchased }.count,
                        color: .warmAmber
                    )
                }
                .padding(.horizontal)
                
                // Quick add button
                Button("Add Item to List") {
                    showingAddSheet = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.oceanBlue)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Simple list of items
                if !groceryItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Items:")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        ForEach(Array(groceryItems.prefix(3)), id: \.id) { item in
                            HStack {
                                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isPurchased ? .sageGreen : .secondaryText)
                                
                                Text(item.name)
                                    .foregroundColor(.primaryText)
                                    .strikethrough(item.isPurchased)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                toggleItem(item)
                            }
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Shopping")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddSheet) {
                AddGroceryItemSheet(newItemName: $newItemName) {
                    addNewItem()
                }
            }
        }
    }
    
    private func addNewItem() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newItem = GroceryItem.create(
            in: viewContext,
            name: newItemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: .other
        )
        
        do {
            try viewContext.save()
            newItemName = ""
            showingAddSheet = false
        } catch {
            print("Error saving grocery item: \(error)")
        }
    }
    
    private func toggleItem(_ item: GroceryItem) {
        item.togglePurchased()
        
        do {
            try viewContext.save()
        } catch {
            print("Error updating item: \(error)")
        }
    }
}

struct ShoppingStatCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct AddGroceryItemSheet: View {
    @Binding var newItemName: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add New Item")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                TextField("Enter item name", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Add to List") {
                    onAdd()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.oceanBlue)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("New Item")
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
}

#Preview {
    ShoppingView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
