//
//  NewItemRow.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct NewItemRow: View {
    let onAdd: (String) -> Void
    
    @State private var newItemText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Empty checkbox placeholder
            Circle()
                .stroke(Color.secondary, lineWidth: 1)
                .frame(width: 24, height: 24)
                .opacity(0.3)
            
            // New item text field
            TextField("Add item...", text: $newItemText)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .onSubmit {
                    addItem()
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
    }
    
    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onAdd(trimmed)
            newItemText = ""
            isFocused = false
        }
    }
}

#Preview {
    NewItemRow { text in
        print("Adding: \(text)")
    }
    .padding()
}
