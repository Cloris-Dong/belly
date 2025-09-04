//
//  AddItemView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct ManualAddItemView: View {
    @StateObject private var fridgeViewModel = FridgeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory = FoodCategory.other
    @State private var quantity = 1.0
    @State private var selectedUnit = FoodUnit.pieces
    @State private var shelfLife = 7
    @State private var selectedLocation = "Refrigerator"
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    // Available locations
    private let locations = [
        "Refrigerator",
        "Freezer",
        "Pantry",
        "Crisper",
        "Dairy Shelf",
        "Meat Drawer",
        "Door Shelf"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    // Name field
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Item name", text: $name)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 200)
                    }
                    
                    // Category picker
                    HStack {
                        Text("Category")
                        Spacer()
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(FoodCategory.allCases) { category in
                                HStack {
                                    Text(category.emoji)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Quantity field
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("Quantity", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 100)
                    }
                    
                    // Unit picker
                    HStack {
                        Text("Unit")
                        Spacer()
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(FoodUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Storage Information")) {
                    // Shelf life field
                    HStack {
                        Text("Shelf Life")
                        Spacer()
                        TextField("Days", value: $shelfLife, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 100)
                        Text("days")
                            .foregroundColor(.secondary)
                    }
                    
                    // Location picker
                    HStack {
                        Text("Location")
                        Spacer()
                        Picker("Location", selection: $selectedLocation) {
                            ForEach(locations, id: \.self) { location in
                                Text(location).tag(location)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Expiration")) {
                    // Calculated expiration date
                    HStack {
                        Text("Expires")
                        Spacer()
                        Text(calculatedExpiryDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    // Expiration warning
                    if shelfLife <= 3 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Short shelf life - consider using soon after purchase")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section {
                    Button("Add to Fridge") {
                        addItem()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var calculatedExpiryDate: Date {
        Calendar.current.date(byAdding: .day, value: shelfLife, to: Date()) ?? Date()
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        quantity > 0 &&
        shelfLife > 0
    }
    
    // MARK: - Actions
    
    private func addItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate input
        guard !trimmedName.isEmpty else {
            validationMessage = "Item name cannot be empty"
            showingValidationError = true
            return
        }
        
        guard quantity > 0 else {
            validationMessage = "Quantity must be greater than 0"
            showingValidationError = true
            return
        }
        
        guard shelfLife > 0 else {
            validationMessage = "Shelf life must be greater than 0 days"
            showingValidationError = true
            return
        }
        
        // Create new item
        let newItem = FoodItem(
            name: trimmedName,
            category: selectedCategory,
            quantity: quantity,
            unit: selectedUnit,
            expirationDate: calculatedExpiryDate,
            dateAdded: Date(),
            zoneTag: selectedLocation,
            storage: "Refrigerator"
        )
        
        // Add to fridge view model
        fridgeViewModel.foodItems.append(newItem)
        dismiss()
    }
}

#Preview {
    ManualAddItemView()
}
