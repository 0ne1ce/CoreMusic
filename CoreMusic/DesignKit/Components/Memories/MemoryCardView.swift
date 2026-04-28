import SwiftUI

struct MemoryCardView: View {
    // MARK: - Properties

    let memory: Memory
    let onFavoriteTap: () -> Void

    // MARK: - Body

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .background { imageView }
            .overlay(alignment: .bottom) { titleBar }
            .overlay(alignment: .topTrailing) {
                FavoriteButton(
                    isFavorite: .init(
                        get: { memory.isFavorite },
                        set: { _ in }
                    ),
                    onTap: onFavoriteTap
                )
                .padding(Spacing.md)
            }
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
    }

    // MARK: - Private properties

    @ViewBuilder
    private var imageView: some View {
        if let photoData = memory.photoData,
           let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        }
        else if let urlString = memory.trackArtworkURLString,
                let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    placeholderView
                }
            }
        }
        else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        LinearGradient(
            colors: [Color.cmPrimaryLight, Color.cmPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "music.note")
                .font(.system(size: Layout.placeholderIconSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var titleBar: some View {
        Text(memory.memoryTitle)
            .font(.cmCallout)
            .foregroundStyle(.white)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(.ultraThinMaterial)
    }
}

// MARK: - Private types

private enum Layout {
    static let cornerRadius: CGFloat = 20
    static let placeholderIconSize: CGFloat = 28
}
