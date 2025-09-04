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
    @ObservedObject private var fridgeDataService = FridgeDataService.shared
    
    @State private var items: [ManualFoodItem] = [ManualFoodItem()]
    @State private var showingAddLocation = false
    @State private var newLocation = ""
    
    struct ManualFoodItem: Identifiable {
        let id = UUID()
        var name = ""
        var category = FoodCategory.other
        var quantity = 1.0
        var unit = FoodUnit.pieces
        var shelfLifeDays = 7
        var expirationDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        var location = "Middle Shelf"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Add Item")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Button(action: {
                        saveAllItems()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .disabled(items.isEmpty || items.allSatisfy { $0.name.isEmpty })
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .background(
                    Color.appBackground
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                )
                
                // Main Content
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.lg) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            ManualItemCard(
                                item: $items[index],
                                onDelete: items.count > 1 ? {
                                    items.remove(at: index)
                                } : nil
                            )
                        }
                        
                        // Circular Plus Button
                        Button(action: {
                            addBlankItem()
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.oceanBlue)
                                )
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                
                Spacer()
            }
            .background(
                Color.appBackground
                    .onTapGesture {
                        // Dismiss keyboard when tapping on background
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .navigationBarHidden(true)
        }
        .alert("Add New Location", isPresented: $showingAddLocation) {
            TextField("Location name", text: $newLocation)
            Button("Add") {
                locationManager.addLocation(newLocation)
                newLocation = ""
            }
            Button("Cancel") {
                newLocation = ""
            }
        } message: {
            Text("Enter a new fridge location (e.g., 'Wine Rack', 'Cheese Drawer')")
        }
    }
    
    private func addBlankItem() {
        let newItem = ManualFoodItem()
        items.append(newItem)
    }
    
    private func saveAllItems() {
        // Convert manual items to food items and save to data service
        let foodItemsToAdd = items.compactMap { item -> FoodItem? in
            guard !item.name.isEmpty else { return nil }
            
            return FoodItem(
                name: item.name,
                category: item.category,
                quantity: item.quantity,
                unit: item.unit,
                expirationDate: item.expirationDate,
                dateAdded: Date(),
                zoneTag: item.location,
                storage: "Refrigerator"
            )
        }
        
        // Add all items to the fridge data service
        if !foodItemsToAdd.isEmpty {
            fridgeDataService.addItems(foodItemsToAdd)
            print("Successfully saved \(foodItemsToAdd.count) manual items to fridge")
        }
        
        dismiss()
    }
}

// MARK: - Manual Item Card

struct ManualItemCard: View {
    @Binding var item: ManualEntryView.ManualFoodItem
    let onDelete: (() -> Void)?
    
    @StateObject private var locationManager = LocationManager()
    @State private var showingAddLocation = false
    @State private var newLocation = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Modern header with improved styling
            VStack(alignment: .leading, spacing: 8) {
                // Item name and delete button on same line
                HStack {
                    TextField("Enter food name", text: $item.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.title3)
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Modern form fields with card-based design
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Category section - separate line
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    
                    Picker("Category", selection: $item.category) {
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            Text(category.emoji + "  " + category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Quantity section - separate line
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity")
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    
                    HStack(spacing: 8) {
                        TextField("1", value: $item.quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.oceanBlue)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 100, alignment: .center)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            )
                            .layoutPriority(1)
                        
                        Picker("Unit", selection: $item.unit) {
                            ForEach(FoodUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .font(.caption)
                        .frame(minWidth: 80)
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Shelf Life and Expires On in one line
                HStack(spacing: DesignSystem.Spacing.lg) {
                    // Shelf life
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shelf Life")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                if item.shelfLifeDays > 1 {
                                    item.shelfLifeDays -= 1
                                    item.expirationDate = Calendar.current.date(byAdding: .day, value: item.shelfLifeDays, to: Date()) ?? Date()
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("\(item.shelfLifeDays)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.oceanBlue)
                                .frame(width: 30)
                            
                            Button(action: {
                                if item.shelfLifeDays < 365 {
                                    item.shelfLifeDays += 1
                                    item.expirationDate = Calendar.current.date(byAdding: .day, value: item.shelfLifeDays, to: Date()) ?? Date()
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.oceanBlue)
                            }
                            
                            Text("days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    // Expires on date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expires On")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        
                        DatePicker("", selection: $item.expirationDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .onChange(of: item.expirationDate) { newDate in
                                let calendar = Calendar.current
                                let today = calendar.startOfDay(for: Date())
                                let selectedDate = calendar.startOfDay(for: newDate)
                                let daysDifference = calendar.dateComponents([.day], from: today, to: selectedDate).day ?? 0
                                item.shelfLifeDays = max(1, daysDifference)
                            }
                    }
                }
                
                // Location section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    
                    Picker("Location", selection: $item.location) {
                        ForEach(locationManager.allLocations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                        
                        Text("Add New Location...")
                            .foregroundColor(.oceanBlue)
                            .tag("add_new")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .cuteDropdownStyle()
                    .onChange(of: item.location) { newValue in
                        if newValue == "add_new" {
                            showingAddLocation = true
                            item.location = locationManager.allLocations.first ?? "Middle Shelf"
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .alert("Add New Location", isPresented: $showingAddLocation) {
            TextField("Location name", text: $newLocation)
            Button("Add") {
                locationManager.addLocation(newLocation)
                item.location = newLocation
                newLocation = ""
            }
            Button("Cancel") {
                newLocation = ""
            }
        } message: {
            Text("Enter a new fridge location (e.g., 'Wine Rack', 'Cheese Drawer')")
        }
    }
}

#Preview {
    ManualEntryView()
}
