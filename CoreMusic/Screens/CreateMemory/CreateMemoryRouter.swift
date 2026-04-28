import Foundation

@MainActor
protocol CreateMemoryRouter: AnyObject {
    func close()
    func dismissAll()
}

@MainActor
final class CreateMemoryRouterImpl: CreateMemoryRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Methods

    func close() {
        appRouter.closeCurrent()
    }

    func dismissAll() {
        appRouter.dismissCover()
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
