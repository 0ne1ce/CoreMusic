import Foundation

@MainActor
struct MemoriesExternalDeps {
    let appRouter: AppRouter
    let memoryRepository: MemoryRepository
}
