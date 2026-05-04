import Combine
import Foundation

@MainActor
protocol LocationSearchService: AnyObject {
    // MARK: - Properties

    var suggestionsPublisher: AnyPublisher<[LocationSuggestion], Never> { get }

    // MARK: - Methods

    func updateQuery(_ query: String)
    func clear()
}

// MARK: - LocationSuggestion

struct LocationSuggestion: Identifiable, Hashable {
    let id = UUID()
    let city: String
    let fullName: String
}
