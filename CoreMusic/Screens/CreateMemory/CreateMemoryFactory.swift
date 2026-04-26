import SwiftUI

@MainActor
struct CreateMemoryFactory {
    // MARK: - Properties

    let externalDeps: CreateMemoryExternalDeps

    // MARK: - Methods

    func makeCreateMemoryScreen(songID: String) -> some View {
        let router = CreateMemoryRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = CreateMemoryViewModelImpl(
            router: router,
            songID: songID
        )

        return CreateMemoryView(viewModel: viewModel)
    }
}
