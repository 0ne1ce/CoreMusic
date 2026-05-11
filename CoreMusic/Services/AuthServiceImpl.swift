import AuthenticationServices
import Combine
import FirebaseAuth
import Foundation
import Security

@MainActor
final class AuthServiceImpl: ObservableObject, AuthService {
    // MARK: - Properties

    @Published private(set) var currentUser: AuthUser?
    @Published private(set) var authState: AuthState = .signedOut

    // MARK: - Methods

    func startListening() {
        guard authStateHandle == nil else {
            return
        }

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                self?.applyFirebaseUser(firebaseUser)
            }
        }
    }

    func makeNonce() -> String {
        var randomBytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        guard status == errSecSuccess else {
            return UUID().uuidString
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte -> Character in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    func handleAppleAuthorization(_ authorization: ASAuthorization, rawNonce: String) async throws {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.missingCredential
        }

        guard let identityTokenData = credential.identityToken else {
            throw AuthError.missingIdentityToken
        }

        guard let idTokenString = String(data: identityTokenData, encoding: .utf8) else {
            throw AuthError.identityTokenDecodingFailed
        }

        authState = .authenticating

        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: credential.fullName
        )

        do {
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            applyFirebaseUser(result.user, appleUserID: credential.user, fallbackName: displayName(from: credential.fullName))
        }
        catch {
            authState = .failed(error.localizedDescription)
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }

    func signOut() async throws {
        try Auth.auth().signOut()
        currentUser = nil
        authState = .signedOut
    }

    func deleteAccount(authorizationCode: String?) async throws {
        if let authorizationCode {
            try await Auth.auth().revokeToken(withAuthorizationCode: authorizationCode)
        }
        try await Auth.auth().currentUser?.delete()
        currentUser = nil
        authState = .signedOut
    }

    // MARK: - Private properties

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Private methods

    private func applyFirebaseUser(
        _ firebaseUser: User?,
        appleUserID: String? = nil,
        fallbackName: String? = nil
    ) {
        guard let firebaseUser else {
            currentUser = nil
            authState = .signedOut
            return
        }

        let user = AuthUser(
            id: firebaseUser.uid,
            appleUserID: appleUserID,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName ?? fallbackName
        )
        currentUser = user
        authState = .signedIn(user)
    }

    private func displayName(from components: PersonNameComponents?) -> String? {
        guard let components else {
            return nil
        }

        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        let formatted = formatter.string(from: components)
        return formatted.isEmpty ? nil : formatted
    }
}

// MARK: - Preview helper

#if DEBUG
extension AuthServiceImpl {
    static func makePreview(currentUser: AuthUser?) -> AuthServiceImpl {
        let service = AuthServiceImpl()
        service.currentUser = currentUser
        service.authState = currentUser.map { .signedIn($0) } ?? .signedOut
        return service
    }
}
#endif
