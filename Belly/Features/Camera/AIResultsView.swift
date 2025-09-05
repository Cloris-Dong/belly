//
//  AIResultsView.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct AIResultsView: View {
    @Binding var detectedItems: [DetectedFood]
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingToFridge = false
    @State private var showingSuccessAlert = false
    @State private var showingSuccess = false
    
    // Data service for adding items to fridge
    @ObservedObject private var fridgeDataService = FridgeDataService.shared
    
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
                    
                                    Text("Review")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Button(action: {
                        addItemsToFridge()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .disabled(detectedItems.isEmpty || isAddingToFridge)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .background(
                    Color.appBackground
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                )
                
                // Items list
                if detectedItems.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(Array(detectedItems.enumerated()), id: \.element.id) { index, item in
                                DetectedItemCard(
                                    item: $detectedItems[index],
                                    onDelete: {
                                        detectedItems.remove(at: index)
                                    }
                                )
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                        
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
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarHidden(true)
        }
        .alert("Items Added!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(detectedItems.count) item\(detectedItems.count == 1 ? "" : "s") added to your fridge.")
        }

        .overlay(
            Group {
                if showingSuccess {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.green)
                        
                        Text("Added to Fridge!")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .scaleEffect(showingSuccess ? 1.0 : 0.5)
                    .opacity(showingSuccess ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showingSuccess)
                }
            }
        )
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "camera.metering.none")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                                    Text("No items detected")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                
                Text("Try taking a clearer photo or add items manually")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Add Manually") {
                addBlankItem()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(Color.oceanBlue)
            )
        }
        .padding(DesignSystem.Spacing.xl)
    }
    

    
    // MARK: - Helper Functions
    
    private func addBlankItem() {
        let newItem = DetectedFood(
            name: "",
            category: "Other",
            shelfLifeDays: 7,
            storage: "Refrigerator",
            location: "Middle Shelf",
            confidence: 1.0,
            quantity: 1.0,
            unit: "pieces"
        )
        detectedItems.append(newItem)
    }
    
    private func addItemsToFridge() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isAddingToFridge = true
        
        // Convert detected items to FoodItems and add to fridge
        var foodItemsToAdd: [FoodItem] = []
        
        for detectedItem in detectedItems {
            let foodItem = FoodItem(
                name: detectedItem.name.isEmpty ? "Unknown Item" : detectedItem.name,
                category: FoodCategory.allCases.first { $0.rawValue == detectedItem.category } ?? .other,
                quantity: detectedItem.quantity,
                unit: FoodUnit.allCases.first { $0.rawValue == detectedItem.unit } ?? .pieces,
                expirationDate: Calendar.current.date(byAdding: .day, value: detectedItem.shelfLifeDays, to: Date()) ?? Date(),
                dateAdded: Date(),
                zoneTag: detectedItem.location,
                storage: detectedItem.storage
            )
            
            foodItemsToAdd.append(foodItem)
        }
        
        // Add all items to fridge using the data service
        fridgeDataService.addItems(foodItemsToAdd)
        
        print("✅ Successfully added \(foodItemsToAdd.count) items to fridge!")
        
        // Show success animation
        showSuccessAnimation()
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    

    
    private func showSuccessAnimation() {
        showingSuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showingSuccess = false
        }
    }
}

// MARK: - Detected Item Card

struct DetectedItemCard: View {
    @Binding var item: DetectedFood
    let onDelete: () -> Void
    
    @StateObject private var locationManager = LocationManager()
    @State private var showingDeleteAlert = false
    @State private var showingAddLocation = false
    @State private var newLocation = ""
    @State private var hasAutoSelectedCategory = false
    @State private var hasAutoSelectedUnit = false
    @State private var hasAutoSelectedQuantity = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Modern header with improved styling
            VStack(alignment: .leading, spacing: 8) {
                // Item name and delete button on same line
                HStack {
                    TextField("Food name", text: $item.name)
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
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                HStack(spacing: 10) {
                    confidenceBadge
                    
                    Text("\(item.confidencePercentage)% confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                        ForEach(FoodCategory.allCases, id: \.rawValue) { category in
                            Text(category.emoji + "  " + category.rawValue)
                                .tag(category.rawValue)
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
                            ForEach(FoodUnit.allCases, id: \.rawValue) { unit in
                                Text(unit.rawValue).tag(unit.rawValue)
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
        .alert("Remove Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to remove '\(item.name)' from the detected items?")
        }
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
        .onAppear {
            // Auto-select the detected category if not already done
            if !hasAutoSelectedCategory {
                // Map the detected category to a valid FoodCategory enum value
                let detectedCategoryEnum = FoodCategory.allCases.first { $0.rawValue.lowercased() == item.category.lowercased() } ?? 
                                         FoodCategory.allCases.first { $0.rawValue.contains(item.category) || item.category.contains($0.rawValue) } ?? 
                                         .other
                
                // Update the item's category to the mapped enum value
                item.category = detectedCategoryEnum.rawValue
                hasAutoSelectedCategory = true
                
                print("🎯 Auto-selected category: \(item.category) for detected item: \(item.name)")
            }
            
            // Auto-select the most likely unit if not already done
            if !hasAutoSelectedUnit {
                let detectedUnit = detectUnitFromName(item.name, category: item.category)
                item.unit = detectedUnit.rawValue
                hasAutoSelectedUnit = true
                
                print("🎯 Auto-selected unit: \(item.unit) for detected item: \(item.name)")
            }
            
            // Auto-select the most likely quantity if not already done
            if !hasAutoSelectedQuantity {
                let detectedQuantity = detectQuantityFromName(item.name, category: item.category, unit: item.unit)
                item.quantity = detectedQuantity
                hasAutoSelectedQuantity = true
                
                print("🎯 Auto-selected quantity: \(item.quantity) for detected item: \(item.name)")
            }
        }
    }
    
    // MARK: - Smart Unit Detection
    
    private func detectUnitFromName(_ name: String, category: String) -> FoodUnit {
        let itemName = name.lowercased()
        let itemCategory = category.lowercased()
        
        // Weight-based items (typically sold by weight)
        if itemName.contains("meat") || itemName.contains("chicken") || itemName.contains("beef") || 
           itemName.contains("pork") || itemName.contains("fish") || itemName.contains("salmon") ||
           itemName.contains("tuna") || itemName.contains("shrimp") || itemName.contains("lamb") ||
           itemName.contains("turkey") || itemName.contains("ham") || itemName.contains("bacon") ||
           itemName.contains("sausage") || itemName.contains("cheese") || itemName.contains("butter") ||
           itemName.contains("flour") || itemName.contains("sugar") || itemName.contains("rice") ||
           itemName.contains("pasta") || itemName.contains("nuts") || itemName.contains("seeds") ||
           itemName.contains("coffee") || itemName.contains("tea") || itemName.contains("spices") ||
           itemName.contains("herbs") || itemName.contains("salt") || itemName.contains("pepper") {
            return .grams
        }
        
        // Large weight items (typically sold by kg)
        else if itemName.contains("watermelon") || itemName.contains("pumpkin") || itemName.contains("cabbage") ||
                itemName.contains("large") || itemName.contains("whole") {
            return .kilograms
        }
        
        // Liquid items (typically sold in bottles)
        else if itemName.contains("milk") || itemName.contains("juice") || itemName.contains("soda") ||
                itemName.contains("water") || itemName.contains("oil") || itemName.contains("vinegar") ||
                itemName.contains("sauce") || itemName.contains("dressing") || itemName.contains("syrup") ||
                itemName.contains("honey") || itemName.contains("wine") || itemName.contains("beer") ||
                itemName.contains("soup") || itemName.contains("broth") {
            return .bottles
        }
        
        // Packaged items
        else if itemName.contains("yogurt") || itemName.contains("cream") || itemName.contains("sour cream") ||
                itemName.contains("cottage") || itemName.contains("milk") || itemName.contains("eggs") ||
                itemName.contains("tofu") || itemName.contains("tempeh") {
            return .cartons
        }
        
        // Canned items
        else if itemName.contains("canned") || itemName.contains("beans") || itemName.contains("corn") ||
                itemName.contains("tomatoes") || itemName.contains("soup") || itemName.contains("tuna") ||
                itemName.contains("sardines") || itemName.contains("olives") || itemName.contains("pickles") {
            return .cans
        }
        
        // Packaged/pre-packaged items
        else if itemName.contains("bread") || itemName.contains("bagels") || itemName.contains("muffins") ||
                itemName.contains("crackers") || itemName.contains("cookies") || itemName.contains("chips") ||
                itemName.contains("cereal") || itemName.contains("granola") || itemName.contains("bars") ||
                itemName.contains("frozen") || itemName.contains("pizza") || itemName.contains("dumplings") ||
                itemName.contains("wraps") || itemName.contains("tortillas") || itemName.contains("pita") ||
                itemName.contains("spinach") || itemName.contains("lettuce") || itemName.contains("arugula") ||
                itemName.contains("kale") || itemName.contains("herbs") || itemName.contains("mushrooms") {
            return .packages
        }
        
        // Individual items (typically sold by piece)
        else if itemName.contains("apple") || itemName.contains("banana") || itemName.contains("orange") ||
                itemName.contains("lemon") || itemName.contains("lime") || itemName.contains("peach") ||
                itemName.contains("pear") || itemName.contains("plum") || itemName.contains("avocado") ||
                itemName.contains("onion") || itemName.contains("garlic") || itemName.contains("potato") ||
                itemName.contains("sweet potato") || itemName.contains("carrot") || itemName.contains("celery") ||
                itemName.contains("cucumber") || itemName.contains("pepper") || itemName.contains("tomato") ||
                itemName.contains("broccoli") || itemName.contains("cauliflower") || itemName.contains("cabbage") ||
                itemName.contains("eggplant") || itemName.contains("zucchini") || itemName.contains("squash") ||
                itemName.contains("corn") || itemName.contains("asparagus") || itemName.contains("mango") ||
                itemName.contains("pineapple") || itemName.contains("kiwi") || itemName.contains("grape") ||
                itemName.contains("strawberry") || itemName.contains("blueberry") || itemName.contains("cherry") {
            return .pieces
        }
        
        // Category-based fallbacks
        else if itemCategory.contains("meat") || itemCategory.contains("dairy") {
            return .grams
        }
        else if itemCategory.contains("beverages") {
            return .bottles
        }
        else if itemCategory.contains("fruits") || itemCategory.contains("vegetables") {
            return .pieces
        }
        else if itemCategory.contains("pantry") {
            return .packages
        }
        
        // Default fallback
        else {
            return .pieces
        }
    }
    
    // MARK: - Smart Quantity Detection
    
    private func detectQuantityFromName(_ name: String, category: String, unit: String) -> Double {
        let itemName = name.lowercased()
        let itemCategory = category.lowercased()
        let itemUnit = unit.lowercased()
        
        // Weight-based items (grams/kg) - typical serving sizes
        if itemUnit == "g" || itemUnit == "kg" {
            if itemName.contains("meat") || itemName.contains("chicken") || itemName.contains("beef") || 
               itemName.contains("pork") || itemName.contains("fish") || itemName.contains("salmon") ||
               itemName.contains("tuna") || itemName.contains("shrimp") || itemName.contains("lamb") ||
               itemName.contains("turkey") || itemName.contains("ham") || itemName.contains("bacon") ||
               itemName.contains("sausage") {
                return 250.0 // ~8.8 oz serving
            }
            else if itemName.contains("cheese") || itemName.contains("butter") {
                return 100.0 // ~3.5 oz serving
            }
            else if itemName.contains("flour") || itemName.contains("sugar") || itemName.contains("rice") ||
                    itemName.contains("pasta") || itemName.contains("nuts") || itemName.contains("seeds") {
                return 150.0 // ~5.3 oz serving
            }
            else if itemName.contains("coffee") || itemName.contains("tea") || itemName.contains("spices") ||
                    itemName.contains("herbs") || itemName.contains("salt") || itemName.contains("pepper") {
                return 50.0 // ~1.8 oz serving
            }
            else {
                return 100.0 // Default weight serving
            }
        }
        
        // Large weight items (kg) - whole items
        else if itemUnit == "kg" {
            if itemName.contains("watermelon") || itemName.contains("pumpkin") {
                return 2.0 // ~4.4 lbs
            }
            else if itemName.contains("cabbage") || itemName.contains("large") || itemName.contains("whole") {
                return 1.0 // ~2.2 lbs
            }
            else {
                return 1.0 // Default kg serving
            }
        }
        
        // Liquid items (bottles) - typical bottle sizes
        else if itemUnit == "bottles" {
            if itemName.contains("milk") || itemName.contains("juice") || itemName.contains("soda") ||
               itemName.contains("water") {
                return 1.0 // 1 bottle
            }
            else if itemName.contains("oil") || itemName.contains("vinegar") || itemName.contains("sauce") ||
                    itemName.contains("dressing") || itemName.contains("syrup") || itemName.contains("honey") {
                return 1.0 // 1 bottle
            }
            else if itemName.contains("wine") || itemName.contains("beer") {
                return 1.0 // 1 bottle/can
            }
            else if itemName.contains("soup") || itemName.contains("broth") {
                return 1.0 // 1 can/carton
            }
            else {
                return 1.0 // Default bottle serving
            }
        }
        
        // Packaged items (packs) - typical package sizes
        else if itemUnit == "packs" {
            if itemName.contains("yogurt") || itemName.contains("cream") || itemName.contains("sour cream") ||
               itemName.contains("cottage") || itemName.contains("eggs") {
                return 1.0 // 1 pack/carton
            }
            else if itemName.contains("tofu") || itemName.contains("tempeh") {
                return 1.0 // 1 package
            }
            else {
                return 1.0 // Default pack serving
            }
        }
        
        // Canned items (cans) - typical can sizes
        else if itemUnit == "cans" {
            if itemName.contains("canned") || itemName.contains("beans") || itemName.contains("corn") ||
               itemName.contains("tomatoes") || itemName.contains("soup") || itemName.contains("tuna") ||
               itemName.contains("sardines") || itemName.contains("olives") || itemName.contains("pickles") {
                return 1.0 // 1 can
            }
            else {
                return 1.0 // Default can serving
            }
        }
        
        // Packaged/pre-packaged items (packs) - typical package sizes
        else if itemUnit == "packs" {
            if itemName.contains("bread") || itemName.contains("bagels") || itemName.contains("muffins") {
                return 1.0 // 1 loaf/pack
            }
            else if itemName.contains("crackers") || itemName.contains("cookies") || itemName.contains("chips") {
                return 1.0 // 1 pack
            }
            else if itemName.contains("cereal") || itemName.contains("granola") || itemName.contains("bars") {
                return 1.0 // 1 box/pack
            }
            else if itemName.contains("frozen") || itemName.contains("pizza") || itemName.contains("dumplings") {
                return 1.0 // 1 package
            }
            else if itemName.contains("wraps") || itemName.contains("tortillas") || itemName.contains("pita") {
                return 1.0 // 1 pack
            }
            else if itemName.contains("spinach") || itemName.contains("lettuce") || itemName.contains("arugula") ||
                    itemName.contains("kale") || itemName.contains("herbs") || itemName.contains("mushrooms") {
                return 1.0 // 1 package
            }
            else {
                return 1.0 // Default pack serving
            }
        }
        
        // Individual items (pieces) - typical serving sizes
        else if itemUnit == "pieces" {
            if itemName.contains("apple") || itemName.contains("banana") || itemName.contains("orange") ||
               itemName.contains("lemon") || itemName.contains("lime") || itemName.contains("peach") ||
               itemName.contains("pear") || itemName.contains("plum") || itemName.contains("avocado") {
                return 1.0 // 1 piece
            }
            else if itemName.contains("onion") || itemName.contains("garlic") || itemName.contains("potato") ||
                    itemName.contains("sweet potato") || itemName.contains("carrot") || itemName.contains("celery") ||
                    itemName.contains("cucumber") || itemName.contains("pepper") || itemName.contains("tomato") {
                return 1.0 // 1 piece
            }
            else if itemName.contains("broccoli") || itemName.contains("cauliflower") || itemName.contains("cabbage") ||
                    itemName.contains("eggplant") || itemName.contains("zucchini") || itemName.contains("squash") {
                return 1.0 // 1 piece
            }
            else if itemName.contains("corn") || itemName.contains("asparagus") {
                return 1.0 // 1 ear/bunch
            }
            else if itemName.contains("mango") || itemName.contains("pineapple") || itemName.contains("kiwi") {
                return 1.0 // 1 piece
            }
            else if itemName.contains("grape") || itemName.contains("strawberry") || itemName.contains("blueberry") ||
                    itemName.contains("cherry") {
                return 1.0 // 1 piece (or small handful)
            }
            else {
                return 1.0 // Default piece serving
            }
        }
        
        // Category-based fallbacks
        else if itemCategory.contains("meat") || itemCategory.contains("dairy") {
            return 1.0 // Default to 1 serving
        }
        else if itemCategory.contains("beverages") {
            return 1.0 // 1 bottle/can
        }
        else if itemCategory.contains("fruits") || itemCategory.contains("vegetables") {
            return 1.0 // 1 piece
        }
        else if itemCategory.contains("pantry") {
            return 1.0 // 1 package
        }
        
        // Default fallback
        else {
            return 1.0 // Default to 1
        }
    }
    
    // MARK: - Confidence Badge
    
    private var confidenceBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(confidenceColor)
                .frame(width: 6, height: 6)
            Text(item.confidenceColor)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(confidenceColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var confidenceColor: Color {
        switch item.confidence {
        case 0.8...:
            return .sageGreen
        case 0.6..<0.8:
            return .warmAmber
        default:
            return .softCoral
        }
    }
}

#Preview {
    AIResultsView(
        detectedItems: .constant([
            DetectedFood(name: "Organic Spinach", category: "Vegetables", shelfLifeDays: 5, storage: "Refrigerator", location: "Crisper Drawer", confidence: 0.92, quantity: 1.0, unit: "packages"),
            DetectedFood(name: "Red Bell Pepper", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", location: "Middle Shelf", confidence: 0.88, quantity: 2.0, unit: "pieces")
        ])
    )
}
