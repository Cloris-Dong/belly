//  OpenAIService.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation
import UIKit

/// Backend-based AI service that calls our Vercel backend instead of OpenAI directly
final class OpenAIService: ObservableObject {
    
    // MARK: - Private Properties
    private let backendURL = "https://belly-backend-ez87kthd4-cloris-dongs-projects.vercel.app"
    
    // MARK: - Usage Tracking
    @Published var requestCountToday: Int = 0
    @Published var lastRequestDate: Date?
    
    // MARK: - User Controls
    @Published var isAIEnabled: Bool = true
    @Published var isRetrying: Bool = false
    @Published var retryMessage: String = ""
    
    // MARK: - Rate Limiting
    private let maxRequestsPerHour = 20
    private let maxRequestsPerDay = 100
    
    // MARK: - Retry Configuration
    private let maxRetryAttempts = 3
    private let baseRetryDelay: TimeInterval = 2.0
    
    // MARK: - Initialization
    
    init() {
        loadUsageData()
        print("✅ Backend-based OpenAI Service initialized")
        print("🌐 Backend URL: \(backendURL)")
    }
    
    // MARK: - Public Interface
    
    /// Always returns true since backend handles authentication
    var isConfigured: Bool {
        return true
    }
    
    /// Detect food items in an image using backend AI service
    func detectFood(from image: UIImage) async throws -> [DetectedFood] {
        print("🔍 Starting food detection request to backend...")
        
        // Check network availability
        let networkStatus = NetworkManager.shared.isNetworkAvailable()
        print("🌐 Network available: \(networkStatus)")
        print("🌐 Connection type: \(NetworkManager.shared.connectionType)")
        
        guard networkStatus else {
            print("❌ Network not available")
            throw OpenAIError.networkError
        }
        
        // Rate limiting check
        guard checkRateLimit() else {
            print("❌ Rate limit exceeded")
            throw OpenAIError.rateLimitExceeded
        }
        
        // Prepare image data
        print("📷 Original image size: \(image.size)")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG")
            throw OpenAIError.invalidInput
        }
        print("📷 Image data size: \(imageData.count) bytes")
        
        // Strip metadata for privacy
        let strippedImageData = stripImageMetadata(imageData)
        let base64Image = strippedImageData.base64EncodedString()
        print("📷 Base64 image length: \(base64Image.count) characters")
        
        let payload: [String: Any] = [
            "image": "data:image/jpeg;base64,\(base64Image)"
        ]
        
        // Make request to backend with retry logic
        let detectedItems = try await performWithRetry { [self] in
            try await makeDetectionRequest(payload: payload)
        }
        
        // Update usage tracking
        updateUsageTracking()
        
        print("✅ Food detection completed: \(detectedItems.count) items found")
        return detectedItems
    }
    
    /// Generate smart recipes prioritizing expiring ingredients while considering all available ingredients
    func generateSmartRecipes(expiringIngredients: [String], allAvailableIngredients: [String]) async throws -> [Recipe] {
        print("🍳 Starting smart recipe generation request to backend...")
        print("🍃 Expiring ingredients: \(expiringIngredients)")
        print("📦 All available ingredients: \(allAvailableIngredients)")
        
        // Check network availability
        guard NetworkManager.shared.isNetworkAvailable() else {
            print("❌ Network not available")
            throw OpenAIError.networkError
        }
        
        // Rate limiting check
        guard checkRateLimit() else {
            print("❌ Rate limit exceeded")
            throw OpenAIError.rateLimitExceeded
        }
        
        // Prepare enhanced payload with expiring items context
        let payload: [String: Any] = [
            "ingredients": allAvailableIngredients,
            "expiring_ingredients": expiringIngredients,
            "priority": "use_expiring_first",
            "requirement": "each_recipe_must_include_at_least_one_expiring_ingredient",
            "dietary": [],
            "difficulty": "medium"
        ]
        
        // Make request to backend with retry logic
        let allRecipes = try await performWithRetry { [self] in
            try await makeRecipeRequest(payload: payload)
        }
        
        // Filter to ensure each recipe includes at least one expiring ingredient
        let cleanExpiring = expiringIngredients.map { $0.lowercased() }
        print("🔍 Filtering recipes with expiring ingredients: \(cleanExpiring)")
        
        let filteredRecipes = allRecipes.filter { recipe in
            // Check if recipe uses any expiring ingredients
            let recipeIngredients = recipe.usedIngredients
            print("🔍 Recipe '\(recipe.title)' has used ingredients: \(recipeIngredients)")
            
            let hasExpiringIngredient = recipeIngredients.contains { ingredient in
                let matches = cleanExpiring.contains { expiringIngredient in
                    ingredient.lowercased().contains(expiringIngredient) || 
                    expiringIngredient.contains(ingredient.lowercased())
                }
                if matches {
                    let matchedExpiring = cleanExpiring.first { expiringIngredient in
                        ingredient.lowercased().contains(expiringIngredient) || 
                        expiringIngredient.contains(ingredient.lowercased())
                    } ?? "unknown"
                    print("✅ Recipe '\(recipe.title)' matches expiring ingredient: \(ingredient) -> \(matchedExpiring)")
                }
                return matches
            }
            
            print("🔍 Recipe '\(recipe.title)' has expiring ingredient: \(hasExpiringIngredient)")
            return hasExpiringIngredient
        }
        
        print("🔍 Filtered recipes count: \(filteredRecipes.count) out of \(allRecipes.count)")
        
        // Ensure comprehensive coverage of expiring items
        var selectedRecipes: [Recipe] = []
        var coveredExpiringItems = Set<String>()
        
        // Sort recipes by expiring ingredient usage
        let sortedRecipes = filteredRecipes.sorted { recipe1, recipe2 in
            let expiring1 = (recipe1.usedIngredients ?? []).filter { ingredient in
                cleanExpiring.contains { expiringIngredient in
                    ingredient.lowercased().contains(expiringIngredient) || expiringIngredient.contains(ingredient.lowercased())
                }
            }.count
            
            let expiring2 = (recipe2.usedIngredients ?? []).filter { ingredient in
                cleanExpiring.contains { expiringIngredient in
                    ingredient.lowercased().contains(expiringIngredient) || expiringIngredient.contains(ingredient.lowercased())
                }
            }.count
            
            return expiring1 > expiring2
        }
        
        // Select recipes to ensure all expiring items are covered
        for recipe in sortedRecipes {
            let recipeExpiringItems = (recipe.usedIngredients ?? []).filter { ingredient in
                cleanExpiring.contains { expiringIngredient in
                    ingredient.lowercased().contains(expiringIngredient) || expiringIngredient.contains(ingredient.lowercased())
                }
            }.map { $0.lowercased() }
            
            let newExpiringItems = recipeExpiringItems.filter { !coveredExpiringItems.contains($0) }
            
            // Add recipe if it covers new expiring items or if we haven't reached minimum
            if !newExpiringItems.isEmpty || selectedRecipes.count < 2 {
                selectedRecipes.append(recipe)
                coveredExpiringItems.formUnion(recipeExpiringItems)
                
                // Stop if we've covered all expiring items and have enough recipes
                if coveredExpiringItems.count >= cleanExpiring.count && selectedRecipes.count >= 3 {
                    break
                }
            }
        }
        
        // If we still haven't covered all expiring items, add more recipes
        if coveredExpiringItems.count < cleanExpiring.count {
            for recipe in sortedRecipes {
                if selectedRecipes.contains(where: { $0.id == recipe.id }) {
                    continue // Skip already selected recipes
                }
                
                let recipeExpiringItems = (recipe.usedIngredients ?? []).filter { ingredient in
                    cleanExpiring.contains { expiringIngredient in
                        ingredient.lowercased().contains(expiringIngredient) || expiringIngredient.contains(ingredient.lowercased())
                    }
                }.map { $0.lowercased() }
                
                let newExpiringItems = recipeExpiringItems.filter { !coveredExpiringItems.contains($0) }
                
                if !newExpiringItems.isEmpty {
                    selectedRecipes.append(recipe)
                    coveredExpiringItems.formUnion(recipeExpiringItems)
                    
                    // Stop if we've covered all expiring items or reached max recipes
                    if coveredExpiringItems.count >= cleanExpiring.count || selectedRecipes.count >= 5 {
                        break
                    }
                }
            }
        }
        
        // Update usage tracking
        updateUsageTracking()
        
        // Log coverage information
        print("📊 AI Recipe Coverage Report:")
        print("   Total expiring items: \(cleanExpiring.count)")
        print("   Covered expiring items: \(coveredExpiringItems.count)")
        print("   Selected recipes: \(selectedRecipes.count)")
        print("   Coverage: \(String(format: "%.1f", Double(coveredExpiringItems.count) / Double(cleanExpiring.count) * 100))%")
        
        print("✅ Smart recipe generation completed: \(selectedRecipes.count) recipes generated (filtered from \(allRecipes.count))")
        return selectedRecipes
    }
    
    /// Generate recipes from ingredients using backend AI service
    func generateRecipes(from ingredients: [String]) async throws -> [Recipe] {
        print("🍳 Starting recipe generation request to backend...")
        
        // Check network availability
        guard NetworkManager.shared.isNetworkAvailable() else {
            print("❌ Network not available")
            throw OpenAIError.networkError
        }
        
        // Rate limiting check
        guard checkRateLimit() else {
            print("❌ Rate limit exceeded")
            throw OpenAIError.rateLimitExceeded
        }
        
        // Prepare payload
        let payload: [String: Any] = [
            "ingredients": ingredients,
            "dietary": [],
            "difficulty": "medium"
        ]
        
        // Make request to backend with retry logic
        let recipes = try await performWithRetry { [self] in
            try await makeRecipeRequest(payload: payload)
        }
        
        // Update usage tracking
        updateUsageTracking()
        
        print("✅ Recipe generation completed: \(recipes.count) recipes generated")
        return recipes
    }
    
    // MARK: - Private Methods
    
    /// Performs an operation with exponential backoff retry logic
    private func performWithRetry<T>(operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetryAttempts {
            do {
                // Reset retry state on first attempt
                if attempt == 1 {
                    await MainActor.run {
                        isRetrying = false
                        retryMessage = ""
                    }
                }
                
                // Perform the operation
                let result = try await operation()
                
                // Success - reset retry state
                await MainActor.run {
                    isRetrying = false
                    retryMessage = ""
                }
                
                return result
                
            } catch {
                lastError = error
                
                // Don't retry for certain errors
                if let openAIError = error as? OpenAIError {
                    switch openAIError {
                    case .rateLimitExceeded, .invalidInput, .invalidResponse:
                        // These errors shouldn't be retried
                        await MainActor.run {
                            isRetrying = false
                            retryMessage = ""
                        }
                        throw error
                    case .networkError, .apiError:
                        // These errors can be retried
                        break
                    }
                }
                
                // If this was the last attempt, throw the error
                if attempt == maxRetryAttempts {
                    await MainActor.run {
                        isRetrying = false
                        retryMessage = ""
                    }
                    throw error
                }
                
                // Calculate delay for next attempt (exponential backoff)
                let delay = baseRetryDelay * pow(2.0, Double(attempt - 1))
                
                // Update UI to show retry status
                await MainActor.run {
                    isRetrying = true
                    retryMessage = "Connecting to AI service... (Attempt \(attempt + 1)/\(maxRetryAttempts))"
                }
                
                print("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
                print("🔄 Retrying in \(delay) seconds...")
                
                // Wait before retrying
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        // This should never be reached, but just in case
        throw lastError ?? OpenAIError.networkError
    }
    
    private func makeDetectionRequest(payload: [String: Any]) async throws -> [DetectedFood] {
        guard let url = URL(string: "\(backendURL)/api/detect-food") else {
            throw OpenAIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to serialize request payload")
            throw OpenAIError.invalidInput
        }
        
        do {
            print("📡 Making request to: \(url)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw OpenAIError.networkError
            }
            
            print("📡 Response status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                return try parseDetectionResponse(data)
            case 429:
                print("❌ Rate limit exceeded on backend")
                throw OpenAIError.rateLimitExceeded
            case 400:
                print("❌ Bad request to backend")
                throw OpenAIError.invalidInput
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Backend error: \(errorMessage)")
                throw OpenAIError.apiError("Backend error: \(errorMessage)")
            }
        } catch let urlError as URLError {
            print("❌ Network error: \(urlError.localizedDescription)")
            throw OpenAIError.networkError
        } catch let openAIError as OpenAIError {
            throw openAIError
        } catch {
            print("❌ Unexpected error: \(error)")
            throw OpenAIError.invalidResponse
        }
    }
    
    private func makeRecipeRequest(payload: [String: Any]) async throws -> [Recipe] {
        guard let url = URL(string: "\(backendURL)/api/generate-recipes") else {
            print("❌ Invalid backend URL: \(backendURL)")
            throw OpenAIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            print("📤 Request payload size: \(request.httpBody?.count ?? 0) bytes")
            if let payloadString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request payload: \(payloadString)")
            }
        } catch {
            print("❌ Failed to serialize request payload: \(error)")
            throw OpenAIError.invalidInput
        }
        
        do {
            print("📡 Making request to: \(url)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw OpenAIError.networkError
            }
            
            print("📡 Response status: \(httpResponse.statusCode)")
            print("📥 Response data size: \(data.count) bytes")
            
            // Log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                let recipes = try parseRecipeResponse(data)
                print("✅ Successfully parsed \(recipes.count) recipes from backend")
                return recipes
            case 429:
                print("❌ Rate limit exceeded on backend")
                throw OpenAIError.rateLimitExceeded
            case 400:
                print("❌ Bad request to backend")
                throw OpenAIError.invalidInput
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Backend error (\(httpResponse.statusCode)): \(errorMessage)")
                throw OpenAIError.apiError("Backend error: \(errorMessage)")
            }
        } catch let urlError as URLError {
            print("❌ Network error: \(urlError.localizedDescription)")
            throw OpenAIError.networkError
        } catch let openAIError as OpenAIError {
            print("❌ OpenAI error: \(openAIError)")
            throw openAIError
        } catch {
            print("❌ Unexpected error: \(error)")
            throw OpenAIError.invalidResponse
        }
    }
    
    private func parseDetectionResponse(_ data: Data) throws -> [DetectedFood] {
        do {
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let detectedItems = response?["detectedItems"] as? [[String: Any]] else {
                print("❌ Invalid response structure - missing detectedItems")
                throw OpenAIError.invalidResponse
            }
            
            let items: [DetectedFood] = try detectedItems.compactMap { item in
                guard let name = item["name"] as? String,
                      let category = item["category"] as? String,
                      let shelfLifeDays = item["shelfLifeDays"] as? Int,
                      let storage = item["storage"] as? String,
                      let location = item["location"] as? String,
                      let confidence = item["confidence"] as? Double,
                      let quantity = item["quantity"] as? Double,
                      let unit = item["unit"] as? String else {
                    print("⚠️ Skipping invalid item: \(item)")
                    return nil
                }
                
                return DetectedFood(
                    name: name,
                    category: category,
                    shelfLifeDays: shelfLifeDays,
                    storage: storage,
                    location: location,
                    confidence: confidence,
                    quantity: quantity,
                    unit: unit
                )
            }
            
            print("✅ Parsed \(items.count) food items from response")
            return items
        } catch {
            print("❌ Failed to parse detection response: \(error)")
            throw OpenAIError.invalidResponse
        }
    }
    
    private func parseRecipeResponse(_ data: Data) throws -> [Recipe] {
        do {
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("🔍 Parsing recipe response structure: \(response?.keys.joined(separator: ", ") ?? "nil")")
            
            guard let recipes = response?["recipes"] as? [[String: Any]] else {
                print("❌ Invalid response structure - missing recipes")
                print("❌ Available keys: \(response?.keys.joined(separator: ", ") ?? "none")")
                throw OpenAIError.invalidResponse
            }
            
            print("🔍 Found \(recipes.count) recipes in response")
            
             let parsedRecipes: [Recipe] = try recipes.enumerated().compactMap { (index, recipe) in
                print("🔍 Parsing recipe \(index + 1): \(recipe.keys.joined(separator: ", "))")
                
                guard let name = recipe["name"] as? String,
                      let ingredientsArray = recipe["ingredients"] as? [[String: Any]],
                      let instructions = recipe["instructions"] as? [String],
                      let totalTime = recipe["totalTime"] as? String,
                      let servings = recipe["servings"] as? Int,
                      let difficultyString = recipe["difficulty"] as? String,
                      let categoryString = recipe["category"] as? String else {
                    print("⚠️ Skipping invalid recipe \(index + 1): missing required fields")
                    print("⚠️ Recipe data: \(recipe)")
                    print("⚠️ Available fields: \(recipe.keys.joined(separator: ", "))")
                    return nil
                }
                
                print("🔍 Recipe \(index + 1) fields:")
                print("   Name: \(name)")
                print("   TotalTime: \(totalTime)")
                print("   Servings: \(servings)")
                print("   Difficulty: \(difficultyString)")
                print("   Category: \(categoryString)")
                print("   Ingredients count: \(ingredientsArray.count)")
                print("   Instructions count: \(instructions.count)")
                
                print("✅ Recipe \(index + 1): \(name) (\(servings) servings, \(totalTime))")
                
                // Convert ingredient objects to simple strings for the existing Recipe model
                let ingredients = ingredientsArray.compactMap { ing -> String? in
                    guard let name = ing["name"] as? String,
                          let quantity = ing["quantity"] as? String,
                          let unit = ing["unit"] as? String else {
                        print("⚠️ Invalid ingredient: \(ing)")
                        return nil
                    }
                    let ingredientString = "\(quantity) \(unit) \(name)"
                    print("   Ingredient: \(ingredientString)")
                    return ingredientString
                }
                
                print("🔍 Parsed \(ingredients.count) ingredients")
                
                // Handle case sensitivity - backend returns lowercase, enums expect capitalized
                let capitalizedDifficulty = difficultyString.capitalized
                let capitalizedCategory = categoryString.capitalized
                
                let difficulty = RecipeDifficulty(rawValue: capitalizedDifficulty) ?? .medium
                let category = RecipeCategory(rawValue: capitalizedCategory) ?? .other
                
                print("🔍 Difficulty: '\(difficultyString)' -> '\(capitalizedDifficulty)' -> \(difficulty)")
                print("🔍 Category: '\(categoryString)' -> '\(capitalizedCategory)' -> \(category)")
                
                // Extract used ingredients from user's fridge by matching ingredient names
                let usedIngredients = ingredients.compactMap { ingredientString -> String? in
                    // Extract the ingredient name from the formatted string (e.g., "2 cups milk" -> "milk")
                    let words = ingredientString.lowercased().components(separatedBy: .whitespaces)
                    if words.count >= 2 {
                        // Take the last word as the ingredient name
                        return words.last
                    }
                    return nil
                }
                
                print("🔍 Recipe \(index + 1) used ingredients: \(usedIngredients)")
                
                let parsedRecipe = Recipe(
                    title: name,
                    cookingTime: totalTime,
                    servings: servings,
                    ingredients: ingredients,
                    instructions: instructions,
                    difficulty: difficulty,
                    category: category,
                    usedIngredients: usedIngredients
                )
                
                print("✅ Successfully parsed recipe: \(parsedRecipe.title)")
                return parsedRecipe
            }
            
            print("✅ Successfully parsed \(parsedRecipes.count) recipes from \(recipes.count) total recipes")
            return parsedRecipes
        } catch {
            print("❌ Failed to parse recipe response: \(error)")
            throw OpenAIError.invalidResponse
        }
    }
    
    private func checkRateLimit() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // Reset daily count if it's a new day
        if let lastDate = lastRequestDate {
            if !calendar.isDate(lastDate, inSameDayAs: now) {
                requestCountToday = 0
            }
        }
        
        // Check daily limit
        if requestCountToday >= maxRequestsPerDay {
            return false
        }
        
        return true
    }
    
    private func updateUsageTracking() {
        requestCountToday += 1
        lastRequestDate = Date()
        saveUsageData()
    }
    
    private func loadUsageData() {
        requestCountToday = UserDefaults.standard.integer(forKey: "OpenAI_RequestCountToday")
        lastRequestDate = UserDefaults.standard.object(forKey: "OpenAI_LastRequestDate") as? Date
        isAIEnabled = UserDefaults.standard.object(forKey: "OpenAI_IsAIEnabled") as? Bool ?? true
    }
    
    private func saveUsageData() {
        UserDefaults.standard.set(requestCountToday, forKey: "OpenAI_RequestCountToday")
        UserDefaults.standard.set(lastRequestDate, forKey: "OpenAI_LastRequestDate")
        UserDefaults.standard.set(isAIEnabled, forKey: "OpenAI_IsAIEnabled")
    }
    
    private func stripImageMetadata(_ imageData: Data) -> Data {
        // For privacy, strip EXIF and other metadata
        guard let image = UIImage(data: imageData),
              let strippedData = image.jpegData(compressionQuality: 0.8) else {
            return imageData
        }
        return strippedData
    }
}

// MARK: - Error Types

enum OpenAIError: Error, LocalizedError {
    case rateLimitExceeded
    case networkError
    case invalidInput
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded:
            return "API usage limit reached. Please try again later."
        case .networkError:
            return "Network error occurred"
        case .invalidInput:
            return "Invalid input provided"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}