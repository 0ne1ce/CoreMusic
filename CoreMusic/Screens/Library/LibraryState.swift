import Foundation

enum LibraryState {
    case idle
    case requestingAuthorization
    case denied
    case loading
    case loaded([LibrarySection])
    case empty
    case error(String)
}
