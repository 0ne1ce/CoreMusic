import SwiftUI

@MainActor
struct MemoryCarouselFactory {
    // MARK: - Properties

    let externalDeps: MemoryCarouselExternalDeps

    // MARK: - Methods

    func makeMemoryCarouselScreen(startMemoryID: UUID) -> some View {
        let router = MemoryCarouselRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = MemoryCarouselViewModelImpl(
            startMemoryID: startMemoryID,
            router: router,
            memoryRepository: externalDeps.memoryRepository,
            playerService: externalDeps.playerService
        )

        return MemoryCarouselView(viewModel: viewModel)
    }
}
