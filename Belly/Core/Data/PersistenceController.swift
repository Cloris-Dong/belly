//
//  PersistenceController.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import CoreData
import Foundation
import os.log

/// Manages the Core Data stack for the Belly app
/// Provides both production and preview contexts for SwiftUI integration
public final class PersistenceController: ObservableObject {
    
    // MARK: - Singleton Instances
    
    /// Shared instance for production use
    public static let shared = PersistenceController()
    
    /// Preview instance for SwiftUI previews with in-memory store and sample data
    public static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Add sample data for previews
        controller.createSampleDataForPreviews()
        
        return controller
    }()
    
    // MARK: - Properties
    
    /// The persistent container that manages the Core Data stack
    public let container: NSPersistentContainer
    
    /// Main context for UI operations (runs on main queue)
    public var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    /// Background context for heavy operations
    public var backgroundContext: NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Logging
    
    private let logger = Logger(subsystem: "com.belly.app", category: "PersistenceController")
    
    // MARK: - Initialization
    
    /// Initialize the persistence controller
    /// - Parameter inMemory: If true, uses an in-memory store for testing/previews
    public init(inMemory: Bool = false) {
        let modelName = "BellyDataModel"
        
        // Check if Core Data model exists in bundle
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") {
            logger.info("✅ Core Data model found at: \(modelURL)")
            container = NSPersistentContainer(name: modelName)
        } else {
            logger.warning("⚠️ Core Data model '\(modelName)' not found in bundle")
            logger.info("🔧 Creating programmatic empty model for development")
            
            // Create a minimal empty model programmatically for development
            let model = NSManagedObjectModel() // Create empty model inline
            container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        }
        
        // Configure for in-memory store if needed (for previews/testing)
        if inMemory {
            setupInMemoryStore()
        }
        
        // Configure container settings
        configureContainer()
        
        // Load persistent stores
        loadPersistentStores()
        
        // Configure view context
        configureViewContext()
    }
    
    // MARK: - Private Setup Methods
    
    private func setupInMemoryStore() {
        if let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
            storeDescription.type = NSInMemoryStoreType
        } else {
            // Create in-memory store description if none exists
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
    }
    
    private func configureContainer() {
        guard let description = container.persistentStoreDescriptions.first else {
            logger.error("Failed to get persistent store description")
            return
        }
        
        // Enable automatic migration
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        
        // Only enable persistent history tracking for non-in-memory stores
        if description.type != NSInMemoryStoreType {
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        logger.info("Configured persistent store description")
    }
    
    private func loadPersistentStores() {
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                self?.logger.error("❌ Core Data failed to load: \(error.localizedDescription)")
                self?.handlePersistentStoreError(error)
            } else {
                self?.logger.info("✅ Core Data loaded successfully")
            }
        }
    }
    
    private func configureViewContext() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Configure for UI responsiveness
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
        
        logger.info("Configured view context")
    }
    
    // MARK: - Error Handling
    
    private func handlePersistentStoreError(_ error: NSError) {
        logger.error("Persistent store error: \(error)")
        logger.error("Error info: \(error.userInfo)")
        
        #if DEBUG
        // In development, we want to know about this immediately
        fatalError("Unresolved Core Data error: \(error)")
        #else
        // In production, handle gracefully
        // You might want to:
        // 1. Try to recover by removing the corrupted store
        // 2. Create a new store
        // 3. Show user-friendly error message
        // 4. Report to crash analytics
        logger.critical("Production Core Data error - app may be unstable")
        #endif
    }
    
    // MARK: - Save Operations
    
    /// Save the view context if it has changes
    public func save() {
        save(context: viewContext)
    }
    
    /// Save a specific context if it has changes
    /// - Parameter context: The context to save
    public func save(context: NSManagedObjectContext) {
        guard context.hasChanges else {
            logger.debug("No changes to save in context")
            return
        }
        
        context.performAndWait {
            do {
                try context.save()
                logger.info("✅ Successfully saved context")
            } catch {
                logger.error("❌ Failed to save context: \(error.localizedDescription)")
                
                // Rollback changes on failure
                context.rollback()
                
                // Post notification for error handling
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .coreDataSaveError,
                        object: nil,
                        userInfo: ["error": error, "context": context]
                    )
                }
            }
        }
    }
    
    /// Perform a background save operation
    /// - Parameter block: The operation to perform in the background context
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        
        context.perform { [weak self] in
            block(context)
            self?.save(context: context)
        }
    }
    
    // MARK: - Data Management
    
    /// Delete all data from the store (useful for testing or reset functionality)
    public func deleteAllData() throws {
        let entities = container.managedObjectModel.entities
        
        for entity in entities {
            guard let entityName = entity.name else { continue }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try viewContext.execute(deleteRequest)
        }
        
        save()
        logger.info("Deleted all data from store")
    }
    
    // MARK: - Sample Data for Previews
    
    /// Create sample data specifically for SwiftUI previews
    private func createSampleDataForPreviews() {
        // This method will be implemented when entities are added
        // For now, it's a placeholder that won't cause errors
        logger.info("Preview sample data creation - ready for entities")
        
        // Example of what this will look like when entities are added:
        /*
        let context = viewContext
        
        // Create sample FoodItem
        let sampleFood = FoodItem(context: context)
        sampleFood.id = UUID()
        sampleFood.name = "Sample Apple"
        sampleFood.dateAdded = Date()
        
        // Create sample GroceryItem
        let sampleGrocery = GroceryItem(context: context)
        sampleGrocery.id = UUID()
        sampleGrocery.name = "Sample Milk"
        sampleGrocery.isPurchased = false
        sampleGrocery.dateAdded = Date()
        
        save(context: context)
        */
    }
    
    // MARK: - Development Helpers
    
    /// Get the URL of the SQLite database file (for debugging)
    public var databaseURL: URL? {
        guard let description = container.persistentStoreDescriptions.first,
              let url = description.url else {
            return nil
        }
        return url
    }
    
    /// Get the size of the database file in bytes (for debugging)
    public var databaseSize: Int64 {
        guard let url = databaseURL else { return 0 }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            logger.error("Failed to get database size: \(error.localizedDescription)")
            return 0
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    /// Posted when a Core Data save operation fails
    public static let coreDataSaveError = Notification.Name("CoreDataSaveError")
}