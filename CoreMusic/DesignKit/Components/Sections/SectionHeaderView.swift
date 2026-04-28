import SwiftUI

struct SectionHeaderView: View {
    // MARK: - Properties

    let title: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.cmSectionTitle)
                    .foregroundStyle(Color.cmTextPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.cmTextSecondary)
                    .offset(y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SectionHeaderView(title: "aavfbafba", action: {})
}
