import Foundation

struct LibraryTrack: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let artworkURL: URL?
    let libraryAddedDate: Date?
    let durationSeconds: TimeInterval?
}
