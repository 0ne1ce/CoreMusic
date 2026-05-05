import SwiftUI

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
                    TrackArtworkView(track: track, size: Layout.artworkSize)
                        .frame(width: Layout.artworkSize, height: Layout.artworkSize)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.artworkCornerRadius))

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

                    Spacer(minLength: Layout.controlHitArea + Spacing.md)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: handlePlaybackToggleTap) {
                Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: Layout.controlSize, weight: .bold))
                    .foregroundStyle(Color.cmTextPrimary)
            }
            .buttonStyle(.plain)
            .frame(width: Layout.controlHitArea, height: Layout.controlHitArea)
            .contentShape(Rectangle())
            .padding(.trailing, Spacing.sm)
        }
        .padding(.leading, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
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
    static let artworkSize: CGFloat = 40
    static let artworkCornerRadius: CGFloat = 10
    static let controlSize: CGFloat = 18
    static let controlHitArea: CGFloat = 44
    static let cornerRadius: CGFloat = 18
}
