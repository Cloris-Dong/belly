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
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var fridgeDataService = FridgeDataService.shared
    
    @State private var selectedItems: Set<UUID> = []
    @State private var showingConfiguration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !showingConfiguration {
                    // Phase 1: Simple Selection
                    SelectionPhaseView(
                        purchasedItems: purchasedItems,
                        selectedItems: $selectedItems,
                        onContinue: {
                            showingConfiguration = true
                        },
                        onCancel: { dismiss() }
                    )
                } else {
                    // Phase 2: Detailed Configuration
                    ConfigurationPhaseView(
                        selectedItems: purchasedItems.filter { selectedItems.contains($0.id) },
                        locationManager: locationManager,
                        fridgeDataService: fridgeDataService,
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
            .background(
                Color.appBackground
                    .onTapGesture {
                        // Dismiss keyboard when tapping on background
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .navigationBarHidden(true)
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
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: {
                    onCancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Select Items")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    onContinue()
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .disabled(selectedItems.isEmpty)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.xl)
            .background(
                Color.appBackground
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
            
            // Content
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header text
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Which items do you want to add to your fridge?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primaryText)
                }
                .padding(.top, DesignSystem.Spacing.lg)
                
                // Items list
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(Array(purchasedItems.enumerated()), id: \.element.id) { _, item in
                            SelectionItemCard(
                                item: item,
                                isSelected: selectedItems.contains(item.id),
                                onToggle: {
                                    if selectedItems.contains(item.id) {
                                        selectedItems.remove(item.id)
                                    } else {
                                        selectedItems.insert(item.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                Spacer()
            }
        }
    }
}

struct SelectionItemCard: View {
    let item: GroceryItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .oceanBlue : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text("\(item.quantity, specifier: "%.0f") \(item.unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConfigurationPhaseView: View {
    let selectedItems: [GroceryItem]
    let locationManager: LocationManager
    let fridgeDataService: FridgeDataService
    let onComplete: ([GroceryItem]) -> Void
    let onBack: () -> Void
    
    @State private var itemConfigurations: [UUID: ItemConfiguration] = [:]
    @State private var showingAddLocation = false
    @State private var newLocation = ""
    
    struct ItemConfiguration {
        var location: String = "Middle Shelf"
        var shelfLifeDays: Int = 7
        var category: FoodCategory = .other
        var quantity: Double
        var unit: String
        
        init(from item: GroceryItem) {
            self.quantity = item.quantity
            self.unit = item.unit
            
            // Smart defaults based on item name
            let name = item.name.lowercased()
            if name.contains("milk") || name.contains("yogurt") || name.contains("cheese") {
                self.category = .dairy
                self.location = "Middle Shelf"
                self.shelfLifeDays = 7
            } else if name.contains("apple") || name.contains("banana") || name.contains("fruit") {
                self.category = .fruits
                self.location = "Crisper Drawer"
                self.shelfLifeDays = 7
            } else if name.contains("lettuce") || name.contains("spinach") || name.contains("vegetable") {
                self.category = .vegetables
                self.location = "Crisper Drawer"
                self.shelfLifeDays = 5
            }
            // Add more smart defaults as needed
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Configure Items")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    addItemsToFridge()
                    onComplete(selectedItems)
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.xl)
            .background(
                Color.appBackground
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
            
            // Content
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    ForEach(selectedItems) { item in
                        ItemConfigurationCard(
                            item: item,
                            configuration: Binding(
                                get: { itemConfigurations[item.id] ?? ItemConfiguration(from: item) },
                                set: { itemConfigurations[item.id] = $0 }
                            ),
                            locationManager: locationManager,
                            onAddLocation: {
                                showingAddLocation = true
                            }
                        )
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            
            Spacer()
        }
        .onAppear {
            // Initialize configurations for all items
            for item in selectedItems {
                if itemConfigurations[item.id] == nil {
                    itemConfigurations[item.id] = ItemConfiguration(from: item)
                }
            }
        }
        .alert("Add New Location", isPresented: $showingAddLocation) {
            TextField("Location name", text: $newLocation)
            Button("Add") {
                locationManager.addLocation(newLocation)
                newLocation = ""
            }
            Button("Cancel", role: .cancel) {
                newLocation = ""
            }
        } message: {
            Text("Enter a name for the new storage location")
        }
    }
    
    // MARK: - Helper Methods
    
    private func addItemsToFridge() {
        var foodItemsToAdd: [FoodItem] = []
        
        for item in selectedItems {
            let config = itemConfigurations[item.id] ?? ItemConfiguration(from: item)
            
            let foodItem = FoodItem(
                name: item.name,
                category: config.category,
                quantity: config.quantity,
                unit: FoodUnit.allCases.first { $0.rawValue == config.unit } ?? .pieces,
                expirationDate: Calendar.current.date(byAdding: .day, value: config.shelfLifeDays, to: Date()) ?? Date(),
                dateAdded: Date(),
                zoneTag: config.location,
                storage: "Refrigerator" // Default storage
            )
            
            foodItemsToAdd.append(foodItem)
        }
        
        // Add all items to fridge using the data service
        fridgeDataService.addItems(foodItemsToAdd)
        
        print("✅ Successfully added \(foodItemsToAdd.count) items to fridge from shopping list!")
    }
}

struct ItemConfigurationCard: View {
    let item: GroceryItem
    @Binding var configuration: ConfigurationPhaseView.ItemConfiguration
    let locationManager: LocationManager
    let onAddLocation: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Item name header
            VStack(alignment: .leading, spacing: 8) {
                Text("Food Name")
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
                
                Text(item.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }
            
            // Category section
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
                
                Picker("Category", selection: $configuration.category) {
                    ForEach(FoodCategory.allCases) { category in
                        Text(category.emoji + "  " + category.rawValue)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Quantity section
            VStack(alignment: .leading, spacing: 8) {
                Text("Quantity")
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
                
                HStack {
                    TextField("Quantity", value: $configuration.quantity, format: .number)
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
                    
                    Picker("Unit", selection: $configuration.unit) {
                        ForEach(["pieces", "kg", "g", "liters", "bottles", "packs"], id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.caption)
                    .frame(minWidth: 80)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
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
                            if configuration.shelfLifeDays > 1 {
                                configuration.shelfLifeDays -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Text("\(configuration.shelfLifeDays)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.oceanBlue)
                            .frame(width: 30)
                        
                        Button(action: {
                            if configuration.shelfLifeDays < 365 {
                                configuration.shelfLifeDays += 1
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
                    
                    DatePicker("", selection: Binding(
                        get: { 
                            Calendar.current.date(byAdding: .day, value: configuration.shelfLifeDays, to: Date()) ?? Date()
                        },
                        set: { newDate in
                            let calendar = Calendar.current
                            let today = calendar.startOfDay(for: Date())
                            let selectedDate = calendar.startOfDay(for: newDate)
                            let daysDifference = calendar.dateComponents([.day], from: today, to: selectedDate).day ?? 0
                            configuration.shelfLifeDays = max(1, daysDifference)
                        }
                    ), in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            
            // Location section
            VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
                
                Picker("Location", selection: $configuration.location) {
                    ForEach(locationManager.allLocations, id: \.self) { location in
                        Text(location).tag(location)
                    }
                    
                    Text("Add New Location...")
                        .foregroundColor(.oceanBlue)
                        .tag("add_new")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .cuteDropdownStyle()
                .onChange(of: configuration.location) { newValue in
                    if newValue == "add_new" {
                        onAddLocation()
                        configuration.location = locationManager.allLocations.first ?? "Middle Shelf"
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
    }
}

#Preview {
    TwoPhaseAddToFridgeView(
        purchasedItems: [
            GroceryItem(name: "Milk", quantity: 2.0, unit: "liters", isPurchased: true),
            GroceryItem(name: "Apples", quantity: 5.0, unit: "pieces", isPurchased: true),
            GroceryItem(name: "Bread", quantity: 1.0, unit: "loaf", isPurchased: true)
        ],
        onComplete: { _ in }
    )
}
