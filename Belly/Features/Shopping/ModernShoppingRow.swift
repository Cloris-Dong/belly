//
//  ModernShoppingRow.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct ModernShoppingRow: View {
    @ObservedObject var item: GroceryItem
    let onTogglePurchased: () -> Void
    let onUpdate: (String, Double, String) -> Void
    let onDelete: () -> Void
    
    @State private var editedName: String = ""
    @State private var editedQuantity: Double = 1.0
    @State private var editedUnit: String = "pieces"
    @FocusState private var isNameFocused: Bool
    @FocusState private var isQuantityFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onTogglePurchased) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPurchased ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Main content area
            VStack(spacing: 8) {
                // Item name row
                TextField("Item name", text: $editedName)
                    .focused($isNameFocused)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .strikethrough(item.isPurchased)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)
                    .onSubmit {
                        updateItem()
                    }
                    .onChange(of: isNameFocused) { focused in
                        if !focused {
                            updateItem()
                        }
                    }
                
                // Quantity and unit row
                HStack(spacing: 8) {
                    // Quantity input
                    HStack {
                        Text("Qty:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("1", value: $editedQuantity, format: .number)
                            .focused($isQuantityFocused)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                            .frame(width: 50)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(isQuantityFocused ? Color.blue : Color.clear, lineWidth: 1)
                                    )
                            )
                            .onSubmit {
                                updateItem()
                            }
                            .onChange(of: isQuantityFocused) { focused in
                                if !focused {
                                    updateItem()
                                }
                            }
                    }
                    
                    // Unit selector
                    HStack {
                        Text("Unit:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            ForEach(["pieces", "kg", "g", "liters", "bottles", "packs", "cans", "boxes"], id: \.self) { unit in
                                Button(unit) {
                                    editedUnit = unit
                                    updateItem()
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(editedUnit)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .opacity(item.isPurchased ? 0.7 : 1.0)
        .scaleEffect(item.isPurchased ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: item.isPurchased)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", role: .destructive, action: onDelete)
        }
        .onAppear {
            editedName = item.name
            editedQuantity = item.quantity
            editedUnit = item.unit
        }
    }
    
    private func updateItem() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            onUpdate(trimmedName, editedQuantity, editedUnit)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ModernShoppingRow(
            item: GroceryItem(name: "Milk", quantity: 2.0, unit: "liters"),
            onTogglePurchased: {},
            onUpdate: { _, _, _ in },
            onDelete: {}
        )
        
        ModernShoppingRow(
            item: GroceryItem(name: "Apples", quantity: 5.0, unit: "pieces", isPurchased: true),
            onTogglePurchased: {},
            onUpdate: { _, _, _ in },
            onDelete: {}
        )
    }
    .padding()
}
