import Foundation

struct TrackCardModel: Equatable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    var isPlaying: Bool = false
}
