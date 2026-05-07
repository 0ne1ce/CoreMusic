import SwiftUI

struct MemoryTagView: View {
    // MARK: - Properties

    let text: String

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(.cmFootnote)
            .foregroundStyle(Color.cmTextPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs + 2)
            .background(Capsule().fill(Color.cmBackgroundLight.opacity(0.85)))
            .lineLimit(1)
    }
}
