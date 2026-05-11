import Foundation

@MainActor
final class MockMemorySyncService: MemorySyncService {
    func performFullSync() async {}
    func pushMemory(_ memory: Memory) async {}
    func pushMemoryDeletion(memoryID: UUID) async {}
}
