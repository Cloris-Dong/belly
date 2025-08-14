//
//  SimpleShoppingRow.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct SimpleShoppingRow: View {
    @ObservedObject var item: GroceryItem
    let onTogglePurchased: () -> Void
    let onUpdate: (String) -> Void
    let onDelete: () -> Void
    
    @State private var editedText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Simple checkbox
            Button(action: onTogglePurchased) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPurchased ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Editable text field (tap anywhere to edit)
            TextField("Add item...", text: $editedText)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .strikethrough(item.isPurchased)
                .foregroundColor(item.isPurchased ? .secondary : .primary)
                .onSubmit {
                    updateItem()
                }
                .onChange(of: isFocused) { focused in
                    if !focused {
                        updateItem()
                    }
                }
                .onTapGesture {
                    isFocused = true
                }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            Rectangle()
                .fill(isFocused ? Color.blue.opacity(0.05) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", role: .destructive, action: onDelete)
        }
        .onAppear {
            editedText = item.displayText
        }
    }
    
    private func updateItem() {
        if !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onUpdate(editedText)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        SimpleShoppingRow(
            item: GroceryItem(text: "Milk 2 liters"),
            onTogglePurchased: {},
            onUpdate: { _ in },
            onDelete: {}
        )
        
        SimpleShoppingRow(
            item: GroceryItem(text: "5 apples"),
            onTogglePurchased: {},
            onUpdate: { _ in },
            onDelete: {}
        )
        
        SimpleShoppingRow(
            item: GroceryItem(text: "Bread", isPurchased: true),
            onTogglePurchased: {},
            onUpdate: { _ in },
            onDelete: {}
        )
    }
    .padding()
}
