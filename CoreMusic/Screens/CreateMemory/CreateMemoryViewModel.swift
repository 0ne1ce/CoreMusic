import SwiftUI

@MainActor
protocol CreateMemoryViewModel: ObservableObject {
    // MARK: - Properties

    var navigationTitle: String { get }
    var selectedTrack: LibraryTrack? { get }
    var memoryTitle: String { get set }
    var note: String { get set }
    var memoryDate: Date { get set }
    var isDateEnabled: Bool { get set }
    var isLocationEnabled: Bool { get set }
    var locationName: String { get set }
    var tagInput: String { get set }
    var tags: [String] { get }
    var isFavorite: Bool { get set }
    var isSaving: Bool { get }
    var errorMessage: String? { get }
    var canSave: Bool { get }

    // MARK: - Methods

    func onAppear()
    func onCloseTap()
    func onSaveTap() async
    func onAddTagTap()
    func onRemoveTagTap(_ tag: String)
    func dismissError()
}
