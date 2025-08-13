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
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
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
        .environment(\.managedObjectContext, PreviewHelper.createPreviewContext())
}
