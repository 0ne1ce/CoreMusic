import PhotosUI
import SwiftUI
import Combine

@MainActor
final class CreateMemoryViewModelImpl: CreateMemoryViewModel {

    // MARK: - Properties

    @Published var navigationTitle: String
    @Published private(set) var selectedTrack: LibraryTrack?
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { loadPhotoData() }
    }
    @Published private(set) var selectedPhotoData: Data?
    @Published var memoryTitle = ""
    @Published var note = ""
    @Published var memoryDate = Date()
    @Published var isDateEnabled = false
    @Published var isLocationEnabled = false
    @Published var locationName = ""
    @Published private(set) var locationSuggestions: [LocationSuggestion] = []
    @Published var tagInput = ""
    @Published private(set) var tags: [String] = []
    @Published var isFavorite = false
    @Published private(set) var isSaving = false
    @Published var showDeleteConfirmation = false
    @Published private(set) var errorMessage: String?

    let isEditMode: Bool

    var canSave: Bool {
        !memoryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    // MARK: - Initializers

    init(
        router: CreateMemoryRouter,
        songID: String,
        musicService: any MusicService,
        playerService: PlayerService,
        memoryRepository: MemoryRepository,
        locationSearchService: LocationSearchService,
        notificationService: NotificationService,
        editingMemory: Memory? = nil
    ) {
        self.router = router
        self.songID = songID
        self.musicService = musicService
        self.playerService = playerService
        self.memoryRepository = memoryRepository
        self.locationSearchService = locationSearchService
        self.notificationService = notificationService
        self.editingMemory = editingMemory
        self.isEditMode = editingMemory != nil
        self.navigationTitle = editingMemory != nil ? "Редактировать" : "Новое воспоминание"

        if let memory = editingMemory {
            prefill(from: memory)
        }

        locationSearchService.suggestionsPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$locationSuggestions)

        userQuerySubject
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.locationSearchService.updateQuery(query)
            }
            .store(in: &cancellables)
    }

    // MARK: - Methods

    func onAppear() {
        guard selectedTrack == nil else {
            return
        }

        if let editingMemory {
            selectedTrack = LibraryTrack(
                id: editingMemory.songID,
                title: editingMemory.songTitle,
                artistName: editingMemory.artistName,
                artwork: nil,
                artworkURL: editingMemory.trackArtworkURLString.flatMap { URL(string: $0) },
                libraryAddedDate: nil,
                durationSeconds: nil
            )
            return
        }

        if playerService.currentTrackID == songID {
            selectedTrack = playerService.currentTrack
        }
        else {
            selectedTrack = musicService.cachedTrack(for: songID)
        }
    }

    func onCloseTap() {
        router.close()
    }

    func onSaveTap() async {
        guard canSave else {
            return
        }

        isSaving = true
        defer {
            isSaving = false
        }

        let draft = MemoryDraft(
            songID: songID,
            songTitle: selectedTrack?.title ?? "Неизвестный трек",
            artistName: selectedTrack?.artistName ?? "Неизвестный артист",
            trackArtworkURLString: selectedTrack?.artworkURL?.absoluteString,
            memoryTitle: memoryTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: isDateEnabled ? memoryDate : Date(),
            locationName: normalizedLocationName,
            photoData: selectedPhotoData,
            tags: tags,
            isFavorite: isFavorite
        )

        do {
            if let editingMemory {
                try memoryRepository.updateMemory(editingMemory, with: draft)
            }
            else {
                try memoryRepository.saveMemory(draft)
            }
            rescheduleNotifications()
            router.close()
        }
        catch {
            errorMessage = "Не удалось сохранить воспоминание. Попробуйте ещё раз."
        }
    }

    func onDeleteTap() {
        showDeleteConfirmation = true
    }

    func confirmDelete() {
        guard let editingMemory else { return }

        do {
            try memoryRepository.deleteMemory(editingMemory)
            rescheduleNotifications()
            router.dismissAll()
        }
        catch {
            errorMessage = "Не удалось удалить воспоминание."
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    func onAddTagTap() {
        let normalizedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedTag.isEmpty else {
            return
        }

        guard !tags.contains(normalizedTag) else {
            tagInput = ""
            return
        }

        tags.append(normalizedTag)
        tagInput = ""
    }

    func onRemoveTagTap(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    func locationNameChanged(_ value: String) {
        locationName = value
        userQuerySubject.send(value)
    }

    func selectLocationSuggestion(_ suggestion: LocationSuggestion) {
        locationName = suggestion.city
        locationSearchService.clear()
    }

    // MARK: - Private properties

    private let router: CreateMemoryRouter
    private let songID: String
    private let musicService: any MusicService
    private let playerService: PlayerService
    private let memoryRepository: MemoryRepository
    private let locationSearchService: LocationSearchService
    private let notificationService: NotificationService
    private let editingMemory: Memory?
    private let userQuerySubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Private methods

    private func rescheduleNotifications() {
        let all: [Memory]
        do { all = try memoryRepository.fetchMemories() }
        catch { return }
        notificationService.rescheduleOnThisDayNotifications(memories: all)
    }

    private func prefill(from memory: Memory) {
        memoryTitle = memory.memoryTitle
        note = memory.note
        memoryDate = memory.date
        isDateEnabled = true
        locationName = memory.locationName ?? ""
        isLocationEnabled = memory.locationName != nil && !memory.locationName!.isEmpty
        tags = memory.tagsStorage.split(separator: "|").map(String.init).filter { !$0.isEmpty }
        isFavorite = memory.isFavorite
        selectedPhotoData = memory.photoData
    }

    private func loadPhotoData() {
        guard let item = selectedPhotoItem else {
            if editingMemory == nil {
                selectedPhotoData = nil
            }
            return
        }

        Task {
            selectedPhotoData = try? await item.loadTransferable(type: Data.self)
        }
    }

    private var normalizedLocationName: String? {
        guard isLocationEnabled else {
            return nil
        }

        let trimmedLocationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedLocationName.isEmpty ? nil : trimmedLocationName
    }
}
