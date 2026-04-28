import Foundation

@MainActor
protocol MemoryCarouselRouter: AnyObject {
    func close()
}

@MainActor
final class MemoryCarouselRouterImpl: MemoryCarouselRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Methods

    func close() {
        appRouter.dismissCover()
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
