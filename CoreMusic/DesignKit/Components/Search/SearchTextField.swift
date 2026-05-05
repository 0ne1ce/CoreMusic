import SwiftUI

struct SearchTextField: View {
    // MARK: - Properties

    @Binding var text: String

    // MARK: - Initializer

    init(text: Binding<String>, placeholder: String = "Найти") {
        self._text = text
        self.placeholder = placeholder
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.cmTextSecondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .tint(Color.cmPrimaryLight)
                .autocorrectionDisabled()
                .submitLabel(.search)

            trailingButton
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 44)
        .background(Color.cmBackgroundLight)
        .clipShape(Capsule())
    }

    // MARK: - Private properties

    private let placeholder: String

    // MARK: - Private methods

    @ViewBuilder
    private var trailingButton: some View {
        if !text.isEmpty {
            Button {
                text = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.cmTextSecondary)
            }
            .buttonStyle(.plain)
        }
    }
}
