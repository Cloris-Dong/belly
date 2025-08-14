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
            confidence: 1.0
        )
        detectedItems.append(newItem)
    }
    
    private func addItemsToFridge() {
        isAddingToFridge = true
        
        // Convert detected items to FoodItems and add to fridge
        for detectedItem in detectedItems {
            let foodItem = FoodItem(
                name: detectedItem.name.isEmpty ? "Unknown Item" : detectedItem.name,
                category: FoodCategory.allCases.first { $0.rawValue == detectedItem.category } ?? .other,
                quantity: 1.0,
                unit: .pieces,
                expirationDate: Calendar.current.date(byAdding: .day, value: detectedItem.shelfLifeDays, to: Date()) ?? Date(),
                dateAdded: Date(),
                zoneTag: nil,
                storage: detectedItem.storage
            )
            
            // Add to fridge view model (mock data for now)
            // TODO: Integrate with real Core Data when available
        }
        
        // Show success and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingSuccessAlert = true
            isAddingToFridge = false
        }
    }
}

// MARK: - Detected Item Card

struct DetectedItemCard: View {
    @Binding var item: DetectedFood
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
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
                            Text(category.rawValue).tag(category.rawValue)
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
                
                // Shelf life and storage
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
                    
                    // Storage location
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Storage")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Picker("Storage", selection: $item.storage) {
                            ForEach(StorageLocation.allCases, id: \.rawValue) { location in
                                Text(location.rawValue).tag(location.rawValue)
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
            DetectedFood(name: "Organic Spinach", category: "Vegetables", shelfLifeDays: 5, storage: "Refrigerator", confidence: 0.92),
            DetectedFood(name: "Red Bell Pepper", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", confidence: 0.88)
        ])
    )
}
