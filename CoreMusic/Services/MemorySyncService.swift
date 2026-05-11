import Foundation

extension Notification.Name {
    static let memorySyncDidComplete = Notification.Name("memorySyncDidComplete")
}

@MainActor
protocol MemorySyncService: AnyObject {
    func performFullSync() async
    func pushMemory(_ memory: Memory) async
    func pushMemoryDeletion(memoryID: UUID) async
}
