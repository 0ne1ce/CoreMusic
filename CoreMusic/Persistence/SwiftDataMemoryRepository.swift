import Foundation
import SwiftData

@MainActor
final class SwiftDataMemoryRepository: MemoryRepository {
    // MARK: - Initializer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.context = ModelContext(modelContainer)
    }

    // MARK: - Public methods

    func fetchMemories() throws -> [Memory] {
        let descriptor = FetchDescriptor<Memory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func saveMemory(_ draft: MemoryDraft) throws {
        let memory = Memory(
            songID: draft.songID,
            songTitle: draft.songTitle,
            artistName: draft.artistName,
            trackArtworkURLString: draft.trackArtworkURLString,
            memoryTitle: draft.memoryTitle,
            note: draft.note,
            date: draft.date,
            locationName: draft.locationName,
            photoData: draft.photoData,
            tags: draft.tags,
            isFavorite: draft.isFavorite
        )

        context.insert(memory)
        try context.save()
    }

    func deleteMemory(_ memory: Memory) throws {
        context.delete(memory)
        try context.save()
    }

    func toggleFavorite(_ memory: Memory) throws {
        memory.isFavorite.toggle()
        try context.save()
    }

    // MARK: - Private properties

    private let modelContainer: ModelContainer
    private let context: ModelContext
}
