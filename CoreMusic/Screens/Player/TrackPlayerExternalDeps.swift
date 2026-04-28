import Foundation

@MainActor
struct TrackPlayerExternalDeps {
    let appRouter: AppRouter
    let playerService: PlayerServiceImpl
}
