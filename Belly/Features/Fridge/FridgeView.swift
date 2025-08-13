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
    @StateObject private var viewModel = FridgeViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.expirationDate, ascending: true)],
        animation: .default)
    private var foodItems: FetchedResults<FoodItem>
    
    @State private var selectedFilter = FridgeFilter.all
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Stats
                FridgeStatsView(foodItems: Array(foodItems))
                    .standardPadding()
                
                // Filter Segment
                filterSegmentControl
                    .standardPadding()
                
                // Food Items List
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    foodItemsList
                }
                
                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Fridge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: DesignSystem.Icons.add)
                            .foregroundColor(.oceanBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }
    
    // MARK: - Filter Segment Control
    
    private var filterSegmentControl: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(FridgeFilter.allCases, id: \.self) { filter in
                Text(filter.title)
                    .tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    // MARK: - Filtered Items
    
    private var filteredItems: [FoodItem] {
        switch selectedFilter {
        case .all:
            return Array(foodItems)
        case .fresh:
            return foodItems.filter { $0.isFresh }
        case .expiring:
            return foodItems.filter { $0.isExpiringSoon }
        case .expired:
            return foodItems.filter { $0.isExpired }
        }
    }
    
    // MARK: - Food Items List
    
    private var foodItemsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.itemSpacing) {
                ForEach(filteredItems, id: \.id) { item in
                    FoodItemRow(item: item)
                        .standardPadding()
                }
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "house")
                .font(.system(size: DesignSystem.Icons.extraLarge))
                .foregroundColor(.oceanBlue)
            
            Text("Your Fridge is Empty")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(.primaryText)
            
            Text("Add items using the camera tab to start tracking your food!")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Add Your First Item") {
                showingAddItem = true
            }
            .buttonStyle(backgroundColor: .oceanBlue, foregroundColor: .white)
            .standardPadding()
        }
        .largePadding()
    }
}

// MARK: - Fridge Filter Enum

enum FridgeFilter: String, CaseIterable {
    case all = "all"
    case fresh = "fresh"
    case expiring = "expiring"
    case expired = "expired"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .fresh: return "Fresh"
        case .expiring: return "Expiring"
        case .expired: return "Expired"
        }
    }
}

// MARK: - Fridge Stats View

struct FridgeStatsView: View {
    let foodItems: [FoodItem]
    
    private var stats: (total: Int, fresh: Int, expiring: Int, expired: Int) {
        let total = foodItems.count
        let fresh = foodItems.filter { $0.isFresh }.count
        let expiring = foodItems.filter { $0.isExpiringSoon }.count
        let expired = foodItems.filter { $0.isExpired }.count
        
        return (total, fresh, expiring, expired)
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatCard(title: "Total", value: stats.total, color: .oceanBlue)
            StatCard(title: "Fresh", value: stats.fresh, color: .freshFood)
            StatCard(title: "Expiring", value: stats.expiring, color: .expiringSoon)
            StatCard(title: "Expired", value: stats.expired, color: .expiredFood)
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(value)")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Food Item Row

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Category Color Indicator
            Rectangle()
                .fill(Color.categoryColor(for: item.foodCategory))
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(item.name)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.primaryText)
                
                HStack {
                    Text(item.formattedQuantity)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(.secondaryText)
                    
                    Spacer()
                    
                    Text(item.expirationStatus)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(statusColor)
                }
            }
            
            Spacer()
            
            // Status Icon
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.system(size: DesignSystem.Icons.standard))
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var statusColor: Color {
        if item.isExpired {
            return .expiredFood
        } else if item.isExpiringSoon {
            return .expiringSoon
        } else {
            return .freshFood
        }
    }
    
    private var statusIcon: String {
        if item.isExpired {
            return DesignSystem.Icons.expired
        } else if item.isExpiringSoon {
            return DesignSystem.Icons.expiring
        } else {
            return DesignSystem.Icons.fresh
        }
    }
}

// MARK: - View Model

class FridgeViewModel: ObservableObject {
    @Published var selectedFilter: FridgeFilter = .all
    @Published var searchText = ""
    @Published var isLoading = false
    
    // Add your business logic here
}

// MARK: - Preview

#Preview {
    FridgeView()
        .environment(\.managedObjectContext, PreviewHelper.createPreviewContext())
}
