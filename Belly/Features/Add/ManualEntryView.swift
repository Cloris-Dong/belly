//
//  ManualEntryView.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var fridgeViewModel = FridgeViewModel()
    
    @State private var itemName = ""
    @State private var selectedCategory = FoodCategory.other
    @State private var quantity = 1.0
    @State private var selectedUnit = FoodUnit.pieces
    @State private var shelfLifeDays = 7
    @State private var expirationDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var selectedLocation = "Middle Shelf"
    @State private var showingAddLocation = false
    @State private var newLocation = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Food name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            Text(category.emoji + "  " + category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    HStack {
                        TextField("Quantity", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(FoodUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Stepper("Shelf Life: \(shelfLifeDays) days", value: $shelfLifeDays, in: 1...365)
                        .onChange(of: shelfLifeDays) { newValue in
                            // Update expiration date based on shelf life
                            expirationDate = Calendar.current.date(byAdding: .day, value: newValue, to: Date()) ?? Date()
                        }
                    
                    DatePicker("Expires on", selection: $expirationDate, displayedComponents: .date)
                        .onChange(of: expirationDate) { newValue in
                            // Update shelf life based on expiration date
                            let days = Calendar.current.dateComponents([.day], from: Date(), to: newValue).day ?? 7
                            shelfLifeDays = max(1, days)
                        }
                }
                
                Section("Storage Location") {
                    Picker("Location", selection: $selectedLocation) {
                        ForEach(locationManager.allLocations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                        
                        Text("Add New Location...")
                            .foregroundColor(.oceanBlue)
                            .tag("add_new")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedLocation) { newValue in
                        if newValue == "add_new" {
                            showingAddLocation = true
                            selectedLocation = locationManager.allLocations.first ?? "Middle Shelf"
                        }
                    }
                }
            }
            .navigationTitle("Add Item Manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
        .alert("Add New Location", isPresented: $showingAddLocation) {
            TextField("Location name", text: $newLocation)
            Button("Add") {
                locationManager.addLocation(newLocation)
                selectedLocation = newLocation
                newLocation = ""
            }
            Button("Cancel") {
                newLocation = ""
            }
        } message: {
            Text("Enter a new fridge location (e.g., 'Wine Rack', 'Cheese Drawer')")
        }
    }
    
    private func saveItem() {
        // Create FoodItem using the struct initializer
        let newFoodItem = FoodItem(
            name: itemName,
            category: selectedCategory,
            quantity: quantity,
            unit: selectedUnit,
            expirationDate: expirationDate,
            dateAdded: Date(),
            zoneTag: selectedLocation,
            storage: "Refrigerator"
        )
        
        // Add to fridge view model (mock data for now)
        fridgeViewModel.foodItems.append(newFoodItem)
        
        print("Successfully saved manual item: \(itemName) to \(selectedLocation)")
        
        // Show success feedback
        // TODO: Add success notification
        
        dismiss()
    }
}

#Preview {
    ManualEntryView()
}
