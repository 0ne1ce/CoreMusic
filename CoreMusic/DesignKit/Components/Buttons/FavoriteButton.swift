import SwiftUI

struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            isFavorite.toggle()
            onTap()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(isFavorite ? Color.cmFavorite : .white)
                .frame(width: size, height: size)
                .contentShape(Rectangle())
                .symbolEffect(.bounce.down, options: .speed(2), value: isFavorite)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(trigger: isFavorite) { _, newValue in
            newValue ? .success : .impact(weight: .light)
        }
    }
    
    private let size: CGFloat = 16
}
