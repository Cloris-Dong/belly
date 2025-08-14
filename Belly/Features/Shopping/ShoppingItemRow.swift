//
//  ShoppingItemRow.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct ShoppingItemRow: View {
    @ObservedObject var item: GroceryItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    @State private var isEditing = false
    @State private var editedName: String = ""
    
    var body: some View {
        HStack {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPurchased ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Item Content
            if isEditing {
                TextField("Item name", text: $editedName)
                    .onSubmit {
                        item.updateFromText(editedName)
                        isEditing = false
                    }
                    .textFieldStyle(.roundedBorder)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayText)
                        .font(.body)
                        .strikethrough(item.isPurchased)
                        .foregroundColor(item.isPurchased ? .secondary : .primary)
                }
                .onTapGesture {
                    editedName = item.displayText
                    isEditing = true
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            Rectangle()
                .fill(isEditing ? Color.blue.opacity(0.05) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isEditing)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ShoppingItemRow(
            item: GroceryItem(text: "Milk 2 liters"),
            onToggle: {},
            onDelete: {}
        )
        
        ShoppingItemRow(
            item: GroceryItem(text: "5 apples"),
            onToggle: {},
            onDelete: {}
        )
        
        ShoppingItemRow(
            item: GroceryItem(text: "Bread", isPurchased: true),
            onToggle: {},
            onDelete: {}
        )
    }
    .padding()
}
