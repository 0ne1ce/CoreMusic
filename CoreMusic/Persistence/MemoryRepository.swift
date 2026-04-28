import Foundation

@MainActor
protocol MemoryRepository: AnyObject {
    func fetchMemories() throws -> [Memory]
    func saveMemory(_ draft: MemoryDraft) throws
    func deleteMemory(_ memory: Memory) throws
}

struct MemoryDraft {
    let songID: String
    let songTitle: String
    let artistName: String
    let trackArtworkURLString: String?
    let memoryTitle: String
    let note: String
    let date: Date
    let locationName: String?
    let photoData: Data?
    let tags: [String]
    let isFavorite: Bool
}
