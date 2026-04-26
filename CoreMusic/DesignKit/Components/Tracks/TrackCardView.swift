import MusicKit
import SwiftUI

struct TrackCardView: View {
    // MARK: - Public types

    enum InteractionMode {
        case plain
        case swipeReveal(onReveal: () -> Void)
    }

    // MARK: - Properties

    let model: TrackCardModel
    let interactionMode: InteractionMode

    // MARK: - Body

    var body: some View {
        switch interactionMode {
        case .plain:
            plainCardView
        case .swipeReveal:
            ZStack(alignment: .trailing) {
                revealBackgroundView
                swipeableCardView
            }
        }
    }

    // MARK: - Initializer

    init(model: TrackCardModel, interactionMode: InteractionMode = .plain) {
        self.model = model
        self.interactionMode = interactionMode
    }

    // MARK: - Private properties

    @State private var offset: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0
    @State private var isRevealed = false

    // MARK: - Private methods

    private var swipeableCardView: some View {
        plainCardView
            .offset(x: offset)
            .gesture(swipeGesture)
    }

    private var plainCardView: some View {
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
        .contentShape(Rectangle())
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: Layout.Card.DragAnimation.minimumDistance)
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
            .onEnded { value in
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
                    handleReveal()
                }
                else if !shouldReveal {
                    isRevealed = false
                }
            }
    }

    private func trackInfoView(title: String, artist: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.cmCardTitle)
                .foregroundStyle(model.isPlaying ? Color.cmPrimarySecondary : Color.cmTextPrimary)
                .lineLimit(1)

            Text(artist)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var artworkView: some View {
        if let artwork = model.artwork {
            ArtworkImage(artwork, width: 44, height: 44)
        }
        else if let url = model.artworkURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty, .failure:
                    artworkPlaceholderView
                @unknown default:
                    artworkPlaceholderView
                }
            }
        }
        else {
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

    // @0ne1ce: now it's only for onboarding purpose, but it could be used for analytics or other cool things
    private func handleReveal() {
        switch interactionMode {
        case .plain:
            return
        case let .swipeReveal(onReveal):
            onReveal()
        }
    }
    
    private var revealBackgroundView: some View {
        Image(systemName: "plus")
            .font(.system(size: Layout.MemoryButton.iconSize, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: Layout.MemoryButton.size, height: Layout.MemoryButton.size)
            .background(Color.cmPrimarySecondary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.MemoryButton.cornerRadius))
            .padding(.trailing, Spacing.sm)
            .opacity(isRevealed ? 1 : 0)
            .animation(
                .easeInOut(duration: Layout.MemoryButton.appearAnimationDuration),
                value: isRevealed
            )
    }
}

// MARK: - Private types

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
            static let minimumDistance: CGFloat = 12
            static let revealWidth: CGFloat = 60
            static let velocity: CGFloat = 0.3
            static let bounce: CGFloat = 0.75
            static let rubberBand: CGFloat = 0.3
        }

        static let height: CGFloat = 64
        static let cornerRadius: CGFloat = 12
    }
}
