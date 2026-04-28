import Foundation

@MainActor
struct LibraryExternalDeps {
    let appRouter: AppRouter
    let musicService: any MusicService
    let playerService: PlayerService
}
