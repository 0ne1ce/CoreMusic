import MusicKit
import SwiftUI

struct TrackArtworkView: View {
    // MARK: - Properties

    let track: LibraryTrack
    let size: CGFloat

    // MARK: - Body

    var body: some View {
        Group {
            if let artwork = track.artwork {
                ArtworkImage(artwork, width: size, height: size)
            }
            else if let url = track.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty, .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            }
            else {
                placeholderView
            }
        }
    }

    // MARK: - Private methods

    private var placeholderView: some View {
        LinearGradient(
            colors: [Color.cmPrimaryLight, Color.cmPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "music.note")
                .font(.system(size: size * 0.3, weight: .semibold))
                .foregroundStyle(.white)
        )
    }
}
