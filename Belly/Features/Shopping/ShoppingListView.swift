//
//  ShoppingListView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct ShoppingListView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Shopping List")
                    .font(.largeTitle)
                    .padding()
                
                Text("Core Data model integration coming soon...")
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Shopping")
        }
    }
}

#Preview {
    ShoppingListView()
}
