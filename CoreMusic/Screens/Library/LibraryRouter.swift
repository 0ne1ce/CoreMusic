import Foundation

@MainActor
protocol LibraryRouter: AnyObject {
    func goToCreateMemory(songID: String)
}

@MainActor
final class LibraryRouterImpl: LibraryRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Methods

    func goToCreateMemory(songID: String) {
        appRouter.presentCover(.createMemory(songID: songID))
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
