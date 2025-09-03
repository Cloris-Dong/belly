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

    @StateObject private var aiManager = AIManager()
    @State private var showingSuccess = false
    
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
            .background(Color.appBackground)
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
                        
                        DatePicker("", selection: Binding(
                            get: { item.expirationDate },
                            set: { newDate in
                                let calendar = Calendar.current
                                let today = calendar.startOfDay(for: Date())
                                let selectedDate = calendar.startOfDay(for: newDate)
                                let daysDifference = calendar.dateComponents([.day], from: today, to: selectedDate).day ?? 0
                                item.shelfLifeDays = max(1, daysDifference)
                            }
                        ), in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .frame(height: 100)
                
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
