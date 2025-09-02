//
//  AddItemView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

struct AddItemView: View {
    @StateObject private var viewModel = AddItemViewModel()
    @StateObject private var permissionManager = CameraPermissionManager()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingManualEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.oceanBlue)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Add Items")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Take a photo to automatically detect food items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xxl)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Camera button
                        Button(action: {
                            checkCameraPermissionAndCapture()
                        }) {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text("Take Photo")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                    .fill(Color.oceanBlue)
                            )
                        }
                        
                        // Gallery picker
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                Text("Choose from Gallery")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.oceanBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                    .stroke(Color.oceanBlue, lineWidth: 2)
                            )
                        }
                        
                        // Manual entry button
                        Button(action: { showingManualEntry = true }) {
                            Text("Add Manually")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer()
                    
                    // Tips section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Tips for better detection:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            TipRow(icon: "light.max", text: "Ensure good lighting")
                            TipRow(icon: "camera.viewfinder", text: "Position items clearly in frame")
                            TipRow(icon: "number", text: "Capture up to 3 items at once")
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(Color(.systemBackground))
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                    )
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
                
                // Error overlay
                if viewModel.hasError {
                    errorOverlay
                }
                
                // Loading overlay
                if viewModel.isProcessing {
                    loadingOverlay
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $viewModel.showingCamera) {
            CameraView(
                selectedImage: $viewModel.selectedImage,
                isPresented: $viewModel.showingCamera,
                onImageCaptured: { image in
                    Task {
                        await viewModel.processImage(image)
                    }
                }
            )
            .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $viewModel.showingResults) {
            AIResultsView(detectedItems: $viewModel.detectedItems)
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualEntryView()
        }
        .onChange(of: selectedPhoto) { newPhoto in
            if let newPhoto = newPhoto {
                loadImageFromGallery(newPhoto)
            }
        }
        .alert("Camera Permission Required", isPresented: $permissionManager.showingPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                permissionManager.openSettings()
            }
        } message: {
            Text("Camera access is needed to detect food items. Please enable camera access in Settings.")
        }
        .alert("Error", isPresented: .constant(viewModel.hasError)) {
            if viewModel.errorType == .networkError {
                Button("Retry") {
                    if let image = viewModel.selectedImage {
                        Task {
                            await viewModel.processImage(image)
                        }
                    }
                }
            }
            
            Button("Add Manually") {
                showingManualEntry = true
                viewModel.clearError()
            }
            
            Button("Cancel") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .oceanBlue))
            
            Text("Analyzing Image...")
                .font(.headline)
            
            Text("Identifying food items using AI")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
    
    // MARK: - Error Overlay
    
    private var errorOverlay: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.softCoral)
            
            Text("Something went wrong")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Try Again") {
                viewModel.clearError()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(Color.oceanBlue)
            )
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .padding(DesignSystem.Spacing.lg)
    }
    
    // MARK: - Gallery Image Loading
    
    private func loadImageFromGallery(_ item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        viewModel.selectedImage = image
                        Task {
                            await viewModel.processImage(image)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Failed to load image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Camera Permission Handling
    
    private func checkCameraPermissionAndCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Camera is authorized, proceed with capture
            viewModel.captureImage()
            
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        viewModel.captureImage()
                    } else {
                        permissionManager.showingPermissionAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied, show alert
            permissionManager.showingPermissionAlert = true
            
        @unknown default:
            // Handle future cases
            permissionManager.showingPermissionAlert = true
        }
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.oceanBlue)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    AddItemView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}