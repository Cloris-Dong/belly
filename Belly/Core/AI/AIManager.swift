//
//  AIManager.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI
import Foundation

class AIManager: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var detectedItems: [DetectedFood] = []
    
    // MARK: - Mock Food Detection
    
    func identifyFoodMock(from image: UIImage) async -> [DetectedFood] {
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Return realistic mock detections based on common scenarios
        let scenarios = [
            // Single item scenarios
            [DetectedFood(name: "Organic Spinach", category: "Vegetables", shelfLifeDays: 5, storage: "Refrigerator", confidence: 0.92)],
            
            [DetectedFood(name: "Red Bell Pepper", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", confidence: 0.88)],
            
            [DetectedFood(name: "Greek Yogurt", category: "Dairy", shelfLifeDays: 14, storage: "Refrigerator", confidence: 0.94)],
            
            [DetectedFood(name: "Chicken Breast", category: "Meat", shelfLifeDays: 5, storage: "Refrigerator", confidence: 0.89)],
            
            // Multiple items scenarios
            [
                DetectedFood(name: "Fresh Spinach", category: "Vegetables", shelfLifeDays: 5, storage: "Refrigerator", confidence: 0.92),
                DetectedFood(name: "Cherry Tomatoes", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", confidence: 0.88)
            ],
            
            [
                DetectedFood(name: "Milk", category: "Dairy", shelfLifeDays: 10, storage: "Refrigerator", confidence: 0.96),
                DetectedFood(name: "Eggs", category: "Dairy", shelfLifeDays: 21, storage: "Refrigerator", confidence: 0.91),
                DetectedFood(name: "Butter", category: "Dairy", shelfLifeDays: 30, storage: "Refrigerator", confidence: 0.87)
            ],
            
            [
                DetectedFood(name: "Organic Bananas", category: "Fruits", shelfLifeDays: 7, storage: "Refrigerator", confidence: 0.95),
                DetectedFood(name: "Strawberries", category: "Fruits", shelfLifeDays: 5, storage: "Refrigerator", confidence: 0.93)
            ],
            
            // Edge cases
            [
                DetectedFood(name: "Apples", category: "Fruits", shelfLifeDays: 14, storage: "Refrigerator", confidence: 0.78),
                DetectedFood(name: "Unknown Item", category: "Other", shelfLifeDays: 7, storage: "Refrigerator", confidence: 0.45)
            ],
            
            // No detection scenario
            []
        ]
        
        return scenarios.randomElement() ?? []
    }
    
    // MARK: - Mock Recipe Generation
    
    func generateRecipesMock(from ingredients: [String]) async -> [Recipe] {
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        let mockRecipes = [
            Recipe(
                title: "Quick Spinach Stir-Fry",
                cookingTime: "10 minutes",
                servings: 2,
                ingredients: ["Spinach", "Bell Pepper", "Garlic", "Olive Oil"],
                instructions: [
                    "Heat olive oil in large pan",
                    "Add minced garlic and cook for 30 seconds",
                    "Add bell pepper and cook for 2 minutes",
                    "Add spinach and stir until wilted",
                    "Season with salt and pepper"
                ],
                difficulty: .easy,
                category: .dinner,
                usedIngredients: ["Spinach", "Bell Pepper"]
            ),
            
            Recipe(
                title: "Fresh Garden Salad",
                cookingTime: "5 minutes",
                servings: 2,
                ingredients: ["Spinach", "Bell Pepper", "Olive Oil", "Lemon"],
                instructions: [
                    "Wash and dry spinach leaves",
                    "Slice bell pepper into strips",
                    "Combine in large bowl",
                    "Drizzle with olive oil and lemon juice"
                ],
                difficulty: .easy,
                category: .salad,
                usedIngredients: ["Spinach", "Bell Pepper"]
            ),
            
            Recipe(
                title: "Greek Yogurt Parfait",
                cookingTime: "3 minutes",
                servings: 1,
                ingredients: ["Greek Yogurt", "Honey", "Granola", "Fresh Berries"],
                instructions: [
                    "Layer yogurt in glass",
                    "Add granola layer",
                    "Top with berries",
                    "Drizzle with honey"
                ],
                difficulty: .easy,
                category: .breakfast,
                usedIngredients: ["Greek Yogurt"]
            ),
            
            Recipe(
                title: "Simple Chicken Stir-Fry",
                cookingTime: "15 minutes",
                servings: 4,
                ingredients: ["Chicken Breast", "Vegetables", "Soy Sauce", "Garlic"],
                instructions: [
                    "Cut chicken into strips",
                    "Stir-fry chicken until golden",
                    "Add vegetables",
                    "Season with soy sauce and garlic"
                ],
                difficulty: .medium,
                category: .dinner,
                usedIngredients: ["Chicken Breast"]
            )
        ]
        
        return mockRecipes
    }
    
    // MARK: - Real AI Integration (Commented out for future use)
    
    /*
    private func callOpenAIVision(image: UIImage) async throws -> [DetectedFood] {
        // TODO: Implement real OpenAI Vision API call
        // This will replace the mock implementation
        fatalError("Real AI integration not yet implemented")
    }
    
    private func callOpenAIRecipeGeneration(ingredients: [String]) async throws -> [Recipe] {
        // TODO: Implement real OpenAI recipe generation
        // This will replace the mock implementation
        fatalError("Real AI integration not yet implemented")
    }
    */
    
    // MARK: - Public Interface
    
    func processImage(_ image: UIImage) async -> [DetectedFood] {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let results = await identifyFoodMock(from: image)
            
            await MainActor.run {
                detectedItems = results
                isLoading = false
            }
            
            return results
        } catch {
            await MainActor.run {
                self.error = "Failed to process image: \(error.localizedDescription)"
                isLoading = false
            }
            return []
        }
    }
    
    func generateRecipes(from ingredients: [String]) async -> [Recipe] {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let recipes = await generateRecipesMock(from: ingredients)
            
            await MainActor.run {
                isLoading = false
            }
            
            return recipes
        } catch {
            await MainActor.run {
                self.error = "Failed to generate recipes: \(error.localizedDescription)"
                isLoading = false
            }
            return []
        }
    }
    
    func reset() {
        detectedItems.removeAll()
        error = nil
        isLoading = false
    }
}
