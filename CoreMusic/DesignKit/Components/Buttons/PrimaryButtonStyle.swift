import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cmCardTitle)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.cmPrimarySecondary : Color.gray.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isEnabled)
    }
}
