import Foundation

struct AuthUser: Equatable, Identifiable {
    let id: String
    let appleUserID: String?
    let email: String?
    let displayName: String?
}
