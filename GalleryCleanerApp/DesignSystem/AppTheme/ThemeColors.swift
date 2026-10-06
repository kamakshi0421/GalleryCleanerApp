import SwiftUI

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
    
    public static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    public static let viewBackground = Color(UIColor.systemGroupedBackground)
    public static let rowBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
    public static let textMuted = Color(UIColor.tertiaryLabel)
}
