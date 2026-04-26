import Foundation

enum AppCover: Identifiable, Hashable {
    case createMemory(songID: String)
    case player(songID: String)

    var id: Self { self }
}
