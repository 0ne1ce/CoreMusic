import Combine
import MusicKit
import SwiftUI

enum HomeSection {
    case recentMemories
    case recentTracks
    case favorites
    case cityTour
}

@MainActor
protocol HomeViewModel: ObservableObject {
    // MARK: - Properties

    var title: String { get }
    var recentMemories: [Memory] { get }
    var favoriteMemories: [Memory] { get }
    var cityTourMemories: [Memory] { get }
    var recentTracks: [LibraryTrack] { get }
    var isLoadingTracks: Bool { get }
    var hasAnyContent: Bool { get }

    // MARK: - Methods

    func onAppear() async
    func onProfileTap()
    func onSectionTap(_ section: HomeSection)
    func onMemoryTap(_ memory: Memory, in section: HomeSection)
    func onFavoriteTap(_ memory: Memory)
    func onTrackTap(_ track: LibraryTrack) async
    func onTrackAddTap(_ track: LibraryTrack)
    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState
}

@MainActor
final class HomeViewModelImpl: HomeViewModel {
    // MARK: - Properties

    @Published var title = "Главная"
    @Published private(set) var recentMemories: [Memory] = []
    @Published private(set) var favoriteMemories: [Memory] = []
    @Published private(set) var cityTourMemories: [Memory] = []
    @Published private(set) var recentTracks: [LibraryTrack] = []
    @Published private(set) var isLoadingTracks = false
    private(set) var totalTracksCount = 0

    var hasAnyContent: Bool {
        !recentMemories.isEmpty
            || !recentTracks.isEmpty
            || !favoriteMemories.isEmpty
            || !cityTourMemories.isEmpty
            || isLoadingTracks
    }

    // MARK: - Initializer

    init(
        router: HomeRouter,
        musicService: any MusicService,
        playerService: PlayerServiceImpl,
        memoryRepository: MemoryRepository
    ) {
        self.router = router
        self.musicService = musicService
        self.playerService = playerService
        self.memoryRepository = memoryRepository

        playerService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Methods

    func onAppear() async {
        loadMemories()

        if MusicAuthorization.currentStatus == .authorized, recentTracks.isEmpty {
            await loadTracks()
        }
    }

    func onProfileTap() {
        let allMemories: [Memory]
        do { allMemories = try memoryRepository.fetchMemories() }
        catch { allMemories = [] }

        router.openProfile(
            totalMemories: allMemories.count,
            favoriteMemories: allMemories.filter(\.isFavorite).count,
            totalTracks: totalTracksCount
        )
    }

    func onSectionTap(_ section: HomeSection) {
        switch section {
        case .recentMemories, .favorites, .cityTour:
            router.goToTab(.memories)
        case .recentTracks:
            router.goToTab(.library)
        }
    }

    func onMemoryTap(_ memory: Memory, in section: HomeSection) {
        let ids: [UUID]
        switch section {
        case .recentMemories:
            ids = recentMemories.map(\.id)
        case .favorites:
            ids = favoriteMemories.map(\.id)
        case .cityTour:
            ids = cityTourMemories.map(\.id)
        case .recentTracks:
            return
        }
        router.openCarousel(startMemoryID: memory.id, memoryIDs: ids)
    }

    func onFavoriteTap(_ memory: Memory) {
        do {
            try memoryRepository.toggleFavorite(memory)
            loadMemories()
        }
        catch { }
    }

    func onTrackTap(_ track: LibraryTrack) async {
        await playerService.play(track: track, queue: recentTracks)
    }

    func onTrackAddTap(_ track: LibraryTrack) {
        router.openCreateMemory(songID: track.id)
    }

    func playbackState(for trackID: String) -> TrackCardModel.PlaybackState {
        playerService.playbackState(for: trackID)
    }

    // MARK: - Private properties

    private let router: HomeRouter
    private let musicService: any MusicService
    private let playerService: PlayerServiceImpl
    private let memoryRepository: MemoryRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Private methods

    private func loadMemories() {
        do {
            let all = try memoryRepository.fetchMemories()
            recentMemories = Array(all.prefix(Constants.maxMemories))
            favoriteMemories = Array(all.filter(\.isFavorite).prefix(Constants.maxMemories))
            cityTourMemories = Array(
                all
                    .filter { $0.locationName?.isEmpty == false }
                    .prefix(Constants.maxMemories)
            )
        }
        catch { }
    }

    private func loadTracks() async {
        isLoadingTracks = true
        defer { isLoadingTracks = false }

        do {
            let tracks = try await musicService.fetchLibrarySongs()
            recentTracks = Array(tracks.prefix(Constants.maxTracks))
            totalTracksCount = tracks.count
        }
        catch { }
    }
}

private enum Constants {
    static let maxMemories = 5
    static let maxTracks = 9
}
