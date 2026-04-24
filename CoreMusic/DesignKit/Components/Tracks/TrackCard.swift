import SwiftUI

struct TrackCardView: View {

    let model: TrackCardModel
    var onReveal: (() -> Void)? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .trailing) {
            memoryButton
            cardView
        }
    }
    
    @State private var offset: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0
    @State private var isRevealed = false

    private var memoryButton: some View {
        Button {
            onAction?()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: Layout.MemoryButton.iconSize, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: Layout.MemoryButton.size, height: Layout.MemoryButton.size)
                .background(Color.cmPrimarySecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.MemoryButton.cornerRadius))
        }
        .padding(.trailing, Spacing.sm)
        .opacity(isRevealed ? 1 : 0)
        .animation(
            .easeInOut(duration: Layout.MemoryButton.appearAnimationDuration),
            value: isRevealed
        )
    }

    private var cardView: some View {
        HStack(spacing: Spacing.md) {
            artworkView
                .frame(width: Layout.Card.Artwork.size, height: Layout.Card.Artwork.size)
                .clipShape(RoundedRectangle(cornerRadius: Layout.Card.Artwork.cornerRadius))

            trackInfoView(title: model.title, artist: model.artist)

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundStyle(Color.cmTextSecondary)
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Layout.Card.height)
        .background(
            RoundedRectangle(cornerRadius: Layout.Card.cornerRadius)
                .fill(model.isPlaying ? Color.cmPrimarySecondary.opacity(0.1) : Color.cmBackgroundLight)
        )
        .offset(x: offset)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let proposed = dragStartOffset + value.translation.width
                    if proposed > 0 {
                        offset = proposed * Layout.Card.DragAnimation.rubberBand
                    }
                    else if proposed < -Layout.Card.DragAnimation.revealWidth {
                        let overshoot = -Layout.Card.DragAnimation.revealWidth - proposed
                        offset = -Layout.Card.DragAnimation.revealWidth - overshoot * Layout.Card.DragAnimation.rubberBand
                    }
                    else {
                        offset = proposed
                    }
                }
                .onEnded { _ in
                    let shouldReveal = offset < -Layout.Card.DragAnimation.revealWidth / 2
                    let target: CGFloat = shouldReveal ? -Layout.Card.DragAnimation.revealWidth : 0
                    withAnimation(
                        .spring(
                            response: Layout.Card.DragAnimation.velocity,
                            dampingFraction: Layout.Card.DragAnimation.bounce
                        )
                    ) {
                        offset = target
                    }
                    dragStartOffset = target
                    if shouldReveal, !isRevealed {
                        isRevealed = true
                        onReveal?()
                    }
                    else if !shouldReveal {
                        isRevealed = false
                    }
                }
        )
    }
    
    private func trackInfoView(title: String, artist: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(model.title)
                .font(.cmCardTitle)
                .foregroundStyle(model.isPlaying ? Color.cmPrimarySecondary : Color.cmTextPrimary)
                .lineLimit(1)

            Text(model.artist)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var artworkView: some View {
        if let url = model.artworkURL {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                artworkPlaceholderView
            }
        } else {
            artworkPlaceholderView
        }
    }

    private var artworkPlaceholderView: some View {
        LinearGradient(
            colors: [Color.cmPrimarySecondary, Color.cmPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "music.note")
                .font(.system(size: Layout.Card.Artwork.placeholderIconSize, weight: .semibold))
                .foregroundStyle(.white)
        )
    }
}

private enum Layout {
    enum MemoryButton {
        static let size: CGFloat = 44
        static let iconSize: CGFloat = 16
        static let cornerRadius: CGFloat = 10
        static let appearAnimationDuration: CGFloat = 0.2
    }
    
    enum Card {
        enum Artwork {
            static let size: CGFloat = 44
            static let cornerRadius: CGFloat = 8
            static let placeholderIconSize: CGFloat = 18
        }
        
        enum DragAnimation {
            static let revealWidth: CGFloat = 60
            static let velocity: CGFloat = 0.3
            static let bounce: CGFloat = 0.75
            static let rubberBand: CGFloat = 0.3
        }
        
        static let height: CGFloat = 64
        static let cornerRadius: CGFloat = 12
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        TrackCardView(model: TrackCardModel(
            id: "1",
            title: "Playing TrackPlaying TrackPlaying Track",
            artist: "ArtistPlaying TrackPlaying Track",
            artworkURL: nil
        ))

        TrackCardView(model: TrackCardModel(
            id: "2",
            title: "Playing Track",
            artist: "Artist",
            artworkURL: nil
        ))

        TrackCardView(model: TrackCardModel(
            id: "3",
            title: "Playing Track",
            artist: "Artist",
            artworkURL: nil
        ))
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
