//
//  NewItemRow.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct NewItemRow: View {
    let onAdd: (String, Double, String) -> Void
    
    @State private var newItemName = ""
    @State private var newQuantity: Double = 1.0
    @State private var newUnit = "pieces"
    @FocusState private var isNameFocused: Bool
    @FocusState private var isQuantityFocused: Bool
    
    // Computed property to check if any field is focused
    var isAnyFieldFocused: Bool {
        isNameFocused || isQuantityFocused
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Empty circle
            Image(systemName: "plus.circle")
                .foregroundColor(.primaryText)
                .font(.title3)
            
            VStack(spacing: 8) {
                // Item name row
                TextField("Add new item...", text: $newItemName)
                    .focused($isNameFocused)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundColor(.primaryText)
                    .onSubmit {
                        addItem()
                    }
                
                // Quantity and unit row
                HStack(spacing: 8) {
                    // Quantity input
                    HStack {
                        Text("Qty:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("1", value: $newQuantity, format: .number)
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
                                            .stroke(isQuantityFocused ? Color.primaryText : Color.clear, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Unit selector
                    HStack {
                        Text("Unit:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            ForEach(["pieces", "kg", "g", "liters", "bottles", "packs", "cans", "boxes"], id: \.self) { unit in
                                Button(unit) {
                                    newUnit = unit
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(newUnit)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                                
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
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                .foregroundColor(.primaryText.opacity(0.3))
        )
        .onTapGesture {
            isNameFocused = true
        }
        .onChange(of: isAnyFieldFocused) { isFocused in
            // When focus is lost and there's text to add, automatically add the item
            if !isFocused && !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                addItem()
            }
        }
    }
    
    private func addItem() {
        let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            onAdd(trimmedName, newQuantity, newUnit)
            
            // Reset form
            newItemName = ""
            newQuantity = 1.0
            newUnit = "pieces"
        }
    }
}

#Preview {
    NewItemRow { name, quantity, unit in
        print("Adding: \(name) \(quantity) \(unit)")
    }
    .padding()
}
