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
    @Published var showingCamera = false
    @Published var showingResults = false
    @Published var showingGallery = false
    @Published var showingManualEntry = false
    
    private let aiManager = AIManager()
    
    // MARK: - Camera Flow Management
    
    func processImage(_ image: UIImage) async {
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
            selectedImage = image
        }
        
        do {
            let results = await aiManager.processImage(image)
            
            await MainActor.run {
                detectedItems = results
                isProcessing = false
                
                if results.isEmpty {
                    errorMessage = "No food items detected. Try a different photo or add manually."
                } else {
                    showingResults = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to process image: \(error.localizedDescription)"
                isProcessing = false
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
