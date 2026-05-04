import Foundation

@MainActor
struct CreateMemoryExternalDeps {
    let appRouter: AppRouter
    let musicService: any MusicService
    let playerService: PlayerService
    let memoryRepository: MemoryRepository
    let makeLocationSearchService: @MainActor () -> LocationSearchService
}
