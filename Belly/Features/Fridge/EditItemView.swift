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
    
    @State private var editedName: String
    @State private var editedCategory: FoodCategory
    @State private var editedQuantity: Double
    @State private var editedUnit: FoodUnit
    @State private var editedExpirationDate: Date
    @State private var editedZoneTag: String
    @State private var showingDeleteConfirmation = false
    
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
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Item Details") {
                    // Name field
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.oceanBlue)
                            .frame(width: 20)
                        
                        TextField("Item name", text: $editedName)
                            .textFieldStyle(.plain)
                    }
                    
                    // Category picker
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.oceanBlue)
                            .frame(width: 20)
                        
                        Picker("Category", selection: $editedCategory) {
                            ForEach(FoodCategory.allCases) { category in
                                HStack {
                                    Text(category.emoji)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Quantity and unit
                    HStack {
                        Image(systemName: "number.square.fill")
                            .foregroundColor(.oceanBlue)
                            .frame(width: 20)
                        
                        TextField("Quantity", value: $editedQuantity, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                            .frame(maxWidth: 80)
                        
                        Picker("Unit", selection: $editedUnit) {
                            ForEach(FoodUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Expiration Section
                Section("Expiration") {
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
                
                // Location Section
                Section("Storage Location") {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.sageGreen)
                            .frame(width: 20)
                        
                        TextField("Zone tag (optional)", text: $editedZoneTag)
                            .textFieldStyle(.plain)
                    }
                }
                
                // Actions Section
                Section {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Remove Item")
                        }
                        .foregroundColor(.softCoral)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .alert("Remove Item", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to remove '\(item.name)' from your fridge?")
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
            zoneTag: editedZoneTag != (item.zoneTag ?? "") ? (editedZoneTag.isEmpty ? nil : editedZoneTag) : nil
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
