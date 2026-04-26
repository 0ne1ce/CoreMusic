import SwiftUI

@MainActor
struct LibraryFactory {
    // MARK: - Properties

    let externalDeps: LibraryExternalDeps

    // MARK: - Methods

    func makeLibraryScreen() -> some View {
        let router = LibraryRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = LibraryViewModelImpl(
            router: router,
            musicService: externalDeps.musicService
        )

        return LibraryView(viewModel: viewModel)
    }
}
