import Combine
import MusicKit

@MainActor
protocol MusicService: AnyObject, ObservableObject {

    var authorizationStatus: MusicAuthorization.Status { get }

    func requestAuthorizationIfNeeded() async -> MusicAuthorization.Status
    func fetchLibrarySongs() async throws -> [LibraryTrack]
}
