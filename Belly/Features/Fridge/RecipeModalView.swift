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
            VStack(spacing: 0) {
                // Sticky header - styled like Fridge page
                ZStack {
                    // Centered title
                    Text("Recipe Ideas")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                    
                    // Close button on the right
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.md)
                
                // Content area - seamless with header
                if isGenerating {
                    // Loading state - centered outside ScrollView
                    loadingView
                } else if recipes.isEmpty {
                    // Empty state - centered outside ScrollView
                    emptyStateView
                } else {
                    // Recipes list - scrollable content
                    ScrollView {
                        recipesScrollView
                    }
                }
            }
            .background(Color.creamWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.lightSageGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .onAppear {
                print("📱 RecipeModalView appeared with \(recipes.count) recipes")
                for (index, recipe) in recipes.enumerated() {
                    print("📱 Recipe \(index + 1): \(recipe.title)")
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .sageGreen))
                
                Text("Generating recipe ideas...")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text("Finding delicious ways to use your expiring items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "book.cookbook")
                    .font(.system(size: 48))
                    .foregroundColor(.sageGreen)
                
                Text("No Recipes Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("We couldn't find recipes that use your expiring ingredients. Try adding more diverse items to your fridge or check back when you have different expiring items!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .padding(DesignSystem.Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Recipes Scroll View
    
    private var recipesScrollView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
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
                    .foregroundColor(.primaryText)
                
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
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
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
                                .lineLimit(1)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        // Servings - with flexible layout
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.caption)
                            Text("\(recipe.servings) servings")
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundColor(.sageGreen)
            }
            .buttonStyle(.plain)
            
            // Expandable content
            if isExpanded {
                expandedContent
                    .transition(.opacity)
            }
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
                .padding(.top, DesignSystem.Spacing.sm)
            
            // Ingredients list
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Ingredients")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                        Text("•")
                            .foregroundColor(.sageGreen)
                            .fontWeight(.semibold)
                        
                        Text(ingredient)
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        
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
                    .foregroundColor(.primaryText)
                
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.sageGreen)
                            .frame(minWidth: 20, alignment: .leading)
                        
                        Text(instruction)
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .clipped() // Prevent content from overflowing
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
