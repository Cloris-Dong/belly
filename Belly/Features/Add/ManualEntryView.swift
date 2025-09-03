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
                            // Item Card
                            VStack(spacing: DesignSystem.Spacing.lg) {
                                // Item name and delete button on same line
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Food Name")
                                            .font(.subheadline)
                                            .foregroundColor(.primaryText)
                                        
                                        TextField("Enter food name", text: $items[index].name)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primaryText)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color(.systemGray6))
                                            )
                                    }
                                    
                                    Spacer()
                                    
                                    if items.count > 1 {
                                        Button(action: {
                                            items.remove(at: index)
                                        }) {
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
                            
                            // Category section - separate line
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                Picker("Category", selection: $items[index].category) {
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
                                    TextField("1", value: $items[index].quantity, format: .number)
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
                                    
                                    Picker("Unit", selection: $items[index].unit) {
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
                                            if items[index].shelfLifeDays > 1 {
                                                items[index].shelfLifeDays -= 1
                                                items[index].expirationDate = Calendar.current.date(byAdding: .day, value: items[index].shelfLifeDays, to: Date()) ?? Date()
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text("\(items[index].shelfLifeDays)")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.oceanBlue)
                                            .frame(width: 30)
                                        
                                        Button(action: {
                                            if items[index].shelfLifeDays < 365 {
                                                items[index].shelfLifeDays += 1
                                                items[index].expirationDate = Calendar.current.date(byAdding: .day, value: items[index].shelfLifeDays, to: Date()) ?? Date()
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
                                    
                                    DatePicker("", selection: $items[index].expirationDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                        )
                                        .onChange(of: items[index].expirationDate) { newDate in
                                            let calendar = Calendar.current
                                            let today = calendar.startOfDay(for: Date())
                                            let selectedDate = calendar.startOfDay(for: newDate)
                                            let daysDifference = calendar.dateComponents([.day], from: today, to: selectedDate).day ?? 0
                                            items[index].shelfLifeDays = max(1, daysDifference)
                                        }
                                }
                            }
                            .frame(height: 100)
                            
                            // Location section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Location")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                Picker("Location", selection: $items[index].location) {
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
                                .onChange(of: items[index].location) { newValue in
                                    if newValue == "add_new" {
                                        showingAddLocation = true
                                        items[index].location = locationManager.allLocations.first ?? "Middle Shelf"
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
            .background(Color.appBackground)
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
        // Save all items with names
        for item in items where !item.name.isEmpty {
            let newFoodItem = FoodItem(
                name: item.name,
                category: item.category,
                quantity: item.quantity,
                unit: item.unit,
                expirationDate: item.expirationDate,
                dateAdded: Date(),
                zoneTag: item.location,
                storage: "Refrigerator"
            )
            
            // Add to fridge view model (mock data for now)
            fridgeViewModel.foodItems.append(newFoodItem)
            
            print("Successfully saved manual item: \(item.name) to \(item.location)")
        }
        
        // Show success feedback
        // TODO: Add success notification
        
        dismiss()
    }
}

#Preview {
    ManualEntryView()
}
