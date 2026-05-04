import AuthenticationServices
import Foundation

enum AuthState: Equatable {
    case signedOut
    case authenticating
    case signedIn(AuthUser)
    case failed(String)
}

@MainActor
protocol AuthService: AnyObject {
    // MARK: - Properties

    var currentUser: AuthUser? { get }
    var authState: AuthState { get }

    // MARK: - Methods

    func startListening()
    func makeNonce() -> String
    func handleAppleAuthorization(_ authorization: ASAuthorization, rawNonce: String) async throws
    func signOut() async throws
    func deleteAccount(authorizationCode: String?) async throws

    // TODO: Remove applyStubUser() after adding FirebaseAuth + Sign in with Apple capability
    func applyStubUser()
}

enum AuthError: LocalizedError {
    case missingCredential
    case missingIdentityToken
    case identityTokenDecodingFailed
    case signInFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingCredential:
            return "Не удалось получить данные авторизации Apple."
        case .missingIdentityToken:
            return "Apple не вернул identity token. Попробуйте ещё раз."
        case .identityTokenDecodingFailed:
            return "Не удалось обработать ответ Apple. Попробуйте ещё раз."
        case let .signInFailed(message):
            return message
        }
    }
}
