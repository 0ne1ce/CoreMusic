import Combine
import SwiftUI


@MainActor
protocol MemoriesViewModel: ObservableObject {
    var title: String { get }
}

@MainActor
final class MemoriesViewModelImpl: MemoriesViewModel {
    // MARK: - Properties

    @Published var title = "Воспоминания"

    // MARK: - Initializer

    init(router: any MemoriesRouter) {
        self.router = router
    }

    // MARK: - Private properties

    private let router: any MemoriesRouter
}
