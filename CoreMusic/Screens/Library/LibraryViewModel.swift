import Combine
import SwiftUI

@MainActor
protocol LibraryViewModel: ObservableObject {
    // MARK: - Properties

    var title: String { get }
    var createMemoryButtonTitle: String { get }

    // MARK: - Methods

    func onCreateMemoryTap()
}

@MainActor
final class LibraryViewModelImpl: LibraryViewModel {
    // MARK: - Properties

    @Published var title = "Медиатека"
    @Published var createMemoryButtonTitle = "Тест push: createMemory"

    // MARK: - Initializer

    init(router: any LibraryRouter) {
        self.router = router
    }

    // MARK: - Methods

    func onCreateMemoryTap() {
        router.goToCreateMemory(songID: "preview-song-id")
    }

    // MARK: - Private properties

    private let router: any LibraryRouter
}
