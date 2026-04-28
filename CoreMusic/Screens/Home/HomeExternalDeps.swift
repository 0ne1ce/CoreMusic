import Foundation

@MainActor
struct HomeExternalDeps {
    let appRouter: AppRouter
    let musicService: any MusicService
    let playerService: PlayerServiceImpl
    let memoryRepository: MemoryRepository
}
