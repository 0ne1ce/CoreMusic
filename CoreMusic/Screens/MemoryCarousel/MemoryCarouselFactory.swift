import SwiftUI

@MainActor
struct MemoryCarouselFactory {
    // MARK: - Properties

    let externalDeps: MemoryCarouselExternalDeps

    // MARK: - Methods

    func makeMemoryCarouselScreen(startMemoryID: UUID, memoryIDs: [UUID]? = nil) -> some View {
        let router = MemoryCarouselRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = MemoryCarouselViewModelImpl(
            startMemoryID: startMemoryID,
            memoryIDs: memoryIDs,
            router: router,
            memoryRepository: externalDeps.memoryRepository,
            playerService: externalDeps.playerService
        )

        return MemoryCarouselView(viewModel: viewModel)
    }
}
