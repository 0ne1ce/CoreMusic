import SwiftUI

struct MemoryCardView: View {
    // MARK: - Properties

    let memory: Memory
    let onFavoriteTap: () -> Void
    var yearBadgeText: String?
    var subtitle: String?
    var cardAspectRatio: CGFloat = 1
    var showDimOverlay: Bool = false
    var favoriteButtonSize: CGFloat = 16

    // MARK: - Body

    var body: some View {
        Color.clear
            .aspectRatio(cardAspectRatio, contentMode: .fit)
            .background { imageView }
            .overlay {
                if showDimOverlay {
                    Color.black.opacity(Layout.dimOverlayOpacity)
                }
            }
            .overlay(alignment: .topLeading) {
                if let yearBadgeText {
                    yearBadge(yearBadgeText)
                }
            }
            .overlay(alignment: .bottom) { titleBar }
            .overlay(alignment: .topTrailing) {
                FavoriteButton(
                    isFavorite: .init(
                        get: { memory.isFavorite },
                        set: { _ in }
                    ),
                    onTap: onFavoriteTap,
                    size: favoriteButtonSize
                )
                .padding(Spacing.md)
            }
            .contentShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
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

    private func yearBadge(_ text: String) -> some View {
        Text(text)
            .font(.cmBody.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(Spacing.md)
            .offset()
    }

    private var titleBar: some View {
        VStack(spacing: subtitle != nil ? Spacing.xs : 0) {
            Text(memory.memoryTitle)
                .font(subtitle != nil ? .cmCardTitle : .cmCallout)
                .foregroundStyle(.white)
                .lineLimit(1)

            if let subtitle {
                Text(subtitle)
                    .font(.cmFootnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
            }
        }
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
    static let dimOverlayOpacity: Double = 0.1
}