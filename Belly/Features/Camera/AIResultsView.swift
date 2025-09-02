//
//  AIResultsView.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct AIResultsView: View {
    @Binding var detectedItems: [DetectedFood]
    @StateObject private var fridgeViewModel = FridgeViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingToFridge = false
    @State private var showingSuccessAlert = false
    @State private var showingRecipes = false
    @State private var generatedRecipes: [Recipe] = []
    @State private var isGeneratingRecipes = false
    @StateObject private var aiManager = AIManager()
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Review & Confirm")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("\(detectedItems.count) item\(detectedItems.count == 1 ? "" : "s") detected")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Add Another") {
                            addBlankItem()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.oceanBlue)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
                .background(Color(.systemBackground))
                
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
                            
                            // Add Another Item Button
                            Button("Add Another Item") {
                                addBlankItem()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(12)
                            
                            // Recipe Generation Section
                            VStack(spacing: 12) {
                                Divider()
                                    .padding(.vertical)
                                
                                Text("Get Recipe Ideas")
                                    .font(.headline)
                                
                                Text("Generate recipes using these ingredients")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button(action: generateRecipes) {
                                    HStack {
                                        if isGeneratingRecipes {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "book.fill")
                                        }
                                        Text(isGeneratingRecipes ? "Generating..." : "Get Recipe Ideas")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(isGeneratingRecipes)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(DesignSystem.Spacing.lg)
                    }
                }
                
                Spacer()
                
                // Bottom action bar
                if !detectedItems.isEmpty {
                    bottomActionBar
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Items Added!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(detectedItems.count) item\(detectedItems.count == 1 ? "" : "s") added to your fridge.")
        }
        .sheet(isPresented: $showingRecipes) {
            RecipeModalView(recipes: generatedRecipes, isGenerating: false)
        }
        .overlay(
            Group {
                if showingSuccess {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
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
                    .foregroundColor(.primary)
                
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
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(detectedItems.count) item\(detectedItems.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Add to Fridge") {
                    addItemsToFridge()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(isAddingToFridge ? Color.gray : Color.oceanBlue)
                )
                .disabled(detectedItems.isEmpty || isAddingToFridge)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(Color(.systemBackground))
        }
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
        for detectedItem in detectedItems {
            let foodItem = FoodItem(
                name: detectedItem.name.isEmpty ? "Unknown Item" : detectedItem.name,
                category: FoodCategory.allCases.first { $0.rawValue == detectedItem.category } ?? .other,
                quantity: detectedItem.quantity, // Use quantity from DetectedFood
                unit: FoodUnit.allCases.first { $0.rawValue == detectedItem.unit } ?? .pieces, // Use unit from DetectedFood
                expirationDate: Calendar.current.date(byAdding: .day, value: detectedItem.shelfLifeDays, to: Date()) ?? Date(),
                dateAdded: Date(),
                zoneTag: detectedItem.location, // Save location as zoneTag
                storage: detectedItem.storage
            )
            
            // Add to fridge view model (mock data for now)
            // TODO: Integrate with real Core Data when available
            print("Adding to fridge: \(detectedItem.name)")
        }
        
        // Show success animation
        showSuccessAnimation()
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    private func generateRecipes() {
        isGeneratingRecipes = true
        let ingredients = detectedItems.map { $0.name }
        
        Task {
            let recipes = await aiManager.generateRecipesMock(from: ingredients)
            
            await MainActor.run {
                self.generatedRecipes = recipes
                self.isGeneratingRecipes = false
                self.showingRecipes = true
            }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header with confidence indicator
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Food name", text: $item.name)
                        .font(.headline)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        confidenceBadge
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(item.confidencePercentage)% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.softCoral)
                        .font(.subheadline)
                }
                .frame(width: 44, height: 44)
            }
            
            // Form fields
            VStack(spacing: DesignSystem.Spacing.md) {
                // Category picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Picker("Category", selection: $item.category) {
                        ForEach(FoodCategory.allCases, id: \.rawValue) { category in
                            Text(category.emoji + "  " + category.rawValue)
                                .tag(category.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                
                // Shelf life and quantity
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Shelf life
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Shelf Life")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Stepper("\(item.shelfLifeDays) days", value: $item.shelfLifeDays, in: 1...365)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    // Quantity and unit
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantity")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            TextField("Qty", value: $item.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                            
                            Picker("Unit", selection: $item.unit) {
                                ForEach(FoodUnit.allCases, id: \.rawValue) { unit in
                                    Text(unit.rawValue).tag(unit.rawValue)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                        }
                    }
                }
                
                // Location picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
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
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
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
    }
    
    // MARK: - Confidence Badge
    
    private var confidenceBadge: some View {
        Text(item.confidenceColor)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(confidenceColor)
            )
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
