import AuthenticationServices
import SwiftUI

@MainActor
protocol AuthViewModel: ObservableObject {
    // MARK: - Properties

    var isAuthenticating: Bool { get }
    var errorMessage: String? { get }

    // MARK: - Methods

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest)
    func handleAppleResult(_ result: Result<ASAuthorization, Error>) async
    func dismissError()
}
