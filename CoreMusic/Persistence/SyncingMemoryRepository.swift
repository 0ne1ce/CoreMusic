import Foundation

@MainActor
final class SyncingMemoryRepository: MemoryRepository {

    // MARK: - Initializer

    init(local: MemoryRepository, syncService: MemorySyncService) {
        self.local = local
        self.syncService = syncService
    }

    // MARK: - Public methods

    func fetchMemories() throws -> [Memory] {
        try local.fetchMemories()
    }

    func fetchMemory(by id: UUID) throws -> Memory? {
        try local.fetchMemory(by: id)
    }

    @discardableResult
    func saveMemory(_ draft: MemoryDraft) throws -> Memory {
        let saved = try local.saveMemory(draft)
        Task { await syncService.pushMemory(saved) }
        return saved
    }

    func updateMemory(_ memory: Memory, with draft: MemoryDraft) throws {
        try local.updateMemory(memory, with: draft)
        Task { await syncService.pushMemory(memory) }
    }

    func deleteMemory(_ memory: Memory) throws {
        let memoryID = memory.id
        try local.deleteMemory(memory)
        Task { await syncService.pushMemoryDeletion(memoryID: memoryID) }
    }

    func toggleFavorite(_ memory: Memory) throws {
        try local.toggleFavorite(memory)
        Task { await syncService.pushMemory(memory) }
    }

    // MARK: - Private properties

    private let local: MemoryRepository
    private let syncService: MemorySyncService
}
