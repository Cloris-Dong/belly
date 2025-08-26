//
//  FridgeView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct FridgeView: View {
    @StateObject private var viewModel = FridgeViewModel()
    @State private var showingRecipes = false
    @State private var showingRemovalConfirmation = false
    @State private var itemToEdit: FoodItem?
    @State private var itemToRemove: FoodItem?
    @State private var removalReason: RemovalReason = .consumed
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    // Expired Section (if any expired items exist)
                    if !viewModel.expiredItems.isEmpty {
                        expiredSection
                    }
                    
                    // Expiring Soon Section
                    expiringSoonSection
                    
                    // Food Categories Section
                    categoriesSection
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.sm)
            }
            .background(Color.appBackground)
            .navigationTitle("Fridge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.foodItems.isEmpty {
                        Button(isSelectionMode ? "Done" : "Select") {
                            toggleSelectionMode()
                        }
                        .foregroundColor(.oceanBlue)
                    }
                }
            }
            .refreshable {
                viewModel.refresh()
            }
            .sheet(item: $itemToEdit) { item in
                EditItemView(
                    item: Binding(
                        get: { item },
                        set: { _ in }
                    ),
                    onSave: { updates in
                        viewModel.updateItem(item, with: updates)
                        itemToEdit = nil
                    },
                    onDelete: {
                        viewModel.removeItem(item, reason: .wasted)
                        itemToEdit = nil
                    }
                )
            }
            .sheet(isPresented: $showingRecipes) {
                RecipeModalView(
                    recipes: viewModel.generateRecipes(),
                    isGenerating: viewModel.isGeneratingRecipes
                )
            }
            .alert("Remove Item", isPresented: $showingRemovalConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Used it up", role: .none) {
                    if let item = itemToRemove {
                        viewModel.removeItem(item, reason: .consumed)
                    }
                }
                Button("Had to toss it", role: .destructive) {
                    if let item = itemToRemove {
                        viewModel.removeItem(item, reason: .wasted)
                    }
                }
            } message: {
                if let item = itemToRemove {
                    Text("How did you use '\(item.name)'?")
                }
            }
            .overlay(alignment: .bottom) {
                if isSelectionMode && !selectedItems.isEmpty {
                    selectionActionBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .toolbar(isSelectionMode ? .hidden : .visible, for: .tabBar)
            .animation(.easeInOut, value: isSelectionMode)
        }
    }
    
    // MARK: - Selection Management
    
    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedItems.removeAll()
        }
    }
    
    private func toggleItemSelection(_ item: FoodItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func removeSelectedItems() {
        let itemsToRemove = viewModel.foodItems.filter { selectedItems.contains($0.id) }
        viewModel.removeItems(itemsToRemove, reason: .wasted)
        selectedItems.removeAll()
        isSelectionMode = false
    }
    
    // MARK: - Expired Section
    
    private var expiredSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expired")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.expiredItemsCount) items need to be removed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats and delete all button
                if viewModel.expiredItemsCount > 0 {
                    HStack(spacing: 8) {
                        // Delete all expired items button
                        Button(action: {
                            viewModel.removeItems(viewModel.expiredItems, reason: .wasted)
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                        
                        // Expired badge
                        expiredBadge
                    }
                }
            }
            
            // Horizontal scroll of expired items
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.lg) {
                    ForEach(viewModel.expiredItems) { item in
                        ExpiredItemCard(
                            item: item,
                            isSelectionMode: isSelectionMode,
                            isSelected: selectedItems.contains(item.id),
                            onEdit: { itemToEdit = item },
                            onRemove: { viewModel.removeItem(item, reason: .wasted) },
                            onToggleSelection: { toggleItemSelection(item) }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .padding(.horizontal, -DesignSystem.Spacing.lg)
            .frame(minHeight: 160)
        }
    }
    
    private var expiredBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.red)
            
            Text("\(viewModel.expiredItemsCount)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
        )
    }
    
    // MARK: - Expiring Soon Section
    
    private var expiringSoonSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expiring Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.expiringItemsCount) items need attention")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats
                if viewModel.expiringItemsCount > 0 {
                    HStack(spacing: 8) {
                        expiringBadge
                    }
                }
            }
            
            // Expiring Items List
            if viewModel.expiringItems.isEmpty {
                // Empty state
                expiringEmptyState
            } else {
                // Horizontal scroll of expiring items
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: DesignSystem.Spacing.lg) {
                        ForEach(viewModel.expiringItems) { item in
                            ExpiringItemCard(
                                item: item,
                                isSelectionMode: isSelectionMode,
                                isSelected: selectedItems.contains(item.id),
                                onEdit: { itemToEdit = item },
                                onToggleSelection: { toggleItemSelection(item) }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                }
                .padding(.horizontal, -DesignSystem.Spacing.lg)
                .frame(minHeight: 160)
                
                // Recipe Ideas Button
                if !viewModel.expiringItems.isEmpty {
                    Button(action: {
                        viewModel.startRecipeGeneration()
                        showingRecipes = true
                    }) {
                        HStack {
                            Image(systemName: "book.cookbook.fill")
                                .font(.subheadline)
                            
                            Text("Get Recipe Ideas")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(DesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(Color.oceanBlue)
                        )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(viewModel.isGeneratingRecipes ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.isGeneratingRecipes)
                }
            }
        }
    }
    
    private var expiringBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.badge.exclamationmark.fill")
                .font(.caption)
                .foregroundColor(.softCoral)
            
            Text("\(viewModel.expiringItemsCount)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.softCoral)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.softCoral.opacity(0.1))
        )
    }
    
    private var expiringEmptyState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundColor(.sageGreen)
            
            Text("Everything looks fresh! ✓")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.sageGreen)
            
            Text("No items expiring in the next 3 days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .foregroundColor(Color.sageGreen.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(Color.sageGreen.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Section Header
            HStack {
                Text("Food Categories")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.totalItemsCount) total items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Categories List
            if viewModel.categoriesWithItems.isEmpty {
                // Empty state
                categoriesEmptyState
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.categoriesWithItems, id: \.self) { category in
                        CategorySection(
                            category: category,
                            items: viewModel.items(for: category),
                            itemCount: viewModel.itemCount(for: category),
                            isSelectionMode: isSelectionMode,
                            selectedItems: selectedItems,
                            onEditItem: { item in
                                itemToEdit = item
                            },
                            onRemoveItem: { item in
                                itemToRemove = item
                                showingRemovalConfirmation = true
                            },
                            onToggleSelection: { item in
                                toggleItemSelection(item)
                            }
                        )
                        .environmentObject(viewModel)
                    }
                }
            }
        }
    }
    
    private var categoriesEmptyState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "plus.circle")
                .font(.title)
                .foregroundColor(.oceanBlue)
            
            Text("No items in your fridge")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.oceanBlue)
            
            Text("Start adding items to see them organized by category")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .foregroundColor(Color.oceanBlue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(Color.oceanBlue.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Selection Action Bar
    
    private var selectionActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                // Cancel selection
                Button("Cancel") {
                    isSelectionMode = false
                    selectedItems.removeAll()
                }
                .foregroundColor(.oceanBlue)
                
                Spacer()
                
                // Selection count
                Text("\(selectedItems.count) selected")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Remove selected items
                Button("Remove Selected (\(selectedItems.count))") {
                    removeSelectedItems()
                }
                .foregroundColor(.softCoral)
                .font(.subheadline)
                .fontWeight(.medium)
                .disabled(selectedItems.isEmpty)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Supporting Views

struct ExpiringItemCard: View {
    let item: FoodItem
    let isSelectionMode: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onToggleSelection: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row with selection/actions
            HStack {
                // Selection checkbox (when in selection mode)
                if isSelectionMode {
                    Button(action: onToggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .oceanBlue : .secondary)
                            .font(.title3)
                    }
                    .frame(width: 24, height: 24)
                }
                
                // Item name and edit button on same line
                HStack {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    // Edit button (when not in selection mode)
                    if !isSelectionMode {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground).opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray5).opacity(0.3), lineWidth: 0.5)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Days left badge
            daysLeftBadge
                .padding(.horizontal, 8)
            
            // Quantity and location
            VStack(alignment: .leading, spacing: 2) {
                Text(item.quantityDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let zoneTag = item.zoneTag {
                    Text(zoneTag)
                        .font(.caption2)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(isSelected ? Color.oceanBlue : Color.clear, lineWidth: 2)
                )
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            if !isSelectionMode {
                onEdit()
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isSelectionMode)
    }
    
    private var daysLeftBadge: some View {
        let daysLeft = item.daysUntilExpiration
        let color: Color = {
            if item.isExpired {
                return .red
            } else if daysLeft <= 1 {
                return .softCoral
            } else if daysLeft <= 3 {
                return .warmAmber
            } else {
                return .sageGreen
            }
        }()
        
        let text: String = {
            if item.isExpired {
                return "Expired"
            } else if daysLeft == 0 {
                return "Today"
            } else if daysLeft == 1 {
                return "1 day"
            } else {
                return "\(daysLeft) days"
            }
        }()
        
        return Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
            )
    }
    

}

struct ExpiredItemCard: View {
    let item: FoodItem
    let isSelectionMode: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onRemove: () -> Void
    let onToggleSelection: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row with selection/actions
            HStack {
                // Selection checkbox (when in selection mode)
                if isSelectionMode {
                    Button(action: onToggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .red : .secondary)
                            .font(.title3)
                    }
                    .frame(width: 24, height: 24)
                }
                
                // Item name and edit button on same line
                HStack {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    // Edit button (when not in selection mode)
                    if !isSelectionMode {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground).opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray5).opacity(0.3), lineWidth: 0.5)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Expired badge
            expiredBadge
                .padding(.horizontal, 8)
            
            // Quantity and location
            VStack(alignment: .leading, spacing: 2) {
                Text(item.quantityDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let zoneTag = item.zoneTag {
                    Text(zoneTag)
                        .font(.caption2)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(isSelected ? Color.red : Color.clear, lineWidth: 2)
                )
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            if !isSelectionMode {
                onEdit()
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isSelectionMode)
    }
    
    private var expiredBadge: some View {
        let daysExpired = abs(item.daysUntilExpiration)
        let text = daysExpired == 1 ? "1 day ago" : "\(daysExpired) days ago"
        
        return Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red)
            )
    }
}

struct CategorySection: View {
    let category: FoodCategory
    let items: [FoodItem]
    let itemCount: Int
    let isSelectionMode: Bool
    let selectedItems: Set<UUID>
    let onEditItem: (FoodItem) -> Void
    let onRemoveItem: (FoodItem) -> Void
    let onToggleSelection: (FoodItem) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Category Header
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Category icon and name
                    HStack(spacing: 8) {
                        Image(systemName: category.sfSymbol)
                            .font(.subheadline)
                            .foregroundColor(category.color)
                            .frame(width: 20)
                        
                        Text(category.rawValue)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("(\(itemCount))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Expand/collapse icon
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            
            // Items Grid
            if isExpanded {
                if items.isEmpty {
                    categoryEmptyState
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
                    ], spacing: DesignSystem.Spacing.sm) {
                        ForEach(items) { item in
                            CategoryItemCard(
                                item: item,
                                isSelectionMode: isSelectionMode,
                                isSelected: selectedItems.contains(item.id),
                                onEdit: onEditItem,
                                onRemove: onRemoveItem,
                                onToggleSelection: { onToggleSelection(item) }
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var categoryEmptyState: some View {
        HStack {
            Image(systemName: "plus.circle")
                .font(.subheadline)
                .foregroundColor(category.color)
            
            Text("No \(category.rawValue.lowercased()) items")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct CategoryItemCard: View {
    let item: FoodItem
    let isSelectionMode: Bool
    let isSelected: Bool
    let onEdit: (FoodItem) -> Void
    let onRemove: (FoodItem) -> Void
    let onToggleSelection: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row with selection/actions
            HStack {
                // Selection checkbox (when in selection mode)
                if isSelectionMode {
                    Button(action: onToggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .oceanBlue : .secondary)
                            .font(.title3)
                    }
                    .frame(width: 24, height: 24)
                }
                
                // Item name and edit button on same line
                HStack {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    // Edit button (when not in selection mode)
                    if !isSelectionMode {
                        Button(action: { onEdit(item) }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground).opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray5).opacity(0.3), lineWidth: 0.5)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Storage location
            if let zoneTag = item.zoneTag {
                Text(zoneTag)
                    .font(.caption2)
                    .foregroundColor(Color(.tertiaryLabel))
                    .lineLimit(1)
                    .padding(.horizontal, 8)
            }
            
            // Green expiry label for Food Categories
            if !item.isExpired && !item.isExpiringSoon {
                let daysLeft = item.daysUntilExpiration
                if daysLeft > 3 {
                    Text("\(daysLeft) days left")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.sageGreen)
                        )
                        .padding(.horizontal, 8)
                }
            }
            
            // Quantity and expiration indicator
            HStack {
                Text(item.quantityDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                expirationIndicator
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(minWidth: 180, maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(isSelected ? Color.oceanBlue : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .swipeActions(edge: .trailing) {
            Button("Remove") {
                onRemove(item)
            }
            .tint(.softCoral)
            
            Button("Edit") {
                onEdit(item)
            }
            .tint(.oceanBlue)
        }
        .onTapGesture {
            if !isSelectionMode {
                onEdit(item)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isSelectionMode)
    }
    
    private var expirationIndicator: some View {
        if item.isExpired {
            return Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.red)
        } else if item.isExpiringSoon {
            return Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundColor(.warmAmber)
        } else {
            return Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.sageGreen)
        }
    }
    

}

// MARK: - View Extensions

extension View {
    func onPressGesture(
        onPress: @escaping () -> Void,
        onRelease: @escaping () -> Void
    ) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Previews

#Preview("Default") {
    FridgeView()
}

#Preview("Empty State") {
    FridgeView()
}

#Preview("Fresh Items Only") {
    FridgeView()
}

#Preview("Minimal Data") {
    FridgeView()
}
