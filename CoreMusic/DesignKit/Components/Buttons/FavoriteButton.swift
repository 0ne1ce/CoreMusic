import SwiftUI

struct FavoriteButton: View {
    // MARK: - Properties

    @Binding var isFavorite: Bool
    let onTap: () -> Void
    var size: CGFloat = 16

    // MARK: - Body

    var body: some View {
        Button {
            isFavorite.toggle()
            onTap()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(isFavorite ? .favorite : .white)
                .frame(width: size, height: size)
                .contentShape(Rectangle())
                .symbolEffect(.bounce.down, options: .speed(2), value: isFavorite)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(trigger: isFavorite) { _, newValue in
            newValue ? .success : .impact(weight: .light)
        }
    }
}
