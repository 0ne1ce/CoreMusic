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
    func onSceneDidBecomeActive() async
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

    func onTrackAddTap(_ track: LibraryTrack) {
        router.goToCreateMemory(songID: track.id)
    }

    // MARK: - Private properties

    private let router: any LibraryRouter
    private let musicService: any MusicService
    private let log = Logger(subsystem: "com.coremusic.app", category: "LibraryViewModel")
    private var fullSectionsTask: Task<Void, Never>?
    private var isLoadInProgress = false
    private var loadRevision = 0

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
                let initialSections = buildInitialSections(from: tracks)
                state = .loaded(initialSections)
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

    private func buildInitialSections(from tracks: [LibraryTrack]) -> [LibrarySection] {
        let initialTracks = Array(tracks.prefix(Constants.initialTrackCount))
        return LibrarySectionBuilder.group(initialTracks)
    }

    private func scheduleLoadedStateUpdate(
        tracks: [LibraryTrack],
        revision: Int,
        shouldShowInitialSections: Bool
    ) {
        if tracks.count <= Constants.initialTrackCount {
            let sections = LibrarySectionBuilder.group(tracks)
            state = .loaded(sections)
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

            self.state = .loaded(fullSections)
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
