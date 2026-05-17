import SwiftUI

struct SwipeableMiniPlayerView: View {
    // MARK: - Properties

    @ObservedObject var playerService: PlayerServiceImpl
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        let queue = playerService.currentQueue
        let currentID = playerService.currentTrackID

        ScrollView(.horizontal) {
            LazyHStack(spacing: Layout.SwipeView.cardSpacing) {
                ForEach(queue) { track in
                    MiniPlayerCard(
                        track: track,
                        isPlaying: playerService.isPlaying && track.id == currentID,
                        isCurrent: track.id == currentID,
                        onTap: onTap,
                        onPlaybackToggle: handlePlaybackToggleTap
                    )
                    .containerRelativeFrame(.horizontal)
                    .id(track.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, Layout.SwipeView.sidePeek)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $scrolledID)
        .frame(height: Layout.SwipeView.miniPlayerHeight)
        .onAppear { scrolledID = currentID }
        .onChange(of: scrolledID) { _, newID in
            handleScrollChange(newID: newID)
        }
        .onChange(of: playerService.currentTrackID) { _, newID in
            isSkipping = false
            scrolledID = newID
        }
    }

    // MARK: - Private properties

    @State private var scrolledID: String?
    @State private var isSkipping = false

    // MARK: - Private methods

    private func handleScrollChange(newID: String?) {
        guard let newID,
              newID != playerService.currentTrackID,
              !isSkipping,
              let track = playerService.currentQueue.first(where: { $0.id == newID })
        else { return }

        isSkipping = true
        Task { await playerService.play(track: track, queue: playerService.currentQueue) }
    }

    private func handlePlaybackToggleTap() {
        Task { await playerService.togglePlayback() }
    }
}

private struct MiniPlayerCard: View {
    // MARK: - Properties

    let track: LibraryTrack
    let isPlaying: Bool
    let isCurrent: Bool
    let onTap: () -> Void
    let onPlaybackToggle: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: onTap) {
                HStack(spacing: Spacing.md) {
                    TrackArtworkView(track: track, size: Layout.Card.artworkSize)
                        .frame(width: Layout.Card.artworkSize, height: Layout.Card.artworkSize)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.Card.artworkCornerRadius))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.cmCardTitle)
                            .foregroundStyle(Color.cmTextPrimary)
                            .lineLimit(1)

                        Text(track.artistName)
                            .font(.cmCallout)
                            .foregroundStyle(Color.cmTextSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: Layout.Card.controlHitArea + Spacing.md)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isCurrent {
                Button(action: onPlaybackToggle) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: Layout.Card.controlSize, weight: .bold))
                        .foregroundStyle(Color.cmTextPrimary)
                }
                .buttonStyle(.plain)
                .frame(width: Layout.Card.controlHitArea, height: Layout.Card.controlHitArea)
                .contentShape(Rectangle())
                .padding(.trailing, Spacing.sm)
            }
        }
        .padding(.leading, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Layout.Card.cornerRadius))
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
    }
}

struct MiniPlayerView: View {
    // MARK: - Properties

    let track: LibraryTrack
    @ObservedObject var playerService: PlayerServiceImpl
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: onTap) {
                HStack(spacing: Spacing.md) {
                    TrackArtworkView(track: track, size: Layout.Card.artworkSize)
                        .frame(width: Layout.Card.artworkSize, height: Layout.Card.artworkSize)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.Card.artworkCornerRadius))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.cmCardTitle)
                            .foregroundStyle(Color.cmTextPrimary)
                            .lineLimit(1)

                        Text(track.artistName)
                            .font(.cmCallout)
                            .foregroundStyle(Color.cmTextSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: Layout.Card.controlHitArea + Spacing.md)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: handlePlaybackToggleTap) {
                Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: Layout.Card.controlSize, weight: .bold))
                    .foregroundStyle(Color.cmTextPrimary)
            }
            .buttonStyle(.plain)
            .frame(width: Layout.Card.controlHitArea, height: Layout.Card.controlHitArea)
            .contentShape(Rectangle())
            .padding(.trailing, Spacing.sm)
        }
        .padding(.leading, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Layout.Card.cornerRadius))
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
    }

    // MARK: - Private methods

    private func handlePlaybackToggleTap() {
        Task {
            await playerService.togglePlayback()
        }
    }
}


private enum Layout {
    enum Card {
        static let artworkSize: CGFloat = 40
        static let artworkCornerRadius: CGFloat = 10
        static let controlSize: CGFloat = 18
        static let controlHitArea: CGFloat = 44
        static let cornerRadius: CGFloat = 18
    }
    enum SwipeView {
        static let sidePeek: CGFloat = 24
        static let cardSpacing: CGFloat = 8
        static let miniPlayerHeight: CGFloat = 56
    }
}
