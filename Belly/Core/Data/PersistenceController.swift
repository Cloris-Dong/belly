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
public final class PersistenceController: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance for production use
    public static let shared = PersistenceController()
    
    /// Preview instance for SwiftUI previews with in-memory store
    public static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Wait for container to load, then add sample data
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        controller.container.loadPersistentStores { _, error in
            if error == nil {
                // Only create sample data if store loaded successfully
                controller.createSampleDataForPreview()
            }
            dispatchGroup.leave()
        }
        
        // Wait for loading to complete (with timeout for safety)
        _ = dispatchGroup.wait(timeout: .now() + 2.0)
        
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
        container = NSPersistentContainer(name: "BellyDataModel")
        
        if inMemory {
            // Safe unwrapping for preview context
            if let storeDescription = container.persistentStoreDescriptions.first {
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
            } else {
                // Create a default in-memory store description if none exists
                let description = NSPersistentStoreDescription()
                description.url = URL(fileURLWithPath: "/dev/null")
                description.type = NSInMemoryStoreType
                container.persistentStoreDescriptions = [description]
            }
        }
        
        configureContainer()
        
        // For non-preview contexts, load stores immediately
        if !inMemory {
            loadPersistentStores()
            configureViewContext()
        }
    }
    
    // MARK: - Configuration
    
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
                self?.logger.error("Core Data failed to load: \(error.localizedDescription)")
                self?.handlePersistentStoreError(error)
            } else {
                self?.logger.info("Core Data loaded successfully")
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
        // Log the error details
        logger.error("Persistent store error: \(error)")
        logger.error("Error info: \(error.userInfo)")
        
        // In a production app, you might want to:
        // 1. Try to recover by removing the corrupted store
        // 2. Create a new store
        // 3. Show user-friendly error message
        // 4. Report to crash analytics
        
        fatalError("Unresolved Core Data error: \(error)")
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
                logger.info("Successfully saved context")
            } catch {
                logger.error("Failed to save context: \(error.localizedDescription)")
                
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
    
    // MARK: - Batch Operations
    
    /// Perform a batch delete operation
    /// - Parameters:
    ///   - request: The fetch request for items to delete
    ///   - context: The context to use (defaults to background context)
    public func batchDelete<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        in context: NSManagedObjectContext? = nil
    ) throws {
        let deleteContext = context ?? backgroundContext
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try deleteContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                // Merge changes into view context
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            }
            
            logger.info("Batch delete completed for \(String(describing: T.self))")
        } catch {
            logger.error("Batch delete failed: \(error.localizedDescription)")
            throw error
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
    
    /// Get the URL of the SQLite database file
    public var databaseURL: URL? {
        guard let description = container.persistentStoreDescriptions.first,
              let url = description.url else {
            return nil
        }
        return url
    }
    
    /// Get the size of the database file in bytes
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

// MARK: - Sample Data Creation
extension PersistenceController {
    
    /// Create sample data for previews and testing
    public func createSampleData() {
        let context = viewContext
        
        // Create sample food items
        createSampleFoodItems(in: context)
        
        // Create sample grocery items
        createSampleGroceryItems(in: context)
        
        save(context: context)
        logger.info("Created sample data")
    }
    
    /// Create sample data specifically for SwiftUI previews
    public func createSampleDataForPreview() {
        let context = viewContext
        
        // Configure context for preview use
        configureViewContext()
        
        // Create a minimal set of sample data for previews
        createPreviewFoodItems(in: context)
        createPreviewGroceryItems(in: context)
        
        // Save synchronously for preview
        do {
            try context.save()
            logger.info("Created preview sample data")
        } catch {
            logger.error("Failed to save preview data: \(error.localizedDescription)")
        }
    }
    
    private func createSampleFoodItems(in context: NSManagedObjectContext) {
        let sampleItems = [
            ("Apples", FoodCategory.fruits, 6.0, FoodUnit.pieces, Calendar.current.date(byAdding: .day, value: 5, to: Date())!, "Refrigerator"),
            ("Milk", FoodCategory.dairy, 1.0, FoodUnit.cartons, Calendar.current.date(byAdding: .day, value: 3, to: Date())!, "Refrigerator"),
            ("Chicken Breast", FoodCategory.meat, 0.5, FoodUnit.kilograms, Calendar.current.date(byAdding: .day, value: 2, to: Date())!, "Refrigerator"),
            ("Bread", FoodCategory.pantry, 1.0, FoodUnit.packages, Calendar.current.date(byAdding: .day, value: 7, to: Date())!, "Pantry"),
            ("Carrots", FoodCategory.vegetables, 1.0, FoodUnit.packages, Calendar.current.date(byAdding: .day, value: 10, to: Date())!, "Refrigerator"),
            ("Leftover Pizza", FoodCategory.leftovers, 4.0, FoodUnit.pieces, Calendar.current.date(byAdding: .day, value: 1, to: Date())!, "Refrigerator"),
            ("Orange Juice", FoodCategory.beverages, 1.0, FoodUnit.cartons, Calendar.current.date(byAdding: .day, value: 7, to: Date())!, "Refrigerator"),
            ("Ketchup", FoodCategory.condiments, 1.0, FoodUnit.bottles, Calendar.current.date(byAdding: .day, value: 90, to: Date())!, "Refrigerator"),
            ("Frozen Peas", FoodCategory.frozen, 1.0, FoodUnit.packages, Calendar.current.date(byAdding: .day, value: 60, to: Date())!, "Freezer"),
            ("Expired Yogurt", FoodCategory.dairy, 2.0, FoodUnit.packages, Calendar.current.date(byAdding: .day, value: -2, to: Date())!, "Refrigerator")
        ]
        
        for (name, category, quantity, unit, expirationDate, storage) in sampleItems {
            _ = FoodItem.create(
                in: context,
                name: name,
                category: category,
                quantity: quantity,
                unit: unit,
                expirationDate: expirationDate,
                storage: storage
            )
        }
    }
    
    private func createSampleGroceryItems(in context: NSManagedObjectContext) {
        let sampleItems = [
            ("Bananas", FoodCategory.fruits, false),
            ("Greek Yogurt", FoodCategory.dairy, false),
            ("Ground Beef", FoodCategory.meat, false),
            ("Whole Wheat Pasta", FoodCategory.pantry, true),
            ("Spinach", FoodCategory.vegetables, false),
            ("Sparkling Water", FoodCategory.beverages, false),
            ("Ice Cream", FoodCategory.frozen, false),
            ("Mustard", FoodCategory.condiments, true),
            ("Cheese", FoodCategory.dairy, false),
            ("Tomatoes", FoodCategory.vegetables, false)
        ]
        
        for (name, category, isPurchased) in sampleItems {
            _ = GroceryItem.create(
                in: context,
                name: name,
                category: category,
                isPurchased: isPurchased
            )
        }
    }
    
    // MARK: - Preview-Specific Sample Data
    
    private func createPreviewFoodItems(in context: NSManagedObjectContext) {
        // Minimal sample data for previews to avoid performance issues
        let previewItems = [
            ("Fresh Apples", FoodCategory.fruits, 4.0, FoodUnit.pieces, Calendar.current.date(byAdding: .day, value: 7, to: Date())!, "Refrigerator"),
            ("Milk", FoodCategory.dairy, 1.0, FoodUnit.cartons, Calendar.current.date(byAdding: .day, value: 2, to: Date())!, "Refrigerator"),
            ("Expired Bread", FoodCategory.pantry, 1.0, FoodUnit.packages, Calendar.current.date(byAdding: .day, value: -1, to: Date())!, "Pantry")
        ]
        
        for (name, category, quantity, unit, expirationDate, storage) in previewItems {
            _ = FoodItem.create(
                in: context,
                name: name,
                category: category,
                quantity: quantity,
                unit: unit,
                expirationDate: expirationDate,
                storage: storage
            )
        }
    }
    
    private func createPreviewGroceryItems(in context: NSManagedObjectContext) {
        // Minimal grocery items for preview
        let previewItems = [
            ("Bananas", FoodCategory.fruits, false),
            ("Greek Yogurt", FoodCategory.dairy, true),
            ("Spinach", FoodCategory.vegetables, false)
        ]
        
        for (name, category, isPurchased) in previewItems {
            _ = GroceryItem.create(
                in: context,
                name: name,
                category: category,
                isPurchased: isPurchased
            )
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    /// Posted when a Core Data save operation fails
    public static let coreDataSaveError = Notification.Name("CoreDataSaveError")
}
