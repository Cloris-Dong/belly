//
//  Recipe.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Recipe model for generated recipes from expiring ingredients
struct Recipe: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let cookingTime: String
    let servings: Int
    let ingredients: [String]
    let instructions: [String]
    let difficulty: RecipeDifficulty
    let category: RecipeCategory
    let usedIngredients: [String] // Ingredients from user's fridge
    
    init(
        title: String,
        cookingTime: String,
        servings: Int,
        ingredients: [String],
        instructions: [String],
        difficulty: RecipeDifficulty = .easy,
        category: RecipeCategory = .other,
        usedIngredients: [String] = []
    ) {
        self.title = title
        self.cookingTime = cookingTime
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
        self.difficulty = difficulty
        self.category = category
        self.usedIngredients = usedIngredients
    }
}

/// Recipe difficulty levels
enum RecipeDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .easy: return "star.fill"
        case .medium: return "star.lefthalf.filled"
        case .hard: return "star"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .sageGreen
        case .medium: return .warmAmber
        case .hard: return .softCoral
        }
    }
}

/// Recipe categories
enum RecipeCategory: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case dessert = "Dessert"
    case soup = "Soup"
    case salad = "Salad"
    case other = "Other"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .breakfast: return "🍳"
        case .lunch: return "🥪"
        case .dinner: return "🍽️"
        case .snack: return "🥨"
        case .dessert: return "🍰"
        case .soup: return "🍲"
        case .salad: return "🥗"
        case .other: return "🍴"
        }
    }
}

import SwiftUI
