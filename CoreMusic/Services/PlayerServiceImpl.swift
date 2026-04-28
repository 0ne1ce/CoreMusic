import Combine
import Foundation
import MusicKit
import OSLog

@MainActor
final class PlayerServiceImpl: ObservableObject, PlayerService {
    // MARK: - Properties

    @Published private(set) var currentTrack: LibraryTrack?
    @Published private(set) var isPlaying = false
    @Published private(set) var playbackTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    var currentTrackID: String? {
        currentTrack?.id
    }

    // MARK: - Initializer

    init(musicService: any MusicService) {
        self.musicService = musicService
    }

    deinit {
        playbackTimer?.invalidate()
    }

    // MARK: - Public methods

    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState {
        guard currentTrackID == trackID else {
            return .idle
        }

        return isPlaying ? .playing : .paused
    }

    func play(track: LibraryTrack, queue: [LibraryTrack]) async {
        if currentTrackID == track.id {
            await togglePlayback()
            return
        }

        do {
            guard let song = try await musicService.song(for: track.id) else {
                log.error("Failed to resolve song for track \(track.id, privacy: .public)")
                return
            }

            currentQueue = queue
            currentTrack = track
            currentQueueIndex = queue.firstIndex { $0.id == track.id }
            duration = resolvedDuration(for: track, song: song)
            playbackTime = 0

            player.queue = ApplicationMusicPlayer.Queue(for: [song])
            try await player.play()
            isPlaying = true
            startPlaybackTimer()
        }
        catch {
            log.error("Playback failed for track \(track.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    func togglePlayback() async {
        if isPlaying {
            pause()
        }
        else {
            await resume()
        }
    }

    func pause() {
        player.pause()
        isPlaying = false
        stopPlaybackTimer()
    }

    func resume() async {
        do {
            try await player.play()
            isPlaying = true
            startPlaybackTimer()
        }
        catch {
            log.error("Resume playback failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func seek(to time: TimeInterval) {
        player.playbackTime = time
        playbackTime = time
    }

    func skipForward() async {
        guard let index = currentQueueIndex, currentQueue.indices.contains(index + 1) else {
            return
        }

        await play(track: currentQueue[index + 1], queue: currentQueue)
    }

    func skipBackward() async {
        if playbackTime > Constants.restartThreshold {
            seek(to: 0)
            return
        }

        guard let index = currentQueueIndex, currentQueue.indices.contains(index - 1) else {
            seek(to: 0)
            return
        }

        await play(track: currentQueue[index - 1], queue: currentQueue)
    }

    func stop() {
        player.stop()
        stopPlaybackTimer()
        currentTrack = nil
        currentQueue = []
        currentQueueIndex = nil
        playbackTime = 0
        duration = 0
        isPlaying = false
    }

    // MARK: - Private properties

    private let musicService: any MusicService
    private let player = ApplicationMusicPlayer.shared
    private let log = Logger(subsystem: "com.coremusic.app", category: "PlayerService")
    private var currentQueue: [LibraryTrack] = []
    private var currentQueueIndex: Int?
    private var playbackTimer: Timer?

    // MARK: - Private methods

    private func resolvedDuration(for track: LibraryTrack, song: Song) -> TimeInterval {
        track.durationSeconds ?? song.duration ?? 0
    }

    private func startPlaybackTimer() {
        stopPlaybackTimer()

        playbackTimer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshPlaybackProgress()
            }
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func refreshPlaybackProgress() {
        playbackTime = player.playbackTime

        if duration == 0 {
            duration = currentTrack?.durationSeconds ?? 0
        }

        if duration > 0, playbackTime >= duration {
            isPlaying = false
            stopPlaybackTimer()
        }
    }
}

private enum Constants {
    static let timerInterval: TimeInterval = 0.5
    static let restartThreshold: TimeInterval = 3
}
