import PhotosUI
import SwiftUI

@MainActor
protocol CreateMemoryViewModel: ObservableObject {
    // MARK: - Properties

    var navigationTitle: String { get }
    var isEditMode: Bool { get }
    var selectedTrack: LibraryTrack? { get }
    var selectedPhotoItem: PhotosPickerItem? { get set }
    var selectedPhotoData: Data? { get }
    var memoryTitle: String { get set }
    var note: String { get set }
    var memoryDate: Date { get set }
    var isDateEnabled: Bool { get set }
    var isLocationEnabled: Bool { get set }
    var locationName: String { get set }
    var locationSuggestions: [LocationSuggestion] { get }
    var tagInput: String { get set }
    var tags: [String] { get }
    var isFavorite: Bool { get set }
    var isSaving: Bool { get }
    var showDeleteConfirmation: Bool { get set }
    var errorMessage: String? { get }
    var canSave: Bool { get }

    // MARK: - Methods

    func onAppear()
    func onCloseTap()
    func onSaveTap() async
    func onDeleteTap()
    func confirmDelete()
    func onAddTagTap()
    func onRemoveTagTap(_ tag: String)
    func dismissError()
    func locationNameChanged(_ value: String)
    func selectLocationSuggestion(_ suggestion: LocationSuggestion)
}
