//
//  LocationManager.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation
import SwiftUI

class LocationManager: ObservableObject {
    @Published var savedLocations: [String] = []
    
    private let defaultLocations = [
        "Top Shelf",
        "Middle Shelf", 
        "Bottom Shelf",
        "Crisper Drawer",
        "Door Shelf",
        "Door Bin",
        "Freezer Top",
        "Freezer Bottom",
        "Pantry"
    ]
    
    init() {
        // Load saved locations from UserDefaults
        if let saved = UserDefaults.standard.array(forKey: "SavedLocations") as? [String] {
            savedLocations = saved
        } else {
            savedLocations = defaultLocations
        }
    }
    
    func addLocation(_ location: String) {
        let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !savedLocations.contains(trimmed) {
            savedLocations.append(trimmed)
            saveLocations()
        }
    }
    
    private func saveLocations() {
        UserDefaults.standard.set(savedLocations, forKey: "SavedLocations")
    }
    
    var allLocations: [String] {
        return savedLocations.sorted()
    }
    
    // MARK: - Convenience Methods
    
    func getDefaultLocation(for category: FoodCategory) -> String {
        switch category {
        case .vegetables, .fruits:
            return "Crisper Drawer"
        case .dairy, .meat:
            return "Middle Shelf"
        case .beverages:
            return "Door Shelf"
        case .frozen:
            return "Freezer Top"
        case .pantry:
            return "Pantry"
        case .leftovers, .condiments:
            return "Top Shelf"
        case .other:
            return "Middle Shelf"
        }
    }
    
    func resetToDefaults() {
        savedLocations = defaultLocations
        saveLocations()
    }
}
