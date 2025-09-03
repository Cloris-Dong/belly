//
//  RecipeModalView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct RecipeModalView: View {
    let recipes: [Recipe]
    let isGenerating: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                if isGenerating {
                    // Loading state
                    loadingView
                } else if recipes.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Recipes list
                    recipesScrollView
                }
            }
            .navigationTitle("Recipe Ideas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .oceanBlue))
            
            Text("Generating recipe ideas...")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Text("Finding delicious ways to use your expiring items")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "book.cookbook")
                .font(.system(size: 48))
                .foregroundColor(.oceanBlue)
            
            Text("No Recipes Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            Text("We couldn't find recipes matching your current ingredients. Try adding more items to your fridge!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    // MARK: - Recipes Scroll View
    
    private var recipesScrollView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg) {
                // Header with ingredient info
                if !recipes.isEmpty {
                    ingredientsHeaderView
                }
                
                // Recipe cards
                ForEach(recipes) { recipe in
                    RecipeCard(recipe: recipe)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.sm)
        }
    }
    
    // MARK: - Ingredients Header
    
    private var ingredientsHeaderView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.sageGreen)
                
                Text("Using Your Expiring Items")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text("These recipes help you use items that are expiring soon!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .foregroundColor(Color.sageGreen.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(Color.sageGreen.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Recipe Card

struct RecipeCard: View {
    let recipe: Recipe
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(recipe.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        // Category
                        HStack(spacing: 4) {
                            Text(recipe.category.emoji)
                            Text(recipe.category.rawValue)
                                .font(.caption)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        // Cooking time
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text(recipe.cookingTime)
                                .font(.caption)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        // Servings
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.caption)
                            Text("\(recipe.servings) servings")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Difficulty badge
                difficultyBadge
            }
            
            // Used ingredients (if any)
            if !recipe.usedIngredients.isEmpty {
                usedIngredientsView
            }
            
            // Expandable content
            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
            
            // Expand/collapse button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Show Less" : "Show Recipe")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.oceanBlue)
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .foregroundColor(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
    }
    
    // MARK: - Supporting Views
    
    private var difficultyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: recipe.difficulty.icon)
                .font(.caption2)
            Text(recipe.difficulty.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(recipe.difficulty.color)
        )
    }
    
    private var usedIngredientsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Using from your fridge:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.sageGreen)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.xs) {
                ForEach(recipe.usedIngredients, id: \.self) { ingredient in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.sageGreen)
                        
                        Text(ingredient.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .foregroundColor(Color.sageGreen.opacity(0.05))
        )
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Divider()
            
            // Ingredients list
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Ingredients")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                        Text("•")
                            .foregroundColor(.oceanBlue)
                            .fontWeight(.semibold)
                        
                        Text(ingredient)
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        
                        Spacer()
                    }
                }
            }
            
            Divider()
            
            // Instructions
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Instructions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.oceanBlue)
                            .frame(minWidth: 20, alignment: .leading)
                        
                        Text(instruction)
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Recipe Modal") {
    RecipeModalView(
        recipes: RecipeGenerator.generateRecipes(from: ["chicken", "spinach", "cheese"]),
        isGenerating: false
    )
}

#Preview("Loading State") {
    RecipeModalView(
        recipes: [],
        isGenerating: true
    )
}

#Preview("Empty State") {
    RecipeModalView(
        recipes: [],
        isGenerating: false
    )
}
