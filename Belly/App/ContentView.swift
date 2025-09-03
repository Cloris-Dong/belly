//
//  ContentView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Fridge Tab
            FridgeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Fridge")
                }
                .tag(0)
            
            // Add Tab
            AddItemView()
                .tabItem {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                    Text("Add")
                }
                .tag(1)
            
            // Shopping Tab
            ShoppingListView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shopping")
                }
                .tag(2)
        }
        .accentColor(.oceanBlue)
        .background(Color.appBackground)
        .onAppear {
            setupTabBarAppearance()
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 8)
        }
    }
    
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.appBackground)
        
        // Configure selected tab item
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.oceanBlue)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.oceanBlue)
        ]
        
        // Configure normal tab item
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
