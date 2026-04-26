import Combine
import Foundation
import MusicKit

@MainActor
final class MockMusicService: MusicService {
    // MARK: - Properties

    @Published private(set) var authorizationStatus: MusicAuthorization.Status

    // MARK: - Initializer

    init(
        initialStatus: MusicAuthorization.Status = .authorized,
        tracks: [LibraryTrack] = MockMusicService.previewTracks
    ) {
        self.authorizationStatus = initialStatus
        self.tracks = tracks
    }

    // MARK: - Public methods

    func requestAuthorizationIfNeeded() async -> MusicAuthorization.Status {
        authorizationStatus = .authorized
        return authorizationStatus
    }

    func fetchLibrarySongs() async throws -> [LibraryTrack] {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return tracks
    }

    // MARK: - Private properties

    private let tracks: [LibraryTrack]
}

// MARK: - Preview data

extension MockMusicService {
    nonisolated static var previewTracks: [LibraryTrack] {
        let calendar = Calendar(identifier: .gregorian)
        let april2026 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))
        let april2026Earlier = calendar.date(from: DateComponents(year: 2026, month: 4, day: 5))
        let march2026 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 22))
        let march2026Earlier = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))
        let january2026 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 14))
        let january2026Earlier = calendar.date(from: DateComponents(year: 2026, month: 1, day: 3))

        return [
            LibraryTrack(
                id: "preview-1",
                title: "Bohemian Rhapsody",
                artistName: "Queen",
                artworkURL: nil,
                libraryAddedDate: april2026,
                durationSeconds: 354
            ),
            LibraryTrack(
                id: "preview-2",
                title: "Imagine",
                artistName: "John Lennon",
                artworkURL: nil,
                libraryAddedDate: april2026Earlier,
                durationSeconds: 183
            ),
            LibraryTrack(
                id: "preview-3",
                title: "Hotel California",
                artistName: "Eagles",
                artworkURL: nil,
                libraryAddedDate: march2026,
                durationSeconds: 391
            ),
            LibraryTrack(
                id: "preview-4",
                title: "Stairway to Heaven",
                artistName: "Led Zeppelin",
                artworkURL: nil,
                libraryAddedDate: march2026Earlier,
                durationSeconds: 482
            ),
            LibraryTrack(
                id: "preview-5",
                title: "Wonderwall",
                artistName: "Oasis",
                artworkURL: nil,
                libraryAddedDate: january2026,
                durationSeconds: 258
            ),
            LibraryTrack(
                id: "preview-6",
                title: "Smells Like Teen Spirit",
                artistName: "Nirvana",
                artworkURL: nil,
                libraryAddedDate: january2026Earlier,
                durationSeconds: 301
            ),
            LibraryTrack(
                id: "preview-7",
                title: "Старый трек без даты",
                artistName: "Unknown Artist",
                artworkURL: nil,
                libraryAddedDate: nil,
                durationSeconds: 200
            )
        ]
    }
}
