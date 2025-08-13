//
//  AddItemView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI
import CoreData

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddItemViewModel()
    
    @State private var selectedAddMethod: AddMethod = .manual
    @State private var showingCamera = false
    @State private var showingBarcodeScanner = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                // Header
                headerView
                
                // Add Method Selection
                addMethodSelector
                
                // Main Content
                mainContent
                
                Spacer()
                
                // Action Buttons
                actionButtons
            }
            .standardPadding()
            .background(Color.appBackground)
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.oceanBlue)
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView()
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: DesignSystem.Icons.camera)
                .font(.system(size: DesignSystem.Icons.extraLarge))
                .foregroundColor(.oceanBlue)
            
            Text("Add Food to Your Fridge")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
            
            Text("Choose how you'd like to add your food item")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Add Method Selector
    
    private var addMethodSelector: some View {
        Picker("Add Method", selection: $selectedAddMethod) {
            ForEach(AddMethod.allCases, id: \.self) { method in
                Text(method.title)
                    .tag(method)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            switch selectedAddMethod {
            case .camera:
                cameraContent
            case .barcode:
                barcodeContent
            case .manual:
                manualContent
            }
        }
    }
    
    // MARK: - Camera Content
    
    private var cameraContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.oceanBlue)
            
            Text("Take a Photo")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.primaryText)
            
            Text("Snap a picture of your food item and we'll help identify it automatically")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Open Camera") {
                showingCamera = true
            }
            .buttonStyle(backgroundColor: .oceanBlue, foregroundColor: .white)
        }
        .largePadding()
        .cardStyle()
    }
    
    // MARK: - Barcode Content
    
    private var barcodeContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.oceanBlue)
            
            Text("Scan Barcode")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.primaryText)
            
            Text("Scan the barcode on your food package to automatically add product information")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Open Scanner") {
                showingBarcodeScanner = true
            }
            .buttonStyle(backgroundColor: .oceanBlue, foregroundColor: .white)
        }
        .largePadding()
        .cardStyle()
    }
    
    // MARK: - Manual Content
    
    private var manualContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "pencil")
                .font(.system(size: 60))
                .foregroundColor(.oceanBlue)
            
            Text("Manual Entry")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.primaryText)
            
            Text("Enter food details manually with our simple form")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            // Quick Add Options
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Quick Add")
                    .font(DesignSystem.Typography.calloutEmphasized)
                    .foregroundColor(.primaryText)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.md) {
                    ForEach(QuickAddItem.samples, id: \.name) { item in
                        QuickAddButton(item: item) {
                            viewModel.addQuickItem(item, context: viewContext)
                            dismiss()
                        }
                    }
                }
            }
        }
        .largePadding()
        .cardStyle()
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if selectedAddMethod == .manual {
                Button("Create Custom Item") {
                    viewModel.showManualEntry()
                }
                .buttonStyle(backgroundColor: .oceanBlue, foregroundColor: .white)
            }
            
            Button("Add to Shopping List Instead") {
                viewModel.addToShoppingList()
                dismiss()
            }
            .font(DesignSystem.Typography.callout)
            .foregroundColor(.oceanBlue)
        }
    }
}

// MARK: - Add Method Enum

enum AddMethod: String, CaseIterable {
    case camera = "camera"
    case barcode = "barcode"
    case manual = "manual"
    
    var title: String {
        switch self {
        case .camera: return "Camera"
        case .barcode: return "Barcode"
        case .manual: return "Manual"
        }
    }
    
    var icon: String {
        switch self {
        case .camera: return "camera.fill"
        case .barcode: return "barcode.viewfinder"
        case .manual: return "pencil"
        }
    }
}

// MARK: - Quick Add Item

struct QuickAddItem {
    let name: String
    let category: FoodCategory
    let defaultDays: Int
    let emoji: String
    
    static let samples = [
        QuickAddItem(name: "Milk", category: .dairy, defaultDays: 7, emoji: "🥛"),
        QuickAddItem(name: "Bread", category: .pantry, defaultDays: 5, emoji: "🍞"),
        QuickAddItem(name: "Apples", category: .fruits, defaultDays: 7, emoji: "🍎"),
        QuickAddItem(name: "Chicken", category: .meat, defaultDays: 3, emoji: "🍗"),
        QuickAddItem(name: "Carrots", category: .vegetables, defaultDays: 14, emoji: "🥕"),
        QuickAddItem(name: "Yogurt", category: .dairy, defaultDays: 10, emoji: "🍯")
    ]
}

// MARK: - Quick Add Button

struct QuickAddButton: View {
    let item: QuickAddItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(item.emoji)
                    .font(.largeTitle)
                
                Text(item.name)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(.primaryText)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

// MARK: - Placeholder Views

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("📷")
                    .font(.system(size: 100))
                
                Text("Camera View")
                    .font(DesignSystem.Typography.title1)
                
                Text("Camera functionality will be implemented here")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("📊")
                    .font(.system(size: 100))
                
                Text("Barcode Scanner")
                    .font(DesignSystem.Typography.title1)
                
                Text("Barcode scanning functionality will be implemented here")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model

class AddItemViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var selectedMethod: AddMethod = .manual
    
    func addQuickItem(_ item: QuickAddItem, context: NSManagedObjectContext) {
        let expirationDate = Calendar.current.date(byAdding: .day, value: item.defaultDays, to: Date()) ?? Date()
        
        _ = FoodItem.create(
            in: context,
            name: item.name,
            category: item.category,
            quantity: 1.0,
            unit: .pieces,
            expirationDate: expirationDate
        )
        
        try? context.save()
    }
    
    func showManualEntry() {
        // Navigate to detailed manual entry form
    }
    
    func addToShoppingList() {
        // Navigate to shopping list
    }
}

// MARK: - Preview

#Preview {
    AddItemView()
        .environment(\.managedObjectContext, PreviewHelper.createPreviewContext())
}
