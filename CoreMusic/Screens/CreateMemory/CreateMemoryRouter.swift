import Foundation

@MainActor
protocol CreateMemoryRouter: AnyObject {
    func close()
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

    // MARK: - Private properties

    private let appRouter: AppRouter
}
