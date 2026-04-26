import Foundation

enum LibrarySectionBuilder {
    // MARK: - Methods

    static func group(_ tracks: [LibraryTrack]) -> [LibrarySection] {
        var groups: [String: GroupEntry] = [:]
        var insertionOrder: [String] = []

        for track in tracks {
            let key = key(for: track)
            if groups[key] == nil {
                groups[key] = GroupEntry(
                    sortDate: sortDate(for: track),
                    tracks: []
                )
                insertionOrder.append(key)
            }
            groups[key]?.tracks.append(track)
        }

        let sortedKeys = insertionOrder.sorted { lhs, rhs in
            let lhsDate = groups[lhs]?.sortDate
            let rhsDate = groups[rhs]?.sortDate
            switch (lhsDate, rhsDate) {
            case let (l?, r?):
                return l > r
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            case (nil, nil):
                return false
            }
        }

        return sortedKeys.compactMap { key in
            guard let entry = groups[key] else { return nil }
            let title = entry.sortDate.map { format(date: $0) } ?? noDateTitle
            return LibrarySection(id: key, title: title, tracks: entry.tracks)
        }
    }

    // MARK: - Private types

    private struct GroupEntry {
        let sortDate: Date?
        var tracks: [LibraryTrack]
    }

    // MARK: - Private properties

    private static let noDateKey = "no-date"
    private static let noDateTitle = "Без даты"

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let calendar = Calendar(identifier: .gregorian)

    // MARK: - Private methods

    private static func key(for track: LibraryTrack) -> String {
        guard let date = track.libraryAddedDate else { return noDateKey }
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        return String(format: "%04d-%02d", year, month)
    }

    private static func sortDate(for track: LibraryTrack) -> Date? {
        guard let date = track.libraryAddedDate else { return nil }
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)
    }

    private static func format(date: Date) -> String {
        displayFormatter.string(from: date).capitalized
    }
}
