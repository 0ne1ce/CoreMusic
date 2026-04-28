import Foundation

enum AppCover: Identifiable, Hashable {
    case createMemory(songID: String)
    case editMemory(memoryID: UUID)
    case player(songID: String)
    case memoryCarousel(startMemoryID: UUID)

    var id: Self { self }
}
