//
//  RecipeGenerator.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import Foundation

/// Generates recipes from available ingredients (mock implementation)
final class RecipeGenerator {
    
    /// Generate recipes from available ingredients
    static func generateRecipes(from ingredients: [String]) -> [Recipe] {
        let cleanIngredients = ingredients.map { $0.lowercased() }
        var recipes: [Recipe] = []
        
        // Recipe generation based on available ingredients
        for template in recipeTemplates {
            let matchingIngredients = template.requiredIngredients.filter { ingredient in
                cleanIngredients.contains { availableIngredient in
                    availableIngredient.contains(ingredient) || ingredient.contains(availableIngredient)
                }
            }
            
            if matchingIngredients.count >= template.minRequiredMatches {
                let recipe = Recipe(
                    title: template.title,
                    cookingTime: template.cookingTime,
                    servings: template.servings,
                    ingredients: template.ingredients,
                    instructions: template.instructions,
                    difficulty: template.difficulty,
                    category: template.category,
                    usedIngredients: matchingIngredients
                )
                recipes.append(recipe)
            }
        }
        
        // If no matches, provide general recipes
        if recipes.isEmpty {
            recipes = getGeneralRecipes()
        }
        
        // Limit to 5 recipes max, prioritize by matching ingredients
        return Array(recipes.prefix(5))
    }
    
    // MARK: - Recipe Templates
    
    private static let recipeTemplates: [RecipeTemplate] = [
        // Vegetable-based recipes
        RecipeTemplate(
            title: "Quick Vegetable Stir Fry",
            cookingTime: "15 min",
            servings: 2,
            ingredients: [
                "2 cups mixed vegetables (whatever you have)",
                "2 tbsp olive oil",
                "2 cloves garlic",
                "1 tbsp soy sauce",
                "Salt and pepper to taste"
            ],
            instructions: [
                "Heat olive oil in a large pan over medium-high heat",
                "Add garlic and cook for 30 seconds until fragrant",
                "Add vegetables and stir-fry for 5-7 minutes",
                "Add soy sauce, salt, and pepper",
                "Cook for another 2-3 minutes until vegetables are tender"
            ],
            difficulty: .easy,
            category: .dinner,
            requiredIngredients: ["spinach", "pepper", "carrot", "vegetables"],
            minRequiredMatches: 1
        ),
        
        RecipeTemplate(
            title: "Fresh Garden Salad",
            cookingTime: "10 min",
            servings: 2,
            ingredients: [
                "3 cups mixed greens",
                "1 cucumber, diced",
                "2 tomatoes, chopped",
                "1/4 red onion, sliced",
                "2 tbsp olive oil",
                "1 tbsp vinegar",
                "Salt and pepper"
            ],
            instructions: [
                "Wash and dry all vegetables",
                "Combine greens, cucumber, tomatoes, and onion in a bowl",
                "Whisk together olive oil, vinegar, salt, and pepper",
                "Toss salad with dressing just before serving"
            ],
            difficulty: .easy,
            category: .salad,
            requiredIngredients: ["greens", "spinach", "vegetables"],
            minRequiredMatches: 1
        ),
        
        // Protein-based recipes
        RecipeTemplate(
            title: "Simple Grilled Chicken",
            cookingTime: "25 min",
            servings: 3,
            ingredients: [
                "3 chicken breasts",
                "2 tbsp olive oil",
                "1 tsp garlic powder",
                "1 tsp paprika",
                "Salt and pepper",
                "Lemon juice"
            ],
            instructions: [
                "Preheat grill or pan to medium-high heat",
                "Season chicken with oil, garlic powder, paprika, salt, and pepper",
                "Cook chicken for 6-7 minutes per side",
                "Check internal temperature reaches 165°F",
                "Let rest for 5 minutes, then slice and serve with lemon"
            ],
            difficulty: .easy,
            category: .dinner,
            requiredIngredients: ["chicken"],
            minRequiredMatches: 1
        ),
        
        RecipeTemplate(
            title: "Pan-Seared Salmon",
            cookingTime: "15 min",
            servings: 2,
            ingredients: [
                "2 salmon fillets",
                "2 tbsp olive oil",
                "1 lemon, sliced",
                "2 cloves garlic",
                "Fresh herbs (optional)",
                "Salt and pepper"
            ],
            instructions: [
                "Pat salmon dry and season with salt and pepper",
                "Heat oil in a pan over medium-high heat",
                "Cook salmon skin-side up for 4-5 minutes",
                "Flip and cook for 3-4 minutes more",
                "Add garlic and lemon slices to pan",
                "Serve immediately with pan juices"
            ],
            difficulty: .medium,
            category: .dinner,
            requiredIngredients: ["salmon"],
            minRequiredMatches: 1
        ),
        
        // Dairy-based recipes
        RecipeTemplate(
            title: "Creamy Cheese Omelette",
            cookingTime: "10 min",
            servings: 1,
            ingredients: [
                "3 large eggs",
                "1/4 cup shredded cheese",
                "2 tbsp milk",
                "1 tbsp butter",
                "Salt and pepper",
                "Fresh herbs (optional)"
            ],
            instructions: [
                "Beat eggs with milk, salt, and pepper",
                "Heat butter in a non-stick pan over medium heat",
                "Pour in eggs and let set for 1 minute",
                "Gently push edges toward center, tilting pan",
                "Add cheese to one half when eggs are almost set",
                "Fold omelette in half and slide onto plate"
            ],
            difficulty: .medium,
            category: .breakfast,
            requiredIngredients: ["cheese", "milk"],
            minRequiredMatches: 1
        ),
        
        // Fruit-based recipes
        RecipeTemplate(
            title: "Mixed Berry Smoothie Bowl",
            cookingTime: "5 min",
            servings: 1,
            ingredients: [
                "1 cup frozen mixed berries",
                "1/2 banana",
                "1/4 cup yogurt",
                "1 tbsp honey",
                "Granola for topping",
                "Fresh fruit for garnish"
            ],
            instructions: [
                "Blend frozen berries, banana, yogurt, and honey until thick",
                "Pour into a bowl",
                "Top with granola and fresh fruit",
                "Serve immediately"
            ],
            difficulty: .easy,
            category: .breakfast,
            requiredIngredients: ["berries", "strawberries", "blueberries", "apple", "banana"],
            minRequiredMatches: 1
        ),
        
        // Leftover-based recipes
        RecipeTemplate(
            title: "Leftover Fried Rice",
            cookingTime: "12 min",
            servings: 2,
            ingredients: [
                "2 cups cooked rice (preferably day-old)",
                "2 eggs, beaten",
                "1 cup leftover vegetables or meat",
                "2 tbsp soy sauce",
                "1 tbsp oil",
                "2 green onions, chopped"
            ],
            instructions: [
                "Heat oil in a large pan or wok over high heat",
                "Add beaten eggs and scramble, then remove",
                "Add rice, breaking up clumps",
                "Stir in leftovers and heat through",
                "Add soy sauce and scrambled eggs",
                "Garnish with green onions"
            ],
            difficulty: .easy,
            category: .dinner,
            requiredIngredients: ["leftover", "pizza", "rice"],
            minRequiredMatches: 1
        )
    ]
    
    // MARK: - General Recipes
    
    private static func getGeneralRecipes() -> [Recipe] {
        return [
            Recipe(
                title: "Quick Pasta Aglio e Olio",
                cookingTime: "15 min",
                servings: 2,
                ingredients: [
                    "8 oz spaghetti",
                    "4 cloves garlic, thinly sliced",
                    "1/4 cup olive oil",
                    "Red pepper flakes",
                    "Parsley",
                    "Parmesan cheese"
                ],
                instructions: [
                    "Cook pasta according to package directions",
                    "Heat olive oil and garlic in a large pan",
                    "Add red pepper flakes",
                    "Toss with drained pasta and parsley",
                    "Serve with Parmesan"
                ],
                difficulty: .easy,
                category: .dinner
            ),
            
            Recipe(
                title: "Simple Avocado Toast",
                cookingTime: "5 min",
                servings: 1,
                ingredients: [
                    "2 slices bread",
                    "1 ripe avocado",
                    "Lemon juice",
                    "Salt and pepper",
                    "Optional: tomato, egg"
                ],
                instructions: [
                    "Toast bread until golden",
                    "Mash avocado with lemon juice, salt, and pepper",
                    "Spread on toast",
                    "Add toppings if desired"
                ],
                difficulty: .easy,
                category: .breakfast
            ),
            
            Recipe(
                title: "Basic Vegetable Soup",
                cookingTime: "30 min",
                servings: 4,
                ingredients: [
                    "2 tbsp olive oil",
                    "1 onion, diced",
                    "2 carrots, diced",
                    "2 celery stalks, diced",
                    "4 cups vegetable broth",
                    "Any vegetables you have",
                    "Salt and pepper"
                ],
                instructions: [
                    "Heat oil in a large pot",
                    "Sauté onion, carrots, and celery",
                    "Add broth and bring to boil",
                    "Add remaining vegetables",
                    "Simmer 15-20 minutes until tender",
                    "Season to taste"
                ],
                difficulty: .easy,
                category: .soup
            )
        ]
    }
}

// MARK: - Supporting Types

private struct RecipeTemplate {
    let title: String
    let cookingTime: String
    let servings: Int
    let ingredients: [String]
    let instructions: [String]
    let difficulty: RecipeDifficulty
    let category: RecipeCategory
    let requiredIngredients: [String] // Keywords to match against user's ingredients
    let minRequiredMatches: Int
}
