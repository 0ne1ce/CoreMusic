import Foundation
import MusicKit

struct TrackCardModel: Equatable, Identifiable {
    enum PlaybackState: Equatable {
        case idle
        case playing
        case paused
    }

    let id: String
    let title: String
    let artist: String
    let artwork: Artwork?
    let artworkURL: URL?
    var playbackState: PlaybackState = .idle

    init(track: LibraryTrack, playbackState: PlaybackState = .idle) {
        self.id = track.id
        self.title = track.title
        self.artist = track.artistName
        self.artwork = track.artwork
        self.artworkURL = track.artworkURL
        self.playbackState = playbackState
    }
}

extension TrackCardModel {
    static func == (lhs: TrackCardModel, rhs: TrackCardModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.artworkURL == rhs.artworkURL &&
        lhs.playbackState == rhs.playbackState
    }
}
