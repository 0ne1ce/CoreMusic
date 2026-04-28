import Combine
import MapKit

@MainActor
final class LocationSearchService: NSObject, ObservableObject {
    // MARK: - Properties

    @Published private(set) var suggestions: [LocationSuggestion] = []

    var query: String = "" {
        didSet {
            if query.isEmpty {
                suggestions = []
                completer.cancel()
            }
            else {
                completer.queryFragment = query
            }
        }
    }

    // MARK: - Methods

    func clear() {
        query = ""
        suggestions = []
        completer.cancel()
    }

    // MARK: - Initializer

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    // MARK: - Private properties

    private let completer = MKLocalSearchCompleter()
}

// MARK: - LocationSuggestion

struct LocationSuggestion: Identifiable, Hashable {
    let id = UUID()
    let city: String
    let fullName: String
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchService: MKLocalSearchCompleterDelegate {
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
            self.suggestions = Array(results)
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.suggestions = []
        }
    }
}
