import SwiftUI

@MainActor
struct AuthFactory {
    // MARK: - Properties

    let externalDeps: AuthExternalDeps

    // MARK: - Methods

    func makeAuthScreen(onSkip: (() -> Void)? = nil) -> some View {
        let viewModel = AuthViewModelImpl(authService: externalDeps.authService)
        return AuthView(viewModel: viewModel, onSkip: onSkip)
    }
}
