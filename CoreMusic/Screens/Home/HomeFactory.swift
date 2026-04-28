import SwiftUI

@MainActor
struct HomeFactory {
    // MARK: - Properties

    let externalDeps: HomeExternalDeps

    // MARK: - Methods

    func makeHomeScreen() -> some View {
        let router = HomeRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = HomeViewModelImpl(
            router: router,
            musicService: externalDeps.musicService,
            playerService: externalDeps.playerService,
            memoryRepository: externalDeps.memoryRepository
        )

        return HomeView(viewModel: viewModel)
    }
}
