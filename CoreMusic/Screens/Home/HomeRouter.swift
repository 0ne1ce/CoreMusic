import Foundation

@MainActor
protocol HomeRouter: AnyObject { }

@MainActor
final class HomeRouterImpl: HomeRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
