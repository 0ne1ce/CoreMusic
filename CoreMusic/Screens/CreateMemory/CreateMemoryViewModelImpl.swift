import SwiftUI
import Combine

@MainActor
final class CreateMemoryViewModelImpl: CreateMemoryViewModel {

    // MARK: - Properties

    @Published var title: String = "Create Memory"
    @Published var navigationTitle = "Новое воспоминание"
    @Published var songDescription: String

    // MARK: - Initializers

    init(router: any CreateMemoryRouter, songID: String) {
        self.router = router
        self.songDescription = "Song: \(songID)"
    }

    // MARK: - Methods

    func onCloseTap() {
        router.close()
    }

    // MARK: - Private properties

    private let router: any CreateMemoryRouter
}
