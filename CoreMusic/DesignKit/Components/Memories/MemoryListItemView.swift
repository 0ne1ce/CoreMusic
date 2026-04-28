import SwiftUI

struct MemoryListItemView: View {
    // MARK: - Properties

    let memory: Memory

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.md) {
            artworkView

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(memory.memoryTitle)
                    .font(.cmCardTitle)
                    .foregroundStyle(Color.cmTextPrimary)
                    .lineLimit(2)

                Text("\(memory.songTitle) · \(memory.artistName)")
                    .font(.cmSecondary)
                    .foregroundStyle(Color.cmTextSecondary)
                    .lineLimit(1)

                Text(memory.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.cmMeta)
                    .foregroundStyle(Color.cmTextSecondary)

                if !memory.note.isEmpty {
                    Text(memory.note)
                        .font(.cmFootnote)
                        .foregroundStyle(Color.cmTextSecondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .background(Color.cmBackgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
    }

    // MARK: - Private methods

    @ViewBuilder
    private var artworkView: some View {
        if let artworkURL = URL(string: memory.trackArtworkURLString ?? "") {
            AsyncImage(url: artworkURL) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    placeholderArtworkView
                }
            }
            .frame(width: Layout.artworkSize, height: Layout.artworkSize)
            .clipShape(RoundedRectangle(cornerRadius: Layout.artworkCornerRadius))
        }
        else {
            placeholderArtworkView
        }
    }

    private var placeholderArtworkView: some View {
        LinearGradient(
            colors: [Color.cmPrimarySecondary, Color.cmPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: memory.isFavorite ? "heart.fill" : "music.note")
                .font(.cmCardTitle)
                .foregroundStyle(.white)
        }
        .frame(width: Layout.artworkSize, height: Layout.artworkSize)
        .clipShape(RoundedRectangle(cornerRadius: Layout.artworkCornerRadius))
    }
}

private enum Layout {
    static let cornerRadius: CGFloat = 18
    static let artworkSize: CGFloat = 72
    static let artworkCornerRadius: CGFloat = 16
}
