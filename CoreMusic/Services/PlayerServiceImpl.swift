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
    @Published private(set) var currentQueue: [LibraryTrack] = []
    @Published private(set) var currentQueueIndex: Int?

    var currentTrackID: String? {
        currentTrack?.id
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        $isPlaying.eraseToAnyPublisher()
    }

    var currentTrackPublisher: AnyPublisher<LibraryTrack?, Never> {
        $currentTrack.eraseToAnyPublisher()
    }

    var playbackTimePublisher: AnyPublisher<TimeInterval, Never> {
        $playbackTime.eraseToAnyPublisher()
    }

    var durationPublisher: AnyPublisher<TimeInterval, Never> {
        $duration.eraseToAnyPublisher()
    }

    // MARK: - Initializer

    init(musicService: any MusicService) {
        self.musicService = musicService
        observePlayerState()
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

        // If the new track is already in the current AMP queue, skip to it
        // without re-resolving songs or rebuilding the queue. Fast path for
        // SwipeableMiniPlayer swipes and similar.
        if isSameQueue(queue),
           let currentIdx = currentQueueIndex,
           let targetIdx = currentQueue.firstIndex(where: { $0.id == track.id }) {
            await skipInExistingQueue(from: currentIdx, to: targetIdx)
            return
        }

        await rebuildQueue(startingAt: track, queue: queue)
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
        wasPlayingBeforeSeek = isPlaying
        isTransitioning = true
        seekToken += 1
        let token = seekToken
        player.playbackTime = time
        playbackTime = time

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.seekSettleDelay) { [weak self] in
            guard let self, self.seekToken == token else { return }
            self.isTransitioning = false
            if self.wasPlayingBeforeSeek && self.player.state.playbackStatus != .playing {
                Task { @MainActor [weak self] in await self?.resume() }
            }
        }
    }

    func skipForward() async {
        guard let index = currentQueueIndex, currentQueue.indices.contains(index + 1) else {
            return
        }

        await advanceWithinQueue(direction: 1)
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

        await advanceWithinQueue(direction: -1)
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
        lastObservedEntryID = nil
    }

    // MARK: - Private properties

    private let musicService: any MusicService
    private let player = ApplicationMusicPlayer.shared
    private let log = Logger(subsystem: "com.coremusic.app", category: "PlayerService")
    private var playbackTimer: Timer?
    private var stateObservation: AnyCancellable?
    private var isTransitioning = false
    private var seekToken = 0
    private var wasPlayingBeforeSeek = false
    private var lastObservedEntryID: String?

    // MARK: - Private methods

    private func resolvedDuration(for track: LibraryTrack, song: Song) -> TimeInterval {
        track.durationSeconds ?? song.duration ?? 0
    }

    private func isSameQueue(_ queue: [LibraryTrack]) -> Bool {
        guard queue.count == currentQueue.count else { return false }
        return zip(queue, currentQueue).allSatisfy { $0.id == $1.id }
    }

    private func rebuildQueue(startingAt track: LibraryTrack, queue: [LibraryTrack]) async {
        isTransitioning = true
        seekToken += 1

        let windowedQueue = makeWindow(queue: queue, around: track.id)
        let resolved = await resolveSongs(for: windowedQueue)

        let pairs = zip(windowedQueue, resolved).compactMap { pair -> (LibraryTrack, Song)? in
            guard let song = pair.1 else { return nil }
            return (pair.0, song)
        }

        guard let startPair = pairs.first(where: { $0.0.id == track.id }),
              let startIdx = pairs.firstIndex(where: { $0.0.id == track.id })
        else {
            isTransitioning = false
            log.error("Failed to resolve target track \(track.id, privacy: .public)")
            return
        }

        let validTracks = pairs.map { $0.0 }
        let songs = pairs.map { $0.1 }
        let startSong = startPair.1

        currentQueue = validTracks
        currentTrack = track
        currentQueueIndex = startIdx
        duration = resolvedDuration(for: track, song: startSong)
        playbackTime = 0
        lastObservedEntryID = nil

        do {
            player.queue = ApplicationMusicPlayer.Queue(for: songs, startingAt: startSong)
            try await player.play()
            isPlaying = true
            isTransitioning = false
            startPlaybackTimer()
        }
        catch {
            isTransitioning = false
            log.error("Playback failed for track \(track.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    private func makeWindow(queue: [LibraryTrack], around trackID: String) -> [LibraryTrack] {
        guard queue.count > Constants.maxQueueWindow else { return queue }
        let startIdx = queue.firstIndex(where: { $0.id == trackID }) ?? 0
        let halfBefore = Constants.maxQueueWindow / 2
        var windowStart = max(0, startIdx - halfBefore)
        let windowEnd = min(queue.count, windowStart + Constants.maxQueueWindow)
        windowStart = max(0, windowEnd - Constants.maxQueueWindow)
        return Array(queue[windowStart..<windowEnd])
    }

    private func resolveSongs(for tracks: [LibraryTrack]) async -> [Song?] {
        var results: [Song?] = []
        for track in tracks {
            let song = try? await musicService.song(for: track.id)
            results.append(song)
        }
        return results
    }


    private func advanceWithinQueue(direction: Int) async {
        isTransitioning = true
        seekToken += 1
        do {
            if direction > 0 {
                try await player.skipToNextEntry()
            }
            else {
                try await player.skipToPreviousEntry()
            }
            // currentEntry observer (via timer) will update currentTrack / index
            isTransitioning = false
        }
        catch {
            isTransitioning = false
            log.error("Skip failed (\(direction, privacy: .public)): \(error.localizedDescription, privacy: .public)")
        }
    }

    private func skipInExistingQueue(from currentIdx: Int, to targetIdx: Int) async {
        let diff = targetIdx - currentIdx
        if abs(diff) == 1 {
            await advanceWithinQueue(direction: diff > 0 ? 1 : -1)
        }
        else {
            await rebuildQueue(startingAt: currentQueue[targetIdx], queue: currentQueue)
        }
    }

    private func startPlaybackTimer() {
        stopPlaybackTimer()

        let timer = Timer(timeInterval: Constants.timerInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshPlaybackProgress()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        playbackTimer = timer
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func refreshPlaybackProgress() {
        syncCurrentEntry()

        let rawTime = player.playbackTime
        if abs(rawTime - playbackTime) > 0.05 {
            playbackTime = rawTime
        }

        if duration == 0 {
            duration = currentTrack?.durationSeconds ?? 0
        }
    }

    private func syncCurrentEntry() {
        let currentEntryID = player.queue.currentEntry?.id
        guard currentEntryID != lastObservedEntryID else { return }
        lastObservedEntryID = currentEntryID

        guard !isTransitioning, let currentEntry = player.queue.currentEntry else { return }

        let entries = player.queue.entries
        guard let entryIdx = entries.firstIndex(where: { $0.id == currentEntry.id }),
              entryIdx < currentQueue.count
        else { return }

        let newTrack = currentQueue[entryIdx]
        guard currentTrack?.id != newTrack.id else { return }

        currentTrack = newTrack
        currentQueueIndex = entryIdx
        playbackTime = 0
        if case let .song(song) = currentEntry.item {
            duration = song.duration ?? newTrack.durationSeconds ?? 0
        }
        else {
            duration = newTrack.durationSeconds ?? 0
        }
    }

    private func observePlayerState() {
        stateObservation = player.state.objectWillChange
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.syncPlaybackState()
                }
            }
    }

    private func syncPlaybackState() {
        syncCurrentEntry()

        guard currentTrack != nil, !isTransitioning else { return }

        let playerStatus = player.state.playbackStatus

        switch playerStatus {
        case .playing:
            guard !isPlaying else { return }
            isPlaying = true
            startPlaybackTimer()
        case .paused, .stopped:
            guard isPlaying else { return }
            isPlaying = false
        default:
            break
        }
    }
}

private enum Constants {
    static let timerInterval: TimeInterval = 0.5
    static let restartThreshold: TimeInterval = 3
    static let seekSettleDelay: TimeInterval = 1.0
    static let maxQueueWindow = 30
}
