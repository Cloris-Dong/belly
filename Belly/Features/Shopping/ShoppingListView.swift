//
//  ShoppingListView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import CoreData

struct ShoppingListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ShoppingListViewModel()
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GroceryItem.isPurchased, ascending: true),
            NSSortDescriptor(keyPath: \GroceryItem.dateAdded, ascending: false)
        ],
        animation: .default)
    private var groceryItems: FetchedResults<GroceryItem>
    
    @State private var showingAddItem = false
    @State private var searchText = ""
    @State private var selectedFilter = ShoppingFilter.all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Shopping Stats
                if !groceryItems.isEmpty {
                    ShoppingStatsView(groceryItems: Array(groceryItems))
                        .standardPadding()
                }
                
                // Filter and Search
                filterAndSearchBar
                
                // Grocery Items List
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    groceryItemsList
                }
                
                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Shopping List")
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
                AddGroceryItemView()
            }
        }
        .searchable(text: $searchText, prompt: "Search items...")
    }
    
    // MARK: - Filter and Search Bar
    
    private var filterAndSearchBar: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(ShoppingFilter.allCases, id: \.self) { filter in
                    Text(filter.title)
                        .tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .standardPadding()
    }
    
    // MARK: - Filtered Items
    
    private var filteredItems: [GroceryItem] {
        let filtered = switch selectedFilter {
        case .all:
            Array(groceryItems)
        case .needed:
            groceryItems.filter { !$0.isPurchased }
        case .purchased:
            groceryItems.filter { $0.isPurchased }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { $0.matches(searchQuery: searchText) }
        }
    }
    
    // MARK: - Grocery Items List
    
    private var groceryItemsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.itemSpacing) {
                ForEach(filteredItems, id: \.id) { item in
                    GroceryItemRow(item: item) {
                        togglePurchased(item)
                    }
                    .standardPadding()
                }
                .onDelete(perform: deleteItems)
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "cart")
                .font(.system(size: DesignSystem.Icons.extraLarge))
                .foregroundColor(.oceanBlue)
            
            Text(emptyStateTitle)
                .font(DesignSystem.Typography.title2)
                .foregroundColor(.primaryText)
            
            Text(emptyStateMessage)
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            if selectedFilter == .all {
                Button("Add Your First Item") {
                    showingAddItem = true
                }
                .buttonStyle(backgroundColor: .oceanBlue, foregroundColor: .white)
                .standardPadding()
            }
        }
        .largePadding()
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all:
            return "Your Shopping List is Empty"
        case .needed:
            return "Nothing to Buy"
        case .purchased:
            return "No Purchased Items"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "Add items to your shopping list to keep track of what you need to buy"
        case .needed:
            return "All items on your list have been purchased!"
        case .purchased:
            return "Items you mark as purchased will appear here"
        }
    }
    
    // MARK: - Actions
    
    private func togglePurchased(_ item: GroceryItem) {
        withAnimation(.spring()) {
            item.togglePurchased()
            
            do {
                try viewContext.save()
            } catch {
                // Handle error
                print("Error saving context: \(error)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredItems[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle error
                print("Error saving context: \(error)")
            }
        }
    }
}

// MARK: - Shopping Filter Enum

enum ShoppingFilter: String, CaseIterable {
    case all = "all"
    case needed = "needed"
    case purchased = "purchased"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .needed: return "Need to Buy"
        case .purchased: return "Purchased"
        }
    }
}

// MARK: - Shopping Stats View

struct ShoppingStatsView: View {
    let groceryItems: [GroceryItem]
    
    private var stats: (total: Int, needed: Int, purchased: Int) {
        let total = groceryItems.count
        let needed = groceryItems.filter { !$0.isPurchased }.count
        let purchased = groceryItems.filter { $0.isPurchased }.count
        
        return (total, needed, purchased)
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatCard(title: "Total", value: stats.total, color: .oceanBlue)
            StatCard(title: "Need to Buy", value: stats.needed, color: .warning)
            StatCard(title: "Purchased", value: stats.purchased, color: .success)
        }
    }
}

// MARK: - Grocery Item Row

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPurchased ? .success : .borderColor)
                    .font(.system(size: DesignSystem.Icons.standard))
            }
            
            // Category Color Indicator
            Rectangle()
                .fill(Color.categoryColor(for: item.foodCategory))
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(item.name)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(item.isPurchased ? .secondaryText : .primaryText)
                    .strikethrough(item.isPurchased)
                
                HStack {
                    Text(item.foodCategory.displayName)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(.secondaryText)
                    
                    Spacer()
                    
                    Text(item.addedDateText)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(.tertiaryText)
                }
            }
            
            Spacer()
            
            // Status Badge
            if item.isPurchased {
                Text("✓")
                    .badgeStyle(backgroundColor: .success, foregroundColor: .white)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
        .opacity(item.isPurchased ? 0.7 : 1.0)
    }
}

// MARK: - Add Grocery Item View

struct AddGroceryItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var selectedCategory = FoodCategory.other
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                // Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: DesignSystem.Icons.extraLarge))
                        .foregroundColor(.oceanBlue)
                    
                    Text("Add to Shopping List")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(.primaryText)
                }
                
                // Form
                VStack(spacing: DesignSystem.Spacing.lg) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Item Name")
                            .font(DesignSystem.Typography.calloutEmphasized)
                            .foregroundColor(.primaryText)
                        
                        TextField("Enter item name", text: $itemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Category")
                            .font(DesignSystem.Typography.calloutEmphasized)
                            .foregroundColor(.primaryText)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(FoodCategory.allCases, id: \.self) { category in
                                HStack {
                                    Text(category.emoji)
                                    Text(category.displayName)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .largePadding()
                .cardStyle()
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: DesignSystem.Spacing.md) {
                    Button("Add to List") {
                        addItem()
                    }
                    .buttonStyle(backgroundColor: .oceanBlue, foregroundColor: .white)
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(.oceanBlue)
                }
            }
            .standardPadding()
            .background(Color.appBackground)
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.oceanBlue)
                }
            }
        }
    }
    
    private func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else { return }
        
        _ = GroceryItem.create(
            in: viewContext,
            name: trimmedName,
            category: selectedCategory
        )
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            // Handle error
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - View Model

class ShoppingListViewModel: ObservableObject {
    @Published var selectedFilter: ShoppingFilter = .all
    @Published var searchText = ""
    @Published var isLoading = false
    
    // Add your business logic here
}

// MARK: - Preview

#Preview {
    ShoppingListView()
        .environment(\.managedObjectContext, PreviewHelper.createPreviewContext())
}

#Preview("Add Item") {
    AddGroceryItemView()
        .environment(\.managedObjectContext, PreviewHelper.createPreviewContext())
}
