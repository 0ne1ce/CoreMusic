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
                .fill(cardBackgroundColor)
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
                .foregroundStyle(titleColor)
                .lineLimit(1)

            Text(artist)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var artworkView: some View {
        TrackArtworkView(track: artworkTrack, size: Layout.Card.Artwork.size)
            .overlay(alignment: .center) {
                artworkPlaybackOverlay
            }
    }

    private var artworkTrack: LibraryTrack {
        LibraryTrack(
            id: model.id,
            title: model.title,
            artistName: model.artist,
            artwork: model.artwork,
            artworkURL: model.artworkURL,
            libraryAddedDate: nil,
            durationSeconds: nil
        )
    }

    @ViewBuilder
    private var artworkPlaybackOverlay: some View {
        switch model.playbackState {
        case .idle:
            EmptyView()
        case .playing, .paused:
            RoundedRectangle(cornerRadius: Layout.Card.Artwork.cornerRadius)
                .fill(Color.black.opacity(Layout.Card.Artwork.overlayOpacity))
                .overlay {
                    Image(systemName: overlayImageName)
                        .font(.system(size: Layout.Card.Artwork.overlayIconSize, weight: .bold))
                        .foregroundStyle(.white)
                }
        }
    }

    private var overlayImageName: String {
        switch model.playbackState {
        case .idle, .paused:
            return "play.fill"
        case .playing:
            return "pause.fill"
        }
    }

    private var cardBackgroundColor: Color {
        switch model.playbackState {
        case .idle:
            return .cmBackgroundLight
        case .playing:
            return .cmPrimarySecondary.opacity(0.12)
        case .paused:
            return .cmBackgroundLight
        }
    }

    private var titleColor: Color {
        switch model.playbackState {
        case .playing:
            return .cmPrimarySecondary
        case .idle, .paused:
            return .cmTextPrimary
        }
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
            static let overlayIconSize: CGFloat = 18
            static let overlayOpacity: CGFloat = 0.5
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
