import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    public static var appCardBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.secondary.opacity(0.15)
        #endif
    }
    
    public static var appViewBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.primary.opacity(0.05)
        #endif
    }
    
    public static var appSystemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.black
        #endif
    }
    
    public static var appSystemGray5: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }
    
    public static var appTertiaryLabel: Color {
        #if canImport(UIKit)
        return Color(UIColor.tertiaryLabel)
        #else
        return Color.secondary.opacity(0.6)
        #endif
    }
}

public enum AppTheme {
    public static let primaryBlue = Color(red: 0.12, green: 0.53, blue: 0.98)
    public static let accentPink = Color(red: 0.98, green: 0.25, blue: 0.55)
    public static let accentTeal = Color(red: 0.12, green: 0.78, blue: 0.65)
    public static let accentGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    public static let accentRed = Color(red: 0.95, green: 0.22, blue: 0.28)
    
    public static let storageGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.95, green: 0.25, blue: 0.60),
            Color(red: 0.25, green: 0.55, blue: 0.98)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    public static let cardBackground = Color.appCardBackground
    public static let viewBackground = Color.appViewBackground
    public static let rowBackground = Color.appCardBackground
    
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
    public static let textMuted = Color.appTertiaryLabel
}

extension View {
    @ViewBuilder
    public func appInlineTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
