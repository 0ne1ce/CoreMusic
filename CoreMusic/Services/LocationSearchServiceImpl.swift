import Combine
import MapKit

@MainActor
final class LocationSearchServiceImpl: NSObject, LocationSearchService {
    // MARK: - Properties

    var suggestionsPublisher: AnyPublisher<[LocationSuggestion], Never> {
        suggestionsSubject.eraseToAnyPublisher()
    }

    // MARK: - Initializer

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    // MARK: - Methods

    func updateQuery(_ query: String) {
        if query.isEmpty {
            suggestionsSubject.send([])
            completer.cancel()
        }
        else {
            completer.queryFragment = query
        }
    }

    func clear() {
        completer.cancel()
        suggestionsSubject.send([])
    }

    // MARK: - Private properties

    private let completer = MKLocalSearchCompleter()
    private let suggestionsSubject = CurrentValueSubject<[LocationSuggestion], Never>([])
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchServiceImpl: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.prefix(5).map { result in
            LocationSuggestion(
                city: result.title,
                fullName: result.subtitle.isEmpty
                    ? result.title
                    : "\(result.title), \(result.subtitle)"
            )
        }

        Task { @MainActor in
            self.suggestionsSubject.send(Array(results))
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.suggestionsSubject.send([])
        }
    }
}
