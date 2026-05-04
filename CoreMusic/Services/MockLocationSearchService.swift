import Combine

@MainActor
final class MockLocationSearchService: LocationSearchService {
    // MARK: - Properties

    var suggestionsPublisher: AnyPublisher<[LocationSuggestion], Never> {
        suggestionsSubject.eraseToAnyPublisher()
    }

    // MARK: - Methods

    func updateQuery(_ query: String) {
        if query.isEmpty {
            suggestionsSubject.send([])
        }
        else {
            suggestionsSubject.send(Self.previewSuggestions)
        }
    }

    func clear() {
        suggestionsSubject.send([])
    }

    // MARK: - Private properties

    private let suggestionsSubject = CurrentValueSubject<[LocationSuggestion], Never>([])

    private static let previewSuggestions: [LocationSuggestion] = [
        LocationSuggestion(city: "Москва", fullName: "Москва, Россия"),
        LocationSuggestion(city: "Санкт-Петербург", fullName: "Санкт-Петербург, Россия"),
        LocationSuggestion(city: "Казань", fullName: "Казань, Республика Татарстан, Россия")
    ]
}
