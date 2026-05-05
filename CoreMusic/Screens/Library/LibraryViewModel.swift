import Combine
import MusicKit
import OSLog
import SwiftUI

@MainActor
protocol LibraryViewModel: ObservableObject {
    // MARK: - Properties

    var title: String { get }
    var state: LibraryState { get }
    var searchInput: String { get set }
    var displayedSections: [LibrarySection] { get }

    // MARK: - Methods

    func onAppear() async
    func onSceneDidBecomeActive() async
    func retry() async
    func openSettings()
    func onTrackTap(_ track: LibraryTrack, queueTracks: [LibraryTrack]) async
    func onTrackAddTap(_ track: LibraryTrack)
    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState
}

@MainActor
final class LibraryViewModelImpl: LibraryViewModel {
    // MARK: - Properties

    let title = "Медиатека"

    @Published private(set) var state: LibraryState = .idle
    @Published var searchInput: String = ""

    var displayedSections: [LibrarySection] {
        guard case let .loaded(sections) = state else {
            return []
        }
        let input = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            return sections
        }
        let filtered = loadedTracks.filter { track in
            track.title.localizedStandardContains(input) ||
            track.artistName.localizedStandardContains(input)
        }
        return LibrarySectionBuilder.group(filtered)
    }

    // MARK: - Initializer

    init(router: LibraryRouter, musicService: any MusicService, playerService: PlayerService) {
        self.router = router
        self.musicService = musicService
        self.playerService = playerService
    }

    // MARK: - Public methods

    func onAppear() async {
        guard shouldLoadOnAppear else {
            return
        }

        await loadLibrary(presentation: .replaceWithLoading)
    }

    func retry() async {
        guard !isLoadInProgress else {
            return
        }

        await loadLibrary(presentation: .replaceWithLoading)
    }

    func onSceneDidBecomeActive() async {
        guard shouldReloadOnForeground else {
            return
        }

        await loadLibrary(presentation: .keepCurrentContent)
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func onTrackTap(_ track: LibraryTrack, queueTracks: [LibraryTrack]) async {
        await playerService.play(track: track, queue: queueTracks)
    }

    func onTrackAddTap(_ track: LibraryTrack) {
        router.goToCreateMemory(songID: track.id)
    }

    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState {
        playerService.playbackState(for: trackID)
    }

    // MARK: - Private properties

    private let router: LibraryRouter
    private let musicService: any MusicService
    private let playerService: PlayerService
    private let log = Logger(subsystem: "com.coremusic.app", category: "LibraryViewModel")
    private var fullSectionsTask: Task<Void, Never>?
    private var isLoadInProgress = false
    private var loadRevision = 0
    private var loadedTracks: [LibraryTrack] = []

    // MARK: - Private methods

    private func loadLibrary(presentation: LoadPresentation) async {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        defer {
            isLoadInProgress = false
        }

        guard await requestAuthorization(presentation: presentation) else {
            return
        }

        if presentation == .replaceWithLoading {
            state = .loading
        }

        do {
            let tracks = try await musicService.fetchLibrarySongs()
            guard !handleEmptyTracksIfNeeded(tracks) else {
                return
            }

            let revision = startNewLoadRevision()
            let shouldShowInitialSections = shouldShowInitialSections(
                for: tracks,
                presentation: presentation
            )

            if shouldShowInitialSections {
                let initialTracks = Array(tracks.prefix(Constants.initialTrackCount))
                applyLoadedState(tracks: initialTracks, sections: LibrarySectionBuilder.group(initialTracks))
            }

            scheduleLoadedStateUpdate(
                tracks: tracks,
                revision: revision,
                shouldShowInitialSections: shouldShowInitialSections
            )
        }
        catch {
            handleLoadError(error)
        }
    }

    private func requestAuthorization(presentation: LoadPresentation) async -> Bool {
        if presentation == .replaceWithLoading {
            state = .requestingAuthorization
        }

        let status = await musicService.requestAuthorizationIfNeeded()

        guard status == .authorized else {
            log.info("Authorization not granted: \(String(describing: status), privacy: .public)")
            state = .denied
            return false
        }

        return true
    }

    private func handleEmptyTracksIfNeeded(_ tracks: [LibraryTrack]) -> Bool {
        guard tracks.isEmpty else {
            return false
        }

        cancelFullSectionsTask()
        state = .empty
        return true
    }

    private func startNewLoadRevision() -> Int {
        loadRevision += 1
        return loadRevision
    }

    private func applyLoadedState(tracks: [LibraryTrack], sections: [LibrarySection]) {
        loadedTracks = tracks
        state = .loaded(sections)
    }

    private func scheduleLoadedStateUpdate(
        tracks: [LibraryTrack],
        revision: Int,
        shouldShowInitialSections: Bool
    ) {
        if tracks.count <= Constants.initialTrackCount {
            applyLoadedState(tracks: tracks, sections: LibrarySectionBuilder.group(tracks))
            return
        }

        cancelFullSectionsTask()
        fullSectionsTask = Task { [tracks] in
            let fullSections = await Task.detached(priority: .utility) {
                LibrarySectionBuilder.group(tracks)
            }.value

            if Task.isCancelled || revision != self.loadRevision {
                return
            }

            self.applyLoadedState(tracks: tracks, sections: fullSections)
        }
    }

    private func shouldShowInitialSections(
        for tracks: [LibraryTrack],
        presentation: LoadPresentation
    ) -> Bool {
        if presentation == .replaceWithLoading {
            return true
        }

        return currentLoadedTrackCount != tracks.count
    }

    private func handleLoadError(_ error: Error) {
        cancelFullSectionsTask()
        log.error("Failed to load library: \(error.localizedDescription, privacy: .public)")
        state = .error("Не удалось загрузить медиатеку. Попробуйте ещё раз.")
    }

    private func cancelFullSectionsTask() {
        fullSectionsTask?.cancel()
        fullSectionsTask = nil
    }

    private var shouldLoadOnAppear: Bool {
        guard !isLoadInProgress else {
            return false
        }

        if case .loaded = state {
            return MusicAuthorization.currentStatus != .authorized
        }

        switch state {
        case .idle, .denied, .empty, .error:
            return true
        case .requestingAuthorization, .loading:
            return false
        case .loaded:
            return false
        }
    }

    private var shouldReloadOnForeground: Bool {
        guard !isLoadInProgress else {
            return false
        }

        switch state {
        case .idle:
            return false
        case .requestingAuthorization, .loading:
            return false
        case .denied, .empty, .error, .loaded:
            return true
        }
    }

    private var currentLoadedTrackCount: Int? {
        guard case let .loaded(sections) = state else {
            return nil
        }

        return sections.reduce(0) { partialResult, section in
            partialResult + section.tracks.count
        }
    }
}

private enum Constants {
    static let initialTrackCount = 40
}

private enum LoadPresentation {
    case replaceWithLoading
    case keepCurrentContent
}
