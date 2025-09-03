//
//  DesignSystem.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

/// Central design system for the Belly app
struct DesignSystem {
    
    // MARK: - Spacing
    
    struct Spacing {
        /// Extra small spacing (4pt)
        static let xs: CGFloat = 4
        
        /// Small spacing (8pt)
        static let sm: CGFloat = 8
        
        /// Medium spacing (12pt)
        static let md: CGFloat = 12
        
        /// Large spacing (16pt) - Base spacing unit
        static let lg: CGFloat = 16
        
        /// Extra large spacing (24pt)
        static let xl: CGFloat = 24
        
        /// Extra extra large spacing (32pt)
        static let xxl: CGFloat = 32
        
        /// Extra extra extra large spacing (48pt)
        static let xxxl: CGFloat = 48
        
        // MARK: - Semantic Spacing
        
        /// Standard padding for views
        static let padding = lg
        
        /// Small padding for compact areas
        static let smallPadding = sm
        
        /// Large padding for prominent areas
        static let largePadding = xl
        
        /// Section spacing between major UI elements
        static let sectionSpacing = xl
        
        /// Item spacing within lists or grids
        static let itemSpacing = md
        
        /// Card content padding
        static let cardPadding = lg
    }
    
    // MARK: - Typography
    
    struct Typography {
        // MARK: - Font Weights
        
        /// Regular weight font - Cute and friendly
        static func regular(size: CGFloat) -> Font {
            return .custom("SF Pro Rounded", size: size).weight(.regular)
        }
        
        /// Semibold weight font - Cute and friendly
        static func semibold(size: CGFloat) -> Font {
            return .custom("SF Pro Rounded", size: size).weight(.semibold)
        }
        
        /// Bold weight font - Cute and friendly
        static func bold(size: CGFloat) -> Font {
            return .custom("SF Pro Rounded", size: size).weight(.bold)
        }
        
        /// Cute and playful font for special elements
        static func cute(size: CGFloat) -> Font {
            return .custom("SF Pro Rounded", size: size).weight(.medium)
        }
        
        // MARK: - Font Sizes
        
        /// Large title (34pt)
        static let largeTitle = Font.largeTitle.weight(.bold)
        
        /// Title 1 (28pt)
        static let title1 = semibold(size: 28)
        
        /// Title 2 (22pt)
        static let title2 = semibold(size: 22)
        
        /// Title 3 (20pt)
        static let title3 = semibold(size: 20)
        
        /// Headline (17pt)
        static let headline = semibold(size: 17)
        
        /// Body (17pt)
        static let body = regular(size: 17)
        
        /// Body emphasized (17pt semibold)
        static let bodyEmphasized = semibold(size: 17)
        
        /// Callout (16pt)
        static let callout = regular(size: 16)
        
        /// Callout emphasized (16pt semibold)
        static let calloutEmphasized = semibold(size: 16)
        
        /// Subheadline (15pt)
        static let subheadline = regular(size: 15)
        
        /// Footnote (13pt)
        static let footnote = regular(size: 13)
        
        /// Caption 1 (12pt)
        static let caption1 = regular(size: 12)
        
        /// Caption 2 (11pt)
        static let caption2 = regular(size: 11)
        
        // MARK: - App-Specific Typography
        
        /// Tab bar title
        static let tabTitle = caption1
        
        /// Navigation title
        static let navigationTitle = title1
        
        /// Card title
        static let cardTitle = headline
        
        /// Card subtitle
        static let cardSubtitle = subheadline
        
        /// Badge text
        static let badge = caption2.weight(.semibold)
        
        /// Button text
        static let button = calloutEmphasized
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        /// Extra small radius (8pt) - More rounded for cuteness
        static let xs: CGFloat = 8
        
        /// Small radius (12pt) - More rounded for cuteness
        static let sm: CGFloat = 12
        
        /// Medium radius (16pt) - More rounded for cuteness
        static let md: CGFloat = 16
        
        /// Large radius (20pt) - More rounded for cuteness
        static let lg: CGFloat = 20
        
        /// Extra large radius (24pt) - More rounded for cuteness
        static let xl: CGFloat = 24
        
        /// Extra extra large radius (28pt) - More rounded for cuteness
        static let xxl: CGFloat = 28
        
        // MARK: - Semantic Corner Radius
        
        /// Standard card corner radius
        static let card = lg
        
        /// Button corner radius
        static let button = md
        
        /// Badge corner radius
        static let badge = sm
        
        /// Tab bar corner radius
        static let tab = md
    }
    
    // MARK: - Shadows
    
    struct Shadow {
        /// Light shadow for subtle elevation
        static let light = Shadow(
            color: Color.black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
        
        /// Medium shadow for cards
        static let medium = Shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        
        /// Heavy shadow for modals
        static let heavy = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Icons
    
    struct Icons {
        /// Standard icon size (24pt)
        static let standard: CGFloat = 24
        
        /// Small icon size (16pt)
        static let small: CGFloat = 16
        
        /// Large icon size (32pt)
        static let large: CGFloat = 32
        
        /// Extra large icon size (48pt)
        static let extraLarge: CGFloat = 48
        
        // MARK: - Tab Icons
        
        static let fridgeTab = "house"
        static let addTab = "camera.fill"
        static let shoppingTab = "cart"
        
        // MARK: - Food Status Icons
        
        static let fresh = "checkmark.circle.fill"
        static let expiring = "exclamationmark.triangle.fill"
        static let expired = "xmark.circle.fill"
        static let purchased = "checkmark.circle"
        
        // MARK: - Action Icons
        
        static let add = "plus"
        static let edit = "pencil"
        static let delete = "trash"
        static let search = "magnifyingglass"
        static let filter = "line.3.horizontal.decrease.circle"
        static let settings = "gearshape"
        static let camera = "camera.fill"
        static let barcode = "barcode.viewfinder"
    }
    
    // MARK: - Animation
    
    struct Animation {
        /// Quick animation duration (0.2s)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        
        /// Standard animation duration (0.3s)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        /// Slow animation duration (0.5s)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        
        /// Spring animation
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        
        /// Bounce animation
        static let bounce = SwiftUI.Animation.interpolatingSpring(stiffness: 300, damping: 10)
    }
    
    // MARK: - Layout
    
    struct Layout {
        /// Minimum touch target size (44pt)
        static let minimumTouchTarget: CGFloat = 44
        
        /// Standard button height (48pt)
        static let buttonHeight: CGFloat = 48
        
        /// Card minimum height (80pt)
        static let cardMinHeight: CGFloat = 80
        
        /// Tab bar height (49pt on iPhone)
        static let tabBarHeight: CGFloat = 49
        
        /// Navigation bar height (44pt)
        static let navigationBarHeight: CGFloat = 44
    }
    
    // MARK: - Cute Design Elements
    
    struct Cute {
        /// Soft shadow for cards
        static let softShadow = Shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
        
        /// Extra soft shadow for subtle elements
        static let extraSoftShadow = Shadow(
            color: Color.black.opacity(0.04),
            radius: 6,
            x: 0,
            y: 2
        )
        
        /// Cute button padding
        static let buttonPadding: CGFloat = 20
        
        /// Cute card padding
        static let cardPadding: CGFloat = 20
        
        /// Cute spacing between elements
        static let elementSpacing: CGFloat = 16
    }
}

// MARK: - View Modifiers

extension View {
    
    /// Apply card style with shadow and background
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .shadow(
                color: DesignSystem.Shadow.medium.color,
                radius: DesignSystem.Shadow.medium.radius,
                x: DesignSystem.Shadow.medium.x,
                y: DesignSystem.Shadow.medium.y
            )
    }
    
    /// Apply standard padding
    func standardPadding() -> some View {
        self.padding(DesignSystem.Spacing.padding)
    }
    
    /// Apply small padding
    func smallPadding() -> some View {
        self.padding(DesignSystem.Spacing.smallPadding)
    }
    
    /// Apply large padding
    func largePadding() -> some View {
        self.padding(DesignSystem.Spacing.largePadding)
    }
    
    /// Apply button style
    func buttonStyle(
        backgroundColor: Color = .primary,
        foregroundColor: Color = .white
    ) -> some View {
        self
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .font(DesignSystem.Typography.button)
    }
    
    /// Apply badge style
    func badgeStyle(
        backgroundColor: Color = .primary,
        foregroundColor: Color = .white
    ) -> some View {
        self
            .font(DesignSystem.Typography.badge)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.badge)
    }
    
    /// Apply cute card style with soft shadows
    func cuteCardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .shadow(
                color: DesignSystem.Cute.softShadow.color,
                radius: DesignSystem.Cute.softShadow.radius,
                x: DesignSystem.Cute.softShadow.x,
                y: DesignSystem.Cute.softShadow.y
            )
    }
    
    /// Apply cute button style
    func cuteButtonStyle(
        backgroundColor: Color = .oceanBlue,
        foregroundColor: Color = .white
    ) -> some View {
        self
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .font(DesignSystem.Typography.button)
            .shadow(
                color: DesignSystem.Cute.extraSoftShadow.color,
                radius: DesignSystem.Cute.extraSoftShadow.radius,
                x: DesignSystem.Cute.extraSoftShadow.x,
                y: DesignSystem.Cute.extraSoftShadow.y
            )
    }
    
    /// Apply cute dropdown style with proper text visibility
    func cuteDropdownStyle() -> some View {
        self
            .foregroundColor(Color.dropdownText)
            .background(Color.dropdownBackground)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(Color.formBorder, lineWidth: 1)
            )
    }
    
    /// Apply cute form field style
    func cuteFormFieldStyle() -> some View {
        self
            .foregroundColor(Color.formText)
            .background(Color.dropdownBackground)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(Color.formBorder, lineWidth: 1)
            )
    }
}
