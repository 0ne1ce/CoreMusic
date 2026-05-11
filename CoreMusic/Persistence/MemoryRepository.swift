import Foundation

@MainActor
protocol MemoryRepository: AnyObject {
    func fetchMemories() throws -> [Memory]
    func fetchMemory(by id: UUID) throws -> Memory?
    @discardableResult
    func saveMemory(_ draft: MemoryDraft) throws -> Memory
    func updateMemory(_ memory: Memory, with draft: MemoryDraft) throws
    func deleteMemory(_ memory: Memory) throws
    func toggleFavorite(_ memory: Memory) throws
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
    let id: UUID?

    init(
        songID: String,
        songTitle: String,
        artistName: String,
        trackArtworkURLString: String?,
        memoryTitle: String,
        note: String,
        date: Date,
        locationName: String?,
        photoData: Data?,
        tags: [String],
        isFavorite: Bool,
        id: UUID? = nil
    ) {
        self.songID = songID
        self.songTitle = songTitle
        self.artistName = artistName
        self.trackArtworkURLString = trackArtworkURLString
        self.memoryTitle = memoryTitle
        self.note = note
        self.date = date
        self.locationName = locationName
        self.photoData = photoData
        self.tags = tags
        self.isFavorite = isFavorite
        self.id = id
    }
}
