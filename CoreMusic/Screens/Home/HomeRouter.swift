import Foundation

@MainActor
protocol HomeRouter: AnyObject {
    func goToTab(_ tab: AppRouter.Tab)
    func openCarousel(startMemoryID: UUID, memoryIDs: [UUID])
    func openCreateMemory(songID: String)
    func openProfile(totalMemories: Int, favoriteMemories: Int, totalTracks: Int)
}

@MainActor
final class HomeRouterImpl: HomeRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Methods

    func goToTab(_ tab: AppRouter.Tab) {
        appRouter.select(tab)
    }

    func openCarousel(startMemoryID: UUID, memoryIDs: [UUID]) {
        appRouter.presentCover(.memoryCarousel(startMemoryID: startMemoryID, memoryIDs: memoryIDs))
    }

    func openCreateMemory(songID: String) {
        appRouter.presentCover(.createMemory(songID: songID))
    }

    func openProfile(totalMemories: Int, favoriteMemories: Int, totalTracks: Int) {
        appRouter.presentSheet(.profile(
            totalMemories: totalMemories,
            favoriteMemories: favoriteMemories,
            totalTracks: totalTracks
        ))
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
