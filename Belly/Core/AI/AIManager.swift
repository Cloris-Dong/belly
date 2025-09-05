//
//  AIManager.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI
import Foundation
import Combine

class AIManager: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var detectedItems: [DetectedFood] = []
    @Published var isRetrying = false
    @Published var retryMessage = ""
    
    // MARK: - AI Service Integration
    private let openAIService: OpenAIService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.openAIService = OpenAIService()
        
        // Observe retry status changes from the OpenAI service
        openAIService.$isRetrying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isRetrying = value
            }
            .store(in: &cancellables)
        
        openAIService.$retryMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.retryMessage = value
            }
            .store(in: &cancellables)
    }
    
    /// Check if real AI is available and configured
    var useRealAI: Bool {
        return openAIService.isConfigured
    }
    
    /// Check if real AI is available for the UI
    var isRealAIAvailable: Bool {
        return openAIService.isConfigured
    }
    
    /// Get AI service for direct access to controls
    var aiService: OpenAIService {
        return openAIService
    }
    
    
    // MARK: - Mock Food Detection
    
    func identifyFoodMock(from image: UIImage) async -> [DetectedFood] {
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Return realistic mock detections based on common scenarios
        let scenarios = [
            // Single item scenarios
            [DetectedFood(name: "Organic Spinach", category: "Vegetables", shelfLifeDays: 5, storage: "Refrigerator", location: "Crisper Drawer", confidence: 0.92, quantity: 1.0, unit: "packages")],
            
            [DetectedFood(name: "Red Bell Pepper", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", location: "Middle Shelf", confidence: 0.88, quantity: 2.0, unit: "pieces")],
            
            [DetectedFood(name: "Greek Yogurt", category: "Dairy", shelfLifeDays: 14, storage: "Refrigerator", location: "Middle Shelf", confidence: 0.94, quantity: 1.0, unit: "cartons")],
            
            [DetectedFood(name: "Chicken Breast", category: "Meat", shelfLifeDays: 5, storage: "Refrigerator", location: "Bottom Shelf", confidence: 0.89, quantity: 500.0, unit: "grams")],
            
            // Multiple items scenarios
            [
                DetectedFood(name: "Fresh Spinach", category: "Vegetables", shelfLifeDays: 5, storage: "Refrigerator", location: "Crisper Drawer", confidence: 0.92, quantity: 1.0, unit: "packages"),
                DetectedFood(name: "Cherry Tomatoes", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", location: "Crisper Drawer", confidence: 0.88, quantity: 250.0, unit: "grams")
            ],
            
            [
                DetectedFood(name: "Milk", category: "Dairy", shelfLifeDays: 10, storage: "Refrigerator", location: "Door Shelf", confidence: 0.96, quantity: 1.0, unit: "cartons"),
                DetectedFood(name: "Eggs", category: "Dairy", shelfLifeDays: 21, storage: "Refrigerator", location: "Door Bin", confidence: 0.91, quantity: 12.0, unit: "pieces"),
                DetectedFood(name: "Butter", category: "Dairy", shelfLifeDays: 30, storage: "Refrigerator", location: "Door Shelf", confidence: 0.87, quantity: 250.0, unit: "grams")
            ],
            
            [
                DetectedFood(name: "Organic Bananas", category: "Fruits", shelfLifeDays: 7, storage: "Refrigerator", location: "Top Shelf", confidence: 0.95, quantity: 6.0, unit: "pieces"),
                DetectedFood(name: "Strawberries", category: "Fruits", shelfLifeDays: 5, storage: "Refrigerator", location: "Crisper Drawer", confidence: 0.93, quantity: 1.0, unit: "packages")
            ],
            
            // Edge cases
            [
                DetectedFood(name: "Apples", category: "Fruits", shelfLifeDays: 14, storage: "Refrigerator", location: "Crisper Drawer", confidence: 0.78, quantity: 4.0, unit: "pieces"),
                DetectedFood(name: "Unknown Item", category: "Other", shelfLifeDays: 7, storage: "Refrigerator", location: "Middle Shelf", confidence: 0.45, quantity: 1.0, unit: "pieces")
            ],
            
            // DISABLED: No detection scenario - always return at least one item
            [DetectedFood(name: "Mock Item", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", location: "Middle Shelf", confidence: 0.9, quantity: 1.0, unit: "pieces")]
        ]
        
        return scenarios.randomElement() ?? [DetectedFood(name: "Mock Item", category: "Vegetables", shelfLifeDays: 7, storage: "Refrigerator", location: "Middle Shelf", confidence: 0.9, quantity: 1.0, unit: "pieces")]
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
            isRetrying = false
            retryMessage = ""
        }
        
        do {
            let results: [DetectedFood]
            
            if useRealAI {
                // Use real OpenAI service
                results = try await openAIService.detectFood(from: image)
            } else {
                // Fall back to mock data
                results = await identifyFoodMock(from: image)
            }
            
            await MainActor.run {
                detectedItems = results
                isLoading = false
                isRetrying = false
                retryMessage = ""
            }
            
            return results
        } catch {
            await MainActor.run {
                // Show generic error message without exposing API details
                if useRealAI {
                    if let openAIError = error as? OpenAIError {
                        switch openAIError {
                        case .networkError:
                            self.error = "No internet connection available"
                        case .rateLimitExceeded:
                            self.error = "AI usage limit reached. Please try again later."
                        case .invalidInput:
                            self.error = "Unable to process this image"
                        default:
                            self.error = "AI service temporarily unavailable"
                        }
                    } else {
                        self.error = "AI service temporarily unavailable"
                    }
                } else {
                    self.error = "Failed to process image: \(error.localizedDescription)"
                }
                isLoading = false
                isRetrying = false
                retryMessage = ""
            }
            return []
        }
    }
    
    func generateRecipes(from ingredients: [String]) async -> [Recipe] {
        await MainActor.run {
            isLoading = true
            error = nil
            isRetrying = false
            retryMessage = ""
        }
        
        do {
            let recipes: [Recipe]
            
            if useRealAI {
                // Use real OpenAI service
                recipes = try await openAIService.generateRecipes(from: ingredients)
            } else {
                // Fall back to mock data
                recipes = await generateRecipesMock(from: ingredients)
            }
            
            await MainActor.run {
                isLoading = false
                isRetrying = false
                retryMessage = ""
            }
            
            return recipes
        } catch {
            await MainActor.run {
                // Show generic error message without exposing API details
                if useRealAI {
                    if let openAIError = error as? OpenAIError {
                        switch openAIError {
                        case .networkError:
                            self.error = "No internet connection available"
                        case .rateLimitExceeded:
                            self.error = "AI usage limit reached. Please try again later."
                        default:
                            self.error = "AI service temporarily unavailable"
                        }
                    } else {
                        self.error = "AI service temporarily unavailable"
                    }
                } else {
                    self.error = "Failed to generate recipes: \(error.localizedDescription)"
                }
                isLoading = false
                isRetrying = false
                retryMessage = ""
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
