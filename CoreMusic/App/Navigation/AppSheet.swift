import Foundation

enum AppSheet: Identifiable, Hashable {
    case player(songID: String)
    case profile(totalMemories: Int, favoriteMemories: Int, totalTracks: Int)

    var id: Self { self }
}
