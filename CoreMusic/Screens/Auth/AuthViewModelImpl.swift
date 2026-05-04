import AuthenticationServices
import Combine
import SwiftUI

@MainActor
final class AuthViewModelImpl: AuthViewModel {
    // MARK: - Properties

    @Published private(set) var isAuthenticating = false
    @Published private(set) var errorMessage: String?

    // MARK: - Initializer

    init(authService: any AuthService) {
        self.authService = authService
    }

    // MARK: - Methods

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = authService.makeNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256()
    }

    func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case let .success(authorization):
            await signIn(with: authorization)
        case let .failure(error):
            handleAppleFailure(error)
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    // TODO: Removw signInStub() after adding Sign in with Apple capability
    func signInStub() async {
        isAuthenticating = true
        defer {
            isAuthenticating = false
        }

        try? await Task.sleep(for: .milliseconds(400))
        authService.applyStubUser()
    }

    // MARK: - Private properties

    private let authService: any AuthService
    private var currentNonce: String?

    // MARK: - Private methods

    private func signIn(with authorization: ASAuthorization) async {
        guard let rawNonce = currentNonce else {
            errorMessage = "Не удалось проверить запрос. Попробуйте ещё раз."
            return
        }

        isAuthenticating = true
        defer {
            isAuthenticating = false
        }

        do {
            try await authService.handleAppleAuthorization(authorization, rawNonce: rawNonce)
            currentNonce = nil
        }
        catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
        }
    }

    private func handleAppleFailure(_ error: Error) {
        if let asError = error as? ASAuthorizationError, asError.code == .canceled {
            return
        }

        errorMessage = error.localizedDescription
    }
}
