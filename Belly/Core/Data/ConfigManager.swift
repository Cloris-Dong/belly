//
//  ConfigManager.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation

/// Manages configuration values from Info.plist and Config.xcconfig
/// Provides secure access to API keys and other sensitive configuration
final class ConfigManager {
    
    /// Shared instance for accessing configuration
    static let shared = ConfigManager()
    
    private init() {}
    
    // MARK: - API Keys
    
    /// OpenAI API key for AI features
    var openAIAPIKey: String? {
        getValue(for: "OPENAI_API_KEY")
    }
    
    /// Google API key for location services
    var googleAPIKey: String? {
        getValue(for: "GOOGLE_API_KEY")
    }
    
    /// Firebase Project ID
    var firebaseProjectID: String? {
        getValue(for: "FIREBASE_PROJECT_ID")
    }
    
    // MARK: - App Configuration
    
    /// Whether debug mode is enabled
    var isDebugMode: Bool {
        getValue(for: "DEBUG_MODE")?.lowercased() == "yes" || getValue(for: "DEBUG_MODE")?.lowercased() == "true"
    }
    
    /// Whether analytics is enabled
    var isAnalyticsEnabled: Bool {
        getValue(for: "ANALYTICS_ENABLED")?.lowercased() == "yes" || getValue(for: "ANALYTICS_ENABLED")?.lowercased() == "true"
    }
    
    // MARK: - Private Methods
    
    /// Safely retrieves a configuration value from Info.plist
    /// - Parameter key: The configuration key to look up
    /// - Returns: The string value if found, nil otherwise
    private func getValue(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            if isDebugMode {
                print("⚠️ ConfigManager: Missing configuration value for key '\(key)'")
            }
            return nil
        }
        
        // Don't return placeholder values
        if value.contains("your_") && value.contains("_here") {
            if isDebugMode {
                print("⚠️ ConfigManager: Placeholder value detected for key '\(key)'. Please update Config.xcconfig with actual values.")
            }
            return nil
        }
        
        return value
    }
    
    // MARK: - Validation
    
    /// Validates that all required configuration values are present
    /// - Returns: Array of missing configuration keys
    func validateConfiguration() -> [String] {
        var missingKeys: [String] = []
        
        // Check for required keys (add more as needed)
        let requiredKeys = [
            "OPENAI_API_KEY",
            "FIREBASE_PROJECT_ID"
        ]
        
        for key in requiredKeys {
            if getValue(for: key) == nil {
                missingKeys.append(key)
            }
        }
        
        return missingKeys
    }
    
    /// Checks if the app is properly configured for production use
    var isProperlyConfigured: Bool {
        return validateConfiguration().isEmpty
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ConfigManager {
    /// Prints all available configuration keys (for debugging)
    func printAvailableKeys() {
        print("📋 Available Configuration Keys:")
        
        let keys = [
            "OPENAI_API_KEY",
            "GOOGLE_API_KEY", 
            "FIREBASE_PROJECT_ID",
            "DEBUG_MODE",
            "ANALYTICS_ENABLED"
        ]
        
        for key in keys {
            let value = getValue(for: key)
            let status = value != nil ? "✅" : "❌"
            print("  \(status) \(key): \(value?.isEmpty == false ? "SET" : "MISSING")")
        }
    }
}
#endif
