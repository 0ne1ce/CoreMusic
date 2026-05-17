import Foundation

@MainActor
struct HomeExternalDeps {
    let appRouter: AppRouter
    let musicService: any MusicService
    let playerService: PlayerService
    let memoryRepository: MemoryRepository
    let notificationService: NotificationService
    let authService: AuthServiceImpl
}
