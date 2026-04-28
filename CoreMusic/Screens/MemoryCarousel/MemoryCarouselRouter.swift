import Foundation

@MainActor
protocol MemoryCarouselRouter: AnyObject {
    func close()
    func openEdit(memoryID: UUID)
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

    func openEdit(memoryID: UUID) {
        appRouter.presentCover(.editMemory(memoryID: memoryID))
    }

    // MARK: - Private properties

    private let appRouter: AppRouter
}
