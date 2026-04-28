import SwiftUI

@MainActor
struct MemoriesFactory {
    // MARK: - Properties

    let externalDeps: MemoriesExternalDeps

    // MARK: - Methods

    func makeMemoriesScreen() -> some View {
        let router = MemoriesRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = MemoriesViewModelImpl(
            router: router,
            memoryRepository: externalDeps.memoryRepository
        )

        return MemoriesView(viewModel: viewModel)
    }
}
