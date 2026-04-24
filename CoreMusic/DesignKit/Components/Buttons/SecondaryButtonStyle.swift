import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cmCardTitle)
            .foregroundStyle(Color.cmTextPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
