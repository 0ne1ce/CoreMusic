import Foundation

@MainActor
protocol TrackPlayerRouter: AnyObject {
    // MARK: - Public methods

    func close()
    func goToCreateMemory(songID: String)
}

@MainActor
final class TrackPlayerRouterImpl: TrackPlayerRouter {
    // MARK: - Initializers

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Public methods

    func close() {
        appRouter.dismissCover()
    }

    func goToCreateMemory(songID: String) {
        appRouter.dismissSheet()
        appRouter.presentCover(.createMemory(songID: songID))
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
