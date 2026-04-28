import Combine
import SwiftUI

@MainActor
protocol HomeViewModel: ObservableObject {
    var title: String { get }
}

@MainActor
final class HomeViewModelImpl: HomeViewModel {
    // MARK: - Properties

    @Published var title = "Главная"

    // MARK: - Initializers

    init(router: HomeRouter) {
        self.router = router
    }

    // MARK: - Private properties

    private let router: HomeRouter
}
