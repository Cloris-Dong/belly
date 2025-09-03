//
//  EditItemView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct EditItemView: View {
    @Binding var item: FoodItem
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    
    @State private var editedName: String
    @State private var editedCategory: FoodCategory
    @State private var editedQuantity: Double
    @State private var editedUnit: FoodUnit
    @State private var editedExpirationDate: Date
    @State private var editedZoneTag: String
    @State private var editedStorage: String
    @State private var showingDeleteConfirmation = false
    @State private var showingAddLocation = false
    @State private var newLocation = ""
    
    let onSave: (ItemUpdate) -> Void
    let onDelete: () -> Void
    
    init(item: Binding<FoodItem>, onSave: @escaping (ItemUpdate) -> Void, onDelete: @escaping () -> Void) {
        self._item = item
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Initialize state with current item values
        self._editedName = State(initialValue: item.wrappedValue.name)
        self._editedCategory = State(initialValue: item.wrappedValue.category)
        self._editedQuantity = State(initialValue: item.wrappedValue.quantity)
        self._editedUnit = State(initialValue: item.wrappedValue.unit)
        self._editedExpirationDate = State(initialValue: item.wrappedValue.expirationDate)
        self._editedZoneTag = State(initialValue: item.wrappedValue.zoneTag ?? "")
        self._editedStorage = State(initialValue: item.wrappedValue.storage)
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
                    
                    Text("Edit Item")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Button(action: {
                        saveChanges()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .background(
                    Color.appBackground
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                )
                
                // Main Content
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Item Card
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            // Item name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Food Name")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.oceanBlue)
                                        .frame(width: 20)
                                    
                                    TextField("Item name", text: $editedName)
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
                            }
                            
                            // Category section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                Button(action: {
                                    // The picker will automatically show when tapped
                                }) {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.oceanBlue)
                                            .frame(width: 20)
                                        
                                        Picker("Category", selection: $editedCategory) {
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
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Quantity section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quantity")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                HStack {
                                    Image(systemName: "number.square.fill")
                                        .foregroundColor(.oceanBlue)
                                        .frame(width: 20)
                                    
                                    TextField("Quantity", value: $editedQuantity, format: .number)
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
                                    
                                    Picker("Unit", selection: $editedUnit) {
                                        ForEach(FoodUnit.allCases) { unit in
                                            Text(unit.displayName).tag(unit)
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
                            
                            // Expiration section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Expiration")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.warmAmber)
                                        .frame(width: 20)
                                    
                                    DatePicker(
                                        "Expires on",
                                        selection: $editedExpirationDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                                
                                // Expiration status indicator
                                HStack {
                                    Image(systemName: expirationStatusIcon)
                                        .foregroundColor(expirationStatusColor)
                                        .frame(width: 20)
                                    
                                    Text(expirationStatusText)
                                        .foregroundColor(expirationStatusColor)
                                        .font(.caption)
                                    
                                    Spacer()
                                }
                            }
                            
                            // Location section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Location")
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                
                                Picker("Location", selection: $editedStorage) {
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
                                .onChange(of: editedStorage) { newValue in
                                    if newValue == "add_new" {
                                        showingAddLocation = true
                                        editedStorage = locationManager.allLocations.first ?? "Middle Shelf"
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
                        
                        // Circular Remove Item Button
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.softCoral)
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
            .alert("Remove Item", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to remove '\(item.name)' from your fridge?")
            }
            .alert("Add New Location", isPresented: $showingAddLocation) {
                TextField("Location name", text: $newLocation)
                Button("Add") {
                    locationManager.addLocation(newLocation)
                    editedStorage = newLocation
                    newLocation = ""
                }
                Button("Cancel", role: .cancel) { 
                    newLocation = ""
                }
            } message: {
                Text("Enter a name for the new storage location")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveChanges() {
        let updates = ItemUpdate(
            name: editedName != item.name ? editedName : nil,
            category: editedCategory != item.category ? editedCategory : nil,
            quantity: editedQuantity != item.quantity ? editedQuantity : nil,
            unit: editedUnit != item.unit ? editedUnit : nil,
            expirationDate: editedExpirationDate != item.expirationDate ? editedExpirationDate : nil,
            zoneTag: editedZoneTag != (item.zoneTag ?? "") ? (editedZoneTag.isEmpty ? nil : editedZoneTag) : nil,
            storage: editedStorage != item.storage ? editedStorage : nil
        )
        
        onSave(updates)
        dismiss()
    }
    
    private var isFormValid: Bool {
        return !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               editedQuantity > 0
    }
    
    // MARK: - Expiration Status
    
    private var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: editedExpirationDate).day ?? 0
    }
    
    private var expirationStatusIcon: String {
        if daysUntilExpiration < 0 {
            return "exclamationmark.triangle.fill"
        } else if daysUntilExpiration <= 3 {
            return "clock.badge.exclamationmark.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var expirationStatusColor: Color {
        if daysUntilExpiration < 0 {
            return .red
        } else if daysUntilExpiration <= 1 {
            return .softCoral
        } else if daysUntilExpiration <= 3 {
            return .warmAmber
        } else {
            return .sageGreen
        }
    }
    
    private var expirationStatusText: String {
        if daysUntilExpiration < 0 {
            let daysExpired = abs(daysUntilExpiration)
            return daysExpired == 1 ? "Expired 1 day ago" : "Expired \(daysExpired) days ago"
        } else if daysUntilExpiration == 0 {
            return "Expires today"
        } else if daysUntilExpiration == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(daysUntilExpiration) days"
        }
    }
}

// MARK: - Previews

#Preview("Edit Item") {
    let sampleItem = Binding.constant(
        FoodItem(
            name: "Greek Yogurt",
            category: .dairy,
            quantity: 1,
            unit: .packages,
            expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            zoneTag: "Middle shelf"
        )
    )
    
    return EditItemView(
        item: sampleItem,
        onSave: { _ in },
        onDelete: { }
    )
}
