import Combine
import SwiftUI

@MainActor
protocol TrackPlayerViewModel: ObservableObject {
    // MARK: - Properties

    var currentTrack: LibraryTrack? { get }
    var isPlaying: Bool { get }
    var playbackTime: TimeInterval { get }
    var duration: TimeInterval { get }

    // MARK: - Methods

    func onPlaybackToggleTap() async
    func onSkipBackwardTap() async
    func onSkipForwardTap() async
    func onSeek(to time: TimeInterval)
    func onCloseTap()
    func onCreateMemoryTap()
}

@MainActor
final class TrackPlayerViewModelImpl: TrackPlayerViewModel {
    // MARK: - Properties

    @Published private(set) var currentTrack: LibraryTrack?
    @Published private(set) var isPlaying = false
    @Published private(set) var playbackTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    // MARK: - Initializer

    init(router: TrackPlayerRouter, playerService: PlayerServiceImpl) {
        self.router = router
        self.playerService = playerService
        self.currentTrack = playerService.currentTrack
        self.isPlaying = playerService.isPlaying
        self.playbackTime = playerService.playbackTime
        self.duration = playerService.duration

        playerService.$currentTrack
            .receive(on: RunLoop.main)
            .assign(to: &$currentTrack)

        playerService.$isPlaying
            .receive(on: RunLoop.main)
            .assign(to: &$isPlaying)

        playerService.$playbackTime
            .receive(on: RunLoop.main)
            .assign(to: &$playbackTime)

        playerService.$duration
            .receive(on: RunLoop.main)
            .assign(to: &$duration)
    }

    // MARK: - Methods

    func onPlaybackToggleTap() async {
        await playerService.togglePlayback()
    }

    func onSkipBackwardTap() async {
        await playerService.skipBackward()
    }

    func onSkipForwardTap() async {
        await playerService.skipForward()
    }

    func onSeek(to time: TimeInterval) {
        playerService.seek(to: time)
    }
    
    func onCloseTap() {
        router.close()
    }
    
    func onCreateMemoryTap() {
        guard let songID = currentTrack?.id else { return }
        router.goToCreateMemory(songID: songID)
    }

    // MARK: - Private properties

    private let router: TrackPlayerRouter
    private let playerService: PlayerService
}
