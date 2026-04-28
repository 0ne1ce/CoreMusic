import Foundation

@MainActor
protocol PlayerService: AnyObject {
    var currentTrack: LibraryTrack? { get }
    var currentTrackID: String? { get }
    var isPlaying: Bool { get }
    var playbackTime: TimeInterval { get }
    var duration: TimeInterval { get }

    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState
    func play(track: LibraryTrack, queue: [LibraryTrack]) async
    func togglePlayback() async
    func pause() async
    func resume() async
    func seek(to time: TimeInterval)
    func skipForward() async
    func skipBackward() async
    func stop()
}
