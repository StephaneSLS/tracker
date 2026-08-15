import SwiftUI

/// Cockpit-instrument visual language shared by every screen: deep navy panels,
/// cyan/amber instrument accents, monospaced numeric readouts.
enum Theme {
    static let background = Color(red: 0.02, green: 0.04, blue: 0.09)
    static let panelBackground = Color(red: 0.06, green: 0.09, blue: 0.15)
    static let panelBackgroundElevated = Color(red: 0.09, green: 0.13, blue: 0.20)
    static let hairline = Color(red: 0.18, green: 0.24, blue: 0.32)
    static let trackBackground = Color(red: 0.11, green: 0.15, blue: 0.22)

    static let cyan = Color(red: 0.31, green: 0.82, blue: 0.77)      // #4FD1C5
    static let amber = Color(red: 1.0, green: 0.69, blue: 0.125)     // #FFB020
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.42)      // fat
    static let violet = Color(red: 0.49, green: 0.61, blue: 1.0)     // carbs

    static let textPrimary = Color(red: 0.93, green: 0.96, blue: 0.98)
    static let textSecondary = Color(red: 0.55, green: 0.63, blue: 0.72)
    static let textTertiary = Color(red: 0.36, green: 0.43, blue: 0.52)

    static func displayFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func monoFont(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static let labelFont: Font = .system(size: 11, weight: .semibold, design: .rounded)
}

extension View {
    /// Standard instrument-panel card treatment used across the app.
    func panelStyle(cornerRadius: CGFloat = 18) -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.panelBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
    }
}
