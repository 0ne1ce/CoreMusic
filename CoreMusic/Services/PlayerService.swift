import Combine
import Foundation

@MainActor
protocol PlayerService: AnyObject {
    var currentTrack: LibraryTrack? { get }
    var currentTrackID: String? { get }
    var isPlaying: Bool { get }
    var playbackTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var currentQueue: [LibraryTrack] { get }
    var currentQueueIndex: Int? { get }

    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var currentTrackPublisher: AnyPublisher<LibraryTrack?, Never> { get }
    var playbackTimePublisher: AnyPublisher<TimeInterval, Never> { get }
    var durationPublisher: AnyPublisher<TimeInterval, Never> { get }

    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState
    func play(track: LibraryTrack, queue: [LibraryTrack]) async
    func togglePlayback() async
    func pause()
    func resume() async
    func seek(to time: TimeInterval)
    func skipForward() async
    func skipBackward() async
    func stop()
}
