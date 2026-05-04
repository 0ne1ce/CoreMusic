import SwiftUI

@MainActor
struct AuthFactory {
    // MARK: - Properties

    let externalDeps: AuthExternalDeps

    // MARK: - Methods

    func makeAuthScreen() -> some View {
        let viewModel = AuthViewModelImpl(authService: externalDeps.authService)
        return AuthView(viewModel: viewModel)
    }
}
