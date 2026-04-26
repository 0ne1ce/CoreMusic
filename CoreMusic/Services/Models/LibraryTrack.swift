import Foundation
import MusicKit

struct LibraryTrack: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let artwork: Artwork?
    let artworkURL: URL?
    let libraryAddedDate: Date?
    let durationSeconds: TimeInterval?
}

extension LibraryTrack {
    static func == (lhs: LibraryTrack, rhs: LibraryTrack) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.artistName == rhs.artistName &&
        lhs.artworkURL == rhs.artworkURL &&
        lhs.libraryAddedDate == rhs.libraryAddedDate &&
        lhs.durationSeconds == rhs.durationSeconds
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(artistName)
        hasher.combine(artworkURL)
        hasher.combine(libraryAddedDate)
        hasher.combine(durationSeconds)
    }
}
