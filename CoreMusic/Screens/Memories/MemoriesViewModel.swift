import Combine
import SwiftUI


@MainActor
protocol MemoriesViewModel: ObservableObject {
    // MARK: - Properties

    var title: String { get }
    var memories: [Memory] { get }
    var displayedMemories: [Memory] { get }
    var searchInput: String { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    // MARK: - Methods

    func onAppear()
    func retry()
    func onMemoryTap(_ memory: Memory)
    func onFavoriteTap(_ memory: Memory)
    func onDeleteTap(_ memory: Memory)
}

@MainActor
final class MemoriesViewModelImpl: MemoriesViewModel {
    // MARK: - Properties

    @Published var title = "Воспоминания"
    @Published private(set) var memories: [Memory] = []
    @Published var searchInput: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var displayedMemories: [Memory] {
        let input = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            return memories
        }
        return memories.filter { memory in
            memory.memoryTitle.localizedStandardContains(input) ||
            memory.note.localizedStandardContains(input) ||
            memory.songTitle.localizedStandardContains(input) ||
            memory.artistName.localizedStandardContains(input) ||
            (memory.locationName?.localizedStandardContains(input) ?? false) ||
            memory.tagsStorage.localizedStandardContains(input)
        }
    }

    // MARK: - Initializer

    init(router: MemoriesRouter, memoryRepository: MemoryRepository) {
        self.router = router
        self.memoryRepository = memoryRepository
    }

    // MARK: - Methods

    func onAppear() {
        guard !isLoading else {
            return
        }

        loadMemories()
    }

    func retry() {
        loadMemories()
    }

    func onMemoryTap(_ memory: Memory) {
        router.openCarousel(startMemoryID: memory.id)
    }

    func onFavoriteTap(_ memory: Memory) {
        do {
            try memoryRepository.toggleFavorite(memory)
        }
        catch {
            errorMessage = "Не удалось обновить воспоминание."
        }
    }

    func onDeleteTap(_ memory: Memory) {
        do {
            try memoryRepository.deleteMemory(memory)
            withAnimation {
                memories.removeAll { $0.id == memory.id }
            }
        }
        catch {
            errorMessage = "Не удалось удалить воспоминание."
        }
    }

    // MARK: - Private properties

    private let router: MemoriesRouter
    private let memoryRepository: MemoryRepository

    // MARK: - Private methods

    private func loadMemories() {
        isLoading = true
        errorMessage = nil

        do {
            memories = try memoryRepository.fetchMemories()
        }
        catch {
            errorMessage = "Не удалось загрузить воспоминания."
        }

        isLoading = false
    }
}
