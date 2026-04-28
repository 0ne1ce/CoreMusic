import Foundation

@MainActor
struct MemoryCarouselExternalDeps {
    let appRouter: AppRouter
    let memoryRepository: MemoryRepository
    let playerService: PlayerServiceImpl
}
