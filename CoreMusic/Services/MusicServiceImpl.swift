import Combine
import Foundation
import MusicKit
import OSLog

@MainActor
final class MusicServiceImpl: MusicService {
    // MARK: - Properties

    @Published private(set) var authorizationStatus: MusicAuthorization.Status

    // MARK: - Initializer

    init() {
        self.authorizationStatus = MusicAuthorization.currentStatus
    }

    // MARK: - Public methods

    func requestAuthorizationIfNeeded() async -> MusicAuthorization.Status {
        let current = MusicAuthorization.currentStatus
        if current == .authorized {
            authorizationStatus = current
            return current
        }

        let status = await MusicAuthorization.request()
        authorizationStatus = status
        log.info("Apple Music authorization resolved: \(String(describing: status), privacy: .public)")
        return status
    }

    func fetchLibrarySongs() async throws -> [LibraryTrack] {
        var request = MusicLibraryRequest<Song>()
        request.sort(by: \.libraryAddedDate, ascending: false)
        let response = try await request.response()
        let songs = Array(response.items)
        let tracks = await Task.detached(priority: .userInitiated) {
            songs.map { $0.toLibraryTrack() }
        }.value
        let tracksWithArtwork = tracks.filter { $0.artwork != nil || $0.artworkURL != nil }.count
        log.info("Fetched \(tracks.count) songs from library")
        log.info("Tracks with artwork available: \(tracksWithArtwork)")
        return tracks
    }

    // MARK: - Private properties

    private let log = Logger(subsystem: "com.coremusic.app", category: "MusicService")
}

// MARK: - Mapping

fileprivate extension Song {
    func toLibraryTrack() -> LibraryTrack {
        LibraryTrack(
            id: self.id.rawValue,
            title: self.title,
            artistName: self.artistName,
            artwork: self.artwork,
            artworkURL: self.artwork?.url(width: 300, height: 300),
            libraryAddedDate: self.libraryAddedDate,
            durationSeconds: self.duration
        )
    }
}
