import Foundation
import SwiftData

@Model
final class Memory {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var songID: String
    var songTitle: String
    var artistName: String
    var trackArtworkURLString: String?
    var createdAt: Date
    var memoryTitle: String
    var note: String
    var date: Date
    var locationName: String?
    var photoData: Data?
    var tagsStorage: String
    var isFavorite: Bool
    var lastModifiedAt: Date = Date()
    var remotePhotoURL: String?

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        songID: String,
        songTitle: String,
        artistName: String,
        trackArtworkURLString: String?,
        createdAt: Date = Date(),
        memoryTitle: String,
        note: String,
        date: Date,
        locationName: String?,
        photoData: Data?,
        tags: [String],
        isFavorite: Bool,
        lastModifiedAt: Date = Date(),
        remotePhotoURL: String? = nil
    ) {
        self.id = id
        self.songID = songID
        self.songTitle = songTitle
        self.artistName = artistName
        self.trackArtworkURLString = trackArtworkURLString
        self.createdAt = createdAt
        self.memoryTitle = memoryTitle
        self.note = note
        self.date = date
        self.locationName = locationName
        self.photoData = photoData
        self.tagsStorage = tags.joined(separator: "|")
        self.isFavorite = isFavorite
        self.lastModifiedAt = lastModifiedAt
        self.remotePhotoURL = remotePhotoURL
    }
}
