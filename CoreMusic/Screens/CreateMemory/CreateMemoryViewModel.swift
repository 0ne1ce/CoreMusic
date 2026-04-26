import SwiftUI

@MainActor
protocol CreateMemoryViewModel: ObservableObject {
    // MARK: - Properties

    var title: String { get }
    var songDescription: String { get }
    var navigationTitle: String { get }

    // MARK: - Methods

    func onCloseTap()
}
