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
    @State private var showingSuccess = false
    
    struct ItemConfiguration {
        var location: String = "Middle Shelf"
        var shelfLifeDays: Int = 7
        var category: FoodCategory = .other
        var quantity: Double
        var unit: String
        
        init(from item: GroceryItem) {
            self.quantity = item.quantity
            
            // Enhanced smart category detection based on item name
            let name = item.name.lowercased()
            
            // Dairy products
            if name.contains("milk") || name.contains("yogurt") || name.contains("cheese") || 
               name.contains("butter") || name.contains("cream") || name.contains("sour cream") ||
               name.contains("cottage") || name.contains("mozzarella") || name.contains("cheddar") ||
               name.contains("feta") || name.contains("parmesan") || name.contains("ricotta") {
                self.category = .dairy
                self.location = "Middle Shelf"
                self.shelfLifeDays = 7
            }
            // Fruits
            else if name.contains("apple") || name.contains("banana") || name.contains("fruit") ||
                    name.contains("orange") || name.contains("lemon") || name.contains("lime") ||
                    name.contains("grape") || name.contains("strawberry") || name.contains("blueberry") ||
                    name.contains("raspberry") || name.contains("peach") || name.contains("pear") ||
                    name.contains("plum") || name.contains("cherry") || name.contains("kiwi") ||
                    name.contains("mango") || name.contains("pineapple") || name.contains("avocado") {
                self.category = .fruits
                self.location = "Crisper Drawer"
                self.shelfLifeDays = 7
            }
            // Vegetables
            else if name.contains("lettuce") || name.contains("spinach") || name.contains("vegetable") ||
                    name.contains("carrot") || name.contains("celery") || name.contains("onion") ||
                    name.contains("garlic") || name.contains("tomato") || name.contains("cucumber") ||
                    name.contains("pepper") || name.contains("broccoli") || name.contains("cauliflower") ||
                    name.contains("cabbage") || name.contains("potato") || name.contains("sweet potato") ||
                    name.contains("mushroom") || name.contains("zucchini") || name.contains("eggplant") ||
                    name.contains("asparagus") || name.contains("green bean") || name.contains("corn") {
                self.category = .vegetables
                self.location = "Crisper Drawer"
                self.shelfLifeDays = 5
            }
            // Meat
            else if name.contains("chicken") || name.contains("beef") || name.contains("pork") ||
                    name.contains("lamb") || name.contains("turkey") || name.contains("ham") ||
                    name.contains("bacon") || name.contains("sausage") || name.contains("fish") ||
                    name.contains("salmon") || name.contains("tuna") || name.contains("shrimp") ||
                    name.contains("crab") || name.contains("lobster") || name.contains("meat") {
                self.category = .meat
                self.location = "Bottom Shelf"
                self.shelfLifeDays = 3
            }
            // Beverages
            else if name.contains("juice") || name.contains("soda") || name.contains("water") ||
                    name.contains("beer") || name.contains("wine") || name.contains("coffee") ||
                    name.contains("tea") || name.contains("smoothie") || name.contains("energy drink") ||
                    name.contains("sports drink") || name.contains("coconut water") {
                self.category = .beverages
                self.location = "Door Shelf"
                self.shelfLifeDays = 14
            }
            // Pantry items
            else if name.contains("bread") || name.contains("cereal") || name.contains("pasta") ||
                    name.contains("rice") || name.contains("flour") || name.contains("sugar") ||
                    name.contains("salt") || name.contains("pepper") || name.contains("spice") ||
                    name.contains("herb") || name.contains("oil") || name.contains("vinegar") ||
                    name.contains("sauce") || name.contains("soup") || name.contains("canned") ||
                    name.contains("jar") || name.contains("box") || name.contains("bag") {
                self.category = .pantry
                self.location = "Pantry"
                self.shelfLifeDays = 30
            }
            // Frozen items
            else if name.contains("frozen") || name.contains("ice cream") || name.contains("frozen") ||
                    name.contains("frozen fruit") || name.contains("frozen vegetable") ||
                    name.contains("frozen meal") || name.contains("frozen pizza") {
                self.category = .frozen
                self.location = "Freezer"
                self.shelfLifeDays = 90
            }
            // Leftovers
            else if name.contains("leftover") || name.contains("cooked") || name.contains("prepared") ||
                    name.contains("meal") || name.contains("dinner") || name.contains("lunch") {
                self.category = .leftovers
                self.location = "Top Shelf"
                self.shelfLifeDays = 3
            }
            // Condiments
            else if name.contains("ketchup") || name.contains("mustard") || name.contains("mayo") ||
                    name.contains("mayonnaise") || name.contains("relish") || name.contains("pickle") ||
                    name.contains("jam") || name.contains("jelly") || name.contains("honey") ||
                    name.contains("syrup") || name.contains("dressing") || name.contains("salsa") {
                self.category = .condiments
                self.location = "Door Shelf"
                self.shelfLifeDays = 30
            }
            // Default fallback
            else {
                self.category = .other
                self.location = "Middle Shelf"
                self.shelfLifeDays = 7
            }
            
            // Initialize unit with default value first
            self.unit = item.unit
            
            // Smart unit detection based on item name and category
            self.unit = detectUnitFromName(item.name, category: self.category.rawValue)
            
            // Smart quantity detection based on item name, category, and unit
            self.quantity = detectQuantityFromName(item.name, category: self.category.rawValue, unit: self.unit)
            
            print("🎯 Auto-selected category: \(self.category.rawValue) for shopping item: \(item.name)")
            print("🎯 Auto-selected unit: \(self.unit) for shopping item: \(item.name)")
            print("🎯 Auto-selected quantity: \(self.quantity) for shopping item: \(item.name)")
        }
        
        // Smart unit detection function
        private func detectUnitFromName(_ name: String, category: String) -> String {
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
                return "g"
            }
            
            // Large weight items (typically sold by kg)
            else if itemName.contains("watermelon") || itemName.contains("pumpkin") || itemName.contains("cabbage") ||
                    itemName.contains("large") || itemName.contains("whole") {
                return "kg"
            }
            
            // Liquid items (typically sold in bottles)
            else if itemName.contains("milk") || itemName.contains("juice") || itemName.contains("soda") ||
                    itemName.contains("water") || itemName.contains("oil") || itemName.contains("vinegar") ||
                    itemName.contains("sauce") || itemName.contains("dressing") || itemName.contains("syrup") ||
                    itemName.contains("honey") || itemName.contains("wine") || itemName.contains("beer") ||
                    itemName.contains("soup") || itemName.contains("broth") {
                return "bottles"
            }
            
            // Packaged items
            else if itemName.contains("yogurt") || itemName.contains("cream") || itemName.contains("sour cream") ||
                    itemName.contains("cottage") || itemName.contains("eggs") ||
                    itemName.contains("tofu") || itemName.contains("tempeh") {
                return "packs"
            }
            
            // Canned items
            else if itemName.contains("canned") || itemName.contains("beans") || itemName.contains("corn") ||
                    itemName.contains("tomatoes") || itemName.contains("soup") || itemName.contains("tuna") ||
                    itemName.contains("sardines") || itemName.contains("olives") || itemName.contains("pickles") {
                return "cans"
            }
            
            // Packaged/pre-packaged items
            else if itemName.contains("bread") || itemName.contains("bagels") || itemName.contains("muffins") ||
                    itemName.contains("crackers") || itemName.contains("cookies") || itemName.contains("chips") ||
                    itemName.contains("cereal") || itemName.contains("granola") || itemName.contains("bars") ||
                    itemName.contains("frozen") || itemName.contains("pizza") || itemName.contains("dumplings") ||
                    itemName.contains("wraps") || itemName.contains("tortillas") || itemName.contains("pita") ||
                    itemName.contains("spinach") || itemName.contains("lettuce") || itemName.contains("arugula") ||
                    itemName.contains("kale") || itemName.contains("herbs") || itemName.contains("mushrooms") {
                return "packs"
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
                return "pieces"
            }
            
            // Category-based fallbacks
            else if itemCategory.contains("meat") || itemCategory.contains("dairy") {
                return "g"
            }
            else if itemCategory.contains("beverages") {
                return "bottles"
            }
            else if itemCategory.contains("fruits") || itemCategory.contains("vegetables") {
                return "pieces"
            }
            else if itemCategory.contains("pantry") {
                return "packs"
            }
            
            // Default fallback
            else {
                return "pieces"
            }
        }
        
        // Smart quantity detection function
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
                    showingSuccess = true
                    
                    // Auto-dismiss after showing success modal
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onComplete(selectedItems)
                    }
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
