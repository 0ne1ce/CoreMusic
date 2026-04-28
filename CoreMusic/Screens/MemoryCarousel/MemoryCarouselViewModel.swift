import Combine
import SwiftUI

@MainActor
protocol MemoryCarouselViewModel: ObservableObject {
    // MARK: - Properties

    var memories: [Memory] { get }
    var currentMemoryID: UUID? { get set }
    var currentIndex: Int { get }
    var errorMessage: String? { get }

    // MARK: - Methods

    func onClose()
    func onEditTap(_ memory: Memory)
    func onFavoriteTap(_ memory: Memory)
    func onDeleteTap(_ memory: Memory)
    func onPlayTap(_ memory: Memory)
    func heroImage(for memory: Memory) -> UIImage?
    func trackCardModel(for memory: Memory) -> TrackCardModel
    func formattedDate(for memory: Memory) -> String
    func tags(for memory: Memory) -> [String]
}

@MainActor
final class MemoryCarouselViewModelImpl: MemoryCarouselViewModel {
    // MARK: - Properties

    @Published private(set) var memories: [Memory] = []
    @Published var currentMemoryID: UUID?
    @Published private(set) var errorMessage: String?

    var currentIndex: Int {
        guard let id = currentMemoryID else { return 0 }
        return memories.firstIndex(where: { $0.id == id }) ?? 0
    }

    // MARK: - Initializer

    init(
        startMemoryID: UUID,
        memoryIDs: [UUID]?,
        router: MemoryCarouselRouter,
        memoryRepository: MemoryRepository,
        playerService: PlayerServiceImpl
    ) {
        self.startMemoryID = startMemoryID
        self.memoryIDs = memoryIDs
        self.router = router
        self.memoryRepository = memoryRepository
        self.playerService = playerService

        playerService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        loadMemories()
    }

    // MARK: - Methods

    func onClose() {
        router.close()
    }

    func onEditTap(_ memory: Memory) {
        router.openEdit(memoryID: memory.id)
    }

    func onFavoriteTap(_ memory: Memory) {
        do {
            try memoryRepository.toggleFavorite(memory)
        }
        catch {
            errorMessage = "Не удалось обновить избранное."
        }
    }

    func onDeleteTap(_ memory: Memory) {
        do {
            try memoryRepository.deleteMemory(memory)
            withAnimation {
                memories.removeAll { $0.id == memory.id }
            }
            if memories.isEmpty {
                router.close()
            }
        }
        catch {
            errorMessage = "Не удалось удалить воспоминание."
        }
    }

    func onPlayTap(_ memory: Memory) {
        let track = libraryTrack(for: memory)
        Task {
            let state = playerService.playbackState(for: memory.songID)
            switch state {
            case .idle:
                await playerService.play(track: track, queue: [track])
            case .playing:
                playerService.pause()
            case .paused:
                await playerService.resume()
            }
        }
    }

    func heroImage(for memory: Memory) -> UIImage? {
        heroImages[memory.id]
    }

    func trackCardModel(for memory: Memory) -> TrackCardModel {
        let track = libraryTrack(for: memory)
        let playbackState = playerService.playbackState(for: memory.songID)
        return TrackCardModel(track: track, playbackState: playbackState)
    }

    func formattedDate(for memory: Memory) -> String {
        Self.dateFormatter.string(from: memory.date)
    }

    func tags(for memory: Memory) -> [String] {
        memory.tagsStorage
            .split(separator: "|")
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    // MARK: - Private properties

    private let startMemoryID: UUID
    private let memoryIDs: [UUID]?
    private let router: MemoryCarouselRouter
    private let memoryRepository: MemoryRepository
    private let playerService: PlayerServiceImpl
    private var cancellables = Set<AnyCancellable>()
    private var heroImages: [UUID: UIImage] = [:]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    // MARK: - Private methods

    private func loadMemories() {
        do {
            var allMemories = try memoryRepository.fetchMemories()
            if let ids = memoryIDs {
                let idSet = Set(ids)
                allMemories = allMemories.filter { idSet.contains($0.id) }
            }
            memories = allMemories
            prepareHeroImages()
            currentMemoryID = startMemoryID
        }
        catch {
            errorMessage = "Не удалось загрузить воспоминания."
        }
    }

    private func prepareHeroImages() {
        for memory in memories {
            if let photoData = memory.photoData,
               let image = UIImage(data: photoData) {
                heroImages[memory.id] = image
            }
        }
    }

    private func libraryTrack(for memory: Memory) -> LibraryTrack {
        LibraryTrack(
            id: memory.songID,
            title: memory.songTitle,
            artistName: memory.artistName,
            artwork: nil,
            artworkURL: memory.trackArtworkURLString.flatMap { URL(string: $0) },
            libraryAddedDate: nil,
            durationSeconds: nil
        )
    }
}
