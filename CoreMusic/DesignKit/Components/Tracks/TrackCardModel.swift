import Foundation
import MusicKit

struct TrackCardModel: Equatable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let artwork: Artwork?
    let artworkURL: URL?
    var isPlaying: Bool = false

    init(track: LibraryTrack, isPlaying: Bool = false) {
        self.id = track.id
        self.title = track.title
        self.artist = track.artistName
        self.artwork = track.artwork
        self.artworkURL = track.artworkURL
        self.isPlaying = isPlaying
    }
}

extension TrackCardModel {
    static func == (lhs: TrackCardModel, rhs: TrackCardModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.artworkURL == rhs.artworkURL &&
        lhs.isPlaying == rhs.isPlaying
    }
}
