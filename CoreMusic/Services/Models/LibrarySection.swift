import Foundation

struct LibrarySection: Identifiable, Hashable {
    let id: String
    let title: String
    let tracks: [LibraryTrack]
}
