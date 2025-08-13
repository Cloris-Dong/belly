//
//  AddView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import CoreData

struct AddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.oceanBlue)
                
                Text("Add Items")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("Add new food items to your fridge")
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    // Add options
                    AddOptionButton(
                        title: "Take Photo",
                        icon: "camera.fill",
                        color: .oceanBlue
                    ) {
                        showingAlert = true
                    }
                    
                    AddOptionButton(
                        title: "Scan Barcode",
                        icon: "barcode.viewfinder",
                        color: .oceanBlue
                    ) {
                        showingAlert = true
                    }
                    
                    AddOptionButton(
                        title: "Manual Entry",
                        icon: "pencil",
                        color: .oceanBlue
                    ) {
                        addSampleItem()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Add Items")
            .navigationBarTitleDisplayMode(.large)
            .alert("Coming Soon", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text("This feature will be available in a future update.")
            }
        }
    }
    
    private func addSampleItem() {
        let newItem = FoodItem.create(
            in: viewContext,
            name: "Sample Item \(Int.random(in: 1...100))",
            category: .other,
            quantity: 1.0,
            unit: .pieces,
            expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving item: \(error)")
        }
    }
}

struct AddOptionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
