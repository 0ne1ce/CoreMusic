import Foundation

@MainActor
struct HomeExternalDeps {
    let appRouter: AppRouter
    let musicService: any MusicService
    let playerService: PlayerServiceImpl
    let memoryRepository: MemoryRepository
    let notificationService: NotificationService
    let authService: AuthServiceImpl
}
