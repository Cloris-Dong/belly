//
//  FridgeView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import CoreData

struct FridgeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.expirationDate, ascending: true)],
        animation: .default)
    private var foodItems: FetchedResults<FoodItem>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.oceanBlue)
                
                Text("Fridge Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("Welcome to your fridge management dashboard")
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Show item count
                VStack(spacing: 8) {
                    Text("Current Items")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text("\(foodItems.count)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.oceanBlue)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .shadow(radius: 2)
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Fridge")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    FridgeView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
