import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties

    let systemImage: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?

    // MARK: - Initializer

    init(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 48, weight: .regular))
                .foregroundStyle(Color.cmTextSecondary)

            Text(title)
                .font(.cmCardTitle)
                .foregroundStyle(Color.cmTextPrimary)
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.top, Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }
}
