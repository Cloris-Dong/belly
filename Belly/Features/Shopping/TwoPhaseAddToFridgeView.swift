//
//  TwoPhaseAddToFridgeView.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct TwoPhaseAddToFridgeView: View {
    let purchasedItems: [GroceryItem]
    let onComplete: ([GroceryItem]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: Set<UUID> = []
    @State private var showingConfiguration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !showingConfiguration {
                    // Phase 1: Simple Selection
                    SelectionPhaseView(
                        purchasedItems: purchasedItems,
                        selectedItems: $selectedItems,
                        onContinue: {
                            showingConfiguration = true
                        }
                    )
                } else {
                    // Phase 2: Detailed Configuration
                    ConfigurationPhaseView(
                        selectedItems: purchasedItems.filter { selectedItems.contains($0.id) },
                        onComplete: { configuredItems in
                            onComplete(configuredItems)
                            dismiss()
                        },
                        onBack: {
                            showingConfiguration = false
                        }
                    )
                }
            }
            .navigationTitle(showingConfiguration ? "Configure Items" : "Select Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            // Pre-select all items
            selectedItems = Set(purchasedItems.map { $0.id })
        }
    }
}

struct SelectionPhaseView: View {
    let purchasedItems: [GroceryItem]
    @Binding var selectedItems: Set<UUID>
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Which items do you want to add to your fridge?")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            List {
                ForEach(purchasedItems) { item in
                    HStack {
                        Button(action: {
                            if selectedItems.contains(item.id) {
                                selectedItems.remove(item.id)
                            } else {
                                selectedItems.insert(item.id)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedItems.contains(item.id) ? .blue : .secondary)
                                
                                Text(item.displayText)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Button("Configure \(selectedItems.count) Items") {
                onContinue()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedItems.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(selectedItems.isEmpty)
            .padding()
        }
    }
}

struct ConfigurationPhaseView: View {
    let selectedItems: [GroceryItem]
    let onComplete: ([GroceryItem]) -> Void
    let onBack: () -> Void
    
    @State private var itemConfigurations: [UUID: ItemConfiguration] = [:]
    
    struct ItemConfiguration {
        var location: String = "Middle Shelf"
        var shelfLifeDays: Int = 7
        var category: String = "Other"
        var quantity: Double
        var unit: String
        
        init(from item: GroceryItem) {
            self.quantity = item.quantity
            self.unit = item.unit
            
            // Smart defaults based on item name
            let name = item.name.lowercased()
            if name.contains("milk") || name.contains("yogurt") || name.contains("cheese") {
                self.category = "Dairy"
                self.location = "Middle Shelf"
                self.shelfLifeDays = 7
            } else if name.contains("apple") || name.contains("banana") || name.contains("fruit") {
                self.category = "Fruits"
                self.location = "Crisper Drawer"
                self.shelfLifeDays = 7
            } else if name.contains("lettuce") || name.contains("spinach") || name.contains("vegetable") {
                self.category = "Vegetables"
                self.location = "Crisper Drawer"
                self.shelfLifeDays = 5
            }
            // Add more smart defaults as needed
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(selectedItems) { item in
                        ItemConfigurationCard(
                            item: item,
                            configuration: Binding(
                                get: { itemConfigurations[item.id] ?? ItemConfiguration(from: item) },
                                set: { itemConfigurations[item.id] = $0 }
                            )
                        )
                    }
                }
                .padding()
            }
            
            HStack(spacing: 16) {
                Button("Back") {
                    onBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
                
                Button("Add to Fridge") {
                    onComplete(selectedItems)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            // Initialize configurations for all items
            for item in selectedItems {
                if itemConfigurations[item.id] == nil {
                    itemConfigurations[item.id] = ItemConfiguration(from: item)
                }
            }
        }
    }
}

struct ItemConfigurationCard: View {
    let item: GroceryItem
    @Binding var configuration: ConfigurationPhaseView.ItemConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.name)
                .font(.headline)
            
            // Same configuration options as manual entry
            HStack {
                VStack(alignment: .leading) {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Qty", value: $configuration.quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        
                        Picker("Unit", selection: $configuration.unit) {
                            ForEach(["pieces", "kg", "g", "liters", "bottles", "packs"], id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Shelf Life")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Stepper("\(configuration.shelfLifeDays) days", value: $configuration.shelfLifeDays, in: 1...30)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Category", selection: $configuration.category) {
                        ForEach(["Vegetables", "Fruits", "Dairy", "Meat", "Pantry", "Beverages", "Other"], id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Location", selection: $configuration.location) {
                        ForEach(["Top Shelf", "Middle Shelf", "Bottom Shelf", "Crisper Drawer", "Door Shelf"], id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TwoPhaseAddToFridgeView(
        purchasedItems: [
            GroceryItem(text: "Milk 2 liters", isPurchased: true),
            GroceryItem(text: "5 apples", isPurchased: true),
            GroceryItem(text: "Bread 1 loaf", isPurchased: true)
        ],
        onComplete: { _ in }
    )
}
