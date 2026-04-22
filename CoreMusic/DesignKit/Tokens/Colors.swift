import SwiftUI

// MARK: - Color Tokens

extension Color {
    static let cmPrimary = Color("PrimaryCm")
    static let cmPrimarySecondary = Color("PrimarySecondaryCm")

    static let cmAppleMusic = Color("AppleMusic")

    static let cmDanger = Color("Danger")
    static let cmWarning = Color("Warning")
    static let cmSuccess = Color("Success")
    static let cmInfo = Color("Info")

    static let cmFavorite = Color("favorite")

    // MARK: - Text

    static let cmTextPrimary = Color("TextPrimary")
    static let cmTextSecondary = Color("TextSecondary")

    // MARK: - Background

    static let cmBackgroundPrimary = Color("BackgroundPrimary")
    static let cmBackgroundLight = Color("BackgroundLight")
    static let cmBackgroundGlobal = Color("BackgroundGlobal")

    // MARK: - Utility

    static let cmOverlay = Color.black.opacity(0.4)
}
