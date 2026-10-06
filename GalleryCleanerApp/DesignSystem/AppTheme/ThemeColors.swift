import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    public static var appCardBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.secondary.opacity(0.15)
        #endif
    }
    
    public static var appViewBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
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
    public static let primaryBlue = Color(red: 0.35, green: 0.25, blue: 0.98)
    public static let accentPink = Color(red: 0.98, green: 0.45, blue: 0.15)
    public static let accentTeal = Color(red: 0.22, green: 0.88, blue: 0.75)
    public static let accentGreen = Color(red: 0.68, green: 0.90, blue: 0.24)
    public static let accentRed = Color(red: 0.95, green: 0.32, blue: 0.38)
    
    public static let storageGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.35, green: 0.25, blue: 0.98),
            Color(red: 0.98, green: 0.45, blue: 0.15)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
        self.navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }
}
