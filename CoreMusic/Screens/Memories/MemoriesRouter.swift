import Foundation

@MainActor
protocol MemoriesRouter: AnyObject {
    //TODO: navigation methods
}

@MainActor
final class MemoriesRouterImpl: MemoriesRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
