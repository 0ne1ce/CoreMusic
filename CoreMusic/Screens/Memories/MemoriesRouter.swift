import Foundation

@MainActor
protocol MemoriesRouter: AnyObject {
    func openCarousel(startMemoryID: UUID)
}

@MainActor
final class MemoriesRouterImpl: MemoriesRouter {
    // MARK: - Initializer

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    // MARK: - Methods

    func openCarousel(startMemoryID: UUID) {
        appRouter.presentCover(.memoryCarousel(startMemoryID: startMemoryID, memoryIDs: nil))
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
