import Combine
import MusicKit
import OSLog
import SwiftUI

@MainActor
protocol LibraryViewModel: ObservableObject {
    // MARK: - Properties

    var title: String { get }
    var state: LibraryState { get }

    // MARK: - Methods

    func onAppear() async
    func retry() async
    func openSettings()
    func onTrackAddTap(_ track: LibraryTrack)
}

@MainActor
final class LibraryViewModelImpl: LibraryViewModel {
    // MARK: - Properties

    let title = "Медиатека"

    @Published private(set) var state: LibraryState = .idle

    // MARK: - Initializer

    init(router: any LibraryRouter, musicService: any MusicService) {
        self.router = router
        self.musicService = musicService
    }

    // MARK: - Public methods

    func onAppear() async {
        if case .loaded = state, MusicAuthorization.currentStatus == .authorized {
            return
        }
        await loadLibrary()
    }

    func retry() async {
        await loadLibrary()
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func onTrackAddTap(_ track: LibraryTrack) {
        router.goToCreateMemory(songID: track.id)
    }

    // MARK: - Private properties

    private let router: any LibraryRouter
    private let musicService: any MusicService
    private let log = Logger(subsystem: "com.coremusic.app", category: "LibraryViewModel")

    // MARK: - Private methods

    private func loadLibrary() async {
        state = .requestingAuthorization
        let status = await musicService.requestAuthorizationIfNeeded()

        guard status == .authorized else {
            log.info("Authorization not granted: \(String(describing: status), privacy: .public)")
            state = .denied
            return
        }

        state = .loading
        do {
            let tracks = try await musicService.fetchLibrarySongs()
            if tracks.isEmpty {
                state = .empty
            }
            else {
                let sections = LibrarySectionBuilder.group(tracks)
                state = .loaded(sections)
            }
        }
        catch {
            log.error("Failed to load library: \(error.localizedDescription, privacy: .public)")
            state = .error("Не удалось загрузить медиатеку. Попробуйте ещё раз.")
        }
    }
}
