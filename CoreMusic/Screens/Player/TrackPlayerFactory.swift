import SwiftUI

@MainActor
struct TrackPlayerFactory {
    // MARK: - Properties

    let externalDeps: TrackPlayerExternalDeps

    // MARK: - Public methods

    func makeTrackPlayerScreen() -> some View {
        let router = TrackPlayerRouterImpl(appRouter: externalDeps.appRouter)
        let viewModel = TrackPlayerViewModelImpl(router: router, playerService: externalDeps.playerService)

        return TrackPlayerView(viewModel: viewModel)
    }
}
