//
//  AddItemViewModel.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI
import UIKit
import AVFoundation

class AddItemViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var detectedItems: [DetectedFood] = []
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var errorType: ErrorType?
    @Published var showingCamera = false
    @Published var showingResults = false
    @Published var showingGallery = false
    @Published var showingManualEntry = false
    
    let aiManager = AIManager()
    
    enum ErrorType {
        case noItemsDetected
        case networkError
        case processingError
        case cameraError
        case rateLimitExceeded
        case configurationError
    }
    
    // MARK: - Camera Flow Management
    
    func processImage(_ image: UIImage) async {
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
            errorType = nil
            selectedImage = image
        }
        
        // Use the AI manager to process the image with real OpenAI API
        let results = await aiManager.processImage(image)
        
        await MainActor.run {
            self.isProcessing = false
            
            if results.isEmpty {
                // Check if there was an error in the AI manager
                if let aiError = aiManager.error {
                    self.errorMessage = aiError
                    self.errorType = .processingError
                } else {
                    // No items detected
                    self.errorMessage = "No food items could be identified in this image. Try taking a clearer photo with better lighting, or add items manually."
                    self.errorType = .noItemsDetected
                }
            } else {
                // Success - items detected
                self.detectedItems = results
                self.showingResults = true
            }
        }
    }
    
    func addDetectedItemsToFridge(_ items: [DetectedFood]) {
        // Convert DetectedFood to FoodItem and add to fridge
        let foodItems = items.map { detectedItem in
            FoodItem(
                name: detectedItem.name,
                category: detectedItem.categoryEnum,
                quantity: 1.0, // Default quantity
                unit: .pieces, // Default unit
                expirationDate: Calendar.current.date(byAdding: .day, value: detectedItem.shelfLifeDays, to: Date()) ?? Date(),
                dateAdded: Date(),
                zoneTag: nil,
                storage: detectedItem.storage
            )
        }
        
        // TODO: Add to FridgeViewModel
        // This will be connected to the main FridgeViewModel when integrated
        
        resetFlow()
    }
    
    func resetFlow() {
        selectedImage = nil
        detectedItems.removeAll()
        isProcessing = false
        errorMessage = nil
        errorType = nil
        showingCamera = false
        showingResults = false
        showingGallery = false
        showingManualEntry = false
        aiManager.reset()
    }
    
    // MARK: - Camera Actions
    
    func captureImage() {
        showingCamera = true
    }
    
    func selectFromGallery() {
        showingGallery = true
    }
    
    func addManually() {
        showingManualEntry = true
    }
    
    // MARK: - Error Handling
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - State Management
    
    var canProcessImage: Bool {
        selectedImage != nil && !isProcessing
    }
    
    var hasDetectedItems: Bool {
        !detectedItems.isEmpty
    }
    
    var processingState: AIProcessingState {
        if isProcessing {
            return .processing
        } else if let error = errorMessage {
            return .failed(error)
        } else if !detectedItems.isEmpty {
            return .completed(detectedItems)
        } else {
            return .idle
        }
    }
}

// MARK: - Camera Permission Manager

class CameraPermissionManager: ObservableObject {
    @Published var hasPermission = false
    @Published var showingPermissionAlert = false
    
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasPermission = granted
                    if !granted {
                        self?.showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            hasPermission = false
            showingPermissionAlert = true
        @unknown default:
            hasPermission = false
            showingPermissionAlert = true
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
