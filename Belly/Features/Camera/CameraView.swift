//
//  CameraView.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Use camera on device, photo library in simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        } else {
            picker.sourceType = .photoLibrary  // Simulator fallback
        }
        
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageCaptured(image)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: - Camera Interface Overlay
struct CameraInterfaceOverlay: View {
    @Binding var showingGallery: Bool
    @Binding var showingManualEntry: Bool
    let onCapture: () -> Void
    let isLoading: Bool
    
    var body: some View {
        ZStack {
            // Top instruction
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Capture up to 3 items")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Position items clearly in frame")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(Color.black.opacity(0.6))
                    )
                    Spacer()
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Gallery and manual entry buttons
                    HStack {
                        Button(action: { showingGallery = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                Text("Gallery")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .fill(Color.black.opacity(0.6))
                            )
                        }
                        
                        Spacer()
                        
                        Button(action: { showingManualEntry = true }) {
                            Text("Add manually")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                        .fill(Color.black.opacity(0.6))
                                )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    // Capture button
                    Button(action: onCapture) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                            
                            Circle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 4)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1.0)
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
            
            // Loading overlay
            if isLoading {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Analyzing...")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(DesignSystem.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(Color.black.opacity(0.8))
                )
            }
        }
    }
}
