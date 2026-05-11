import Combine
import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit

// MARK: - PhotoStorageStrategy

enum PhotoStorageStrategy {
    case firestoreBlob
    case firebaseStorage
}

// MARK: - FirebaseMemorySyncService

@MainActor
final class FirebaseMemorySyncService: MemorySyncService {

    // MARK: - Initializer

    init(
        authService: AuthServiceImpl,
        localRepository: MemoryRepository,
        photoStrategy: PhotoStorageStrategy = .firebaseStorage
    ) {
        self.authService = authService
        self.localRepository = localRepository
        self.photoStrategy = photoStrategy
        observeAuthState()
    }

    // MARK: - Methods

    func performFullSync() async {
        guard !isSyncing else { return }

        guard let uid = authService.currentUser?.id else { return }

        isSyncing = true
        defer { isSyncing = false }

        do {
            let remoteMemories = try await fetchRemoteMemories(uid: uid)
            let localMemories = try localRepository.fetchMemories()

            let remoteLookup = Dictionary(
                remoteMemories.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            let localLookup = Dictionary(
                localMemories.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )

            for local in localMemories where remoteLookup[local.id] == nil {
                await pushMemoryToRemote(local, uid: uid)
            }

            for remote in remoteMemories {
                if let local = localLookup[remote.id] {
                    await resolveConflict(local: local, remote: remote, uid: uid)
                }
                else {
                    await pullRemoteMemory(remote, uid: uid)
                }
            }
            NotificationCenter.default.post(name: .memorySyncDidComplete, object: nil)
        }
        catch {
            print("Full sync failed: \(error.localizedDescription)")
        }
    }

    func pushMemory(_ memory: Memory) async {
        guard let uid = authService.currentUser?.id else {
            return
        }

        await pushMemoryToRemote(memory, uid: uid)
    }

    func pushMemoryDeletion(memoryID: UUID) async {
        guard let uid = authService.currentUser?.id else {
            return
        }

        let docRef = memoriesCollection(uid: uid).document(memoryID.uuidString)

        do {
            try await docRef.delete()
        }
        catch {
            print("Firestore delete failed for \(memoryID): \(error.localizedDescription)")
        }

        if photoStrategy == .firebaseStorage {
            let photoRef = Storage.storage().reference()
                .child("users/\(uid)/memories/\(memoryID.uuidString)/photo.jpg")
            try? await photoRef.delete()
        }
    }

    // MARK: - Private properties

    private let authService: AuthServiceImpl
    private let localRepository: MemoryRepository
    private let photoStrategy: PhotoStorageStrategy
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var isSyncing = false

    // MARK: - Private methods

    private func observeAuthState() {
        authService.$authState
            .removeDuplicates()
            .sink { [weak self] state in
                guard let self else { return }
                if case .signedIn = state {
                    Task { @MainActor in
                        await self.performFullSync()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func memoriesCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("memories")
    }

    // MARK: - Remote fetch

    private func fetchRemoteMemories(uid: String) async throws -> [RemoteMemory] {
        let snapshot = try await memoriesCollection(uid: uid).getDocuments()
        return snapshot.documents.compactMap { RemoteMemory(document: $0) }
    }

    // MARK: - Push to remote

    private func pushMemoryToRemote(_ memory: Memory, uid: String) async {
        var storagePhotoURL: String? = memory.remotePhotoURL

        if photoStrategy == .firebaseStorage, let photoData = memory.photoData, memory.remotePhotoURL == nil {
            do {
                storagePhotoURL = try await uploadPhoto(memoryID: memory.id, photoData: photoData, uid: uid)
                memory.remotePhotoURL = storagePhotoURL
            }
            catch {
                print("Storage upload failed for \(memory.id): \(error)")
            }
        }
        else if photoStrategy == .firebaseStorage, memory.photoData != nil, memory.remotePhotoURL != nil {
            print("Photo already uploaded for \(memory.memoryTitle), reusing URL")
        }

        do {
            let data = remoteData(from: memory, storagePhotoURL: storagePhotoURL)
            try await memoriesCollection(uid: uid)
                .document(memory.id.uuidString)
                .setData(data)
        }
        catch {
            print("Firestore push failed for \(memory.id): \(error)")
        }
    }

    // MARK: - Pull from remote

    private func pullRemoteMemory(_ remote: RemoteMemory, uid: String) async {
        do {
            if let existing = try localRepository.fetchMemory(by: remote.id) {
                await updateLocalFromRemote(local: existing, remote: remote, uid: uid)
                return
            }

            let photoData = await resolvePhotoForPull(remote: remote, uid: uid)

            let draft = MemoryDraft(
                songID: remote.songID,
                songTitle: remote.songTitle,
                artistName: remote.artistName,
                trackArtworkURLString: remote.trackArtworkURLString,
                memoryTitle: remote.memoryTitle,
                note: remote.note,
                date: remote.date,
                locationName: remote.locationName,
                photoData: photoData,
                tags: remote.tagsStorage.split(separator: "|").map(String.init),
                isFavorite: remote.isFavorite,
                id: remote.id
            )

            let saved = try localRepository.saveMemory(draft)
            saved.createdAt = remote.createdAt
            saved.lastModifiedAt = remote.lastModifiedAt
            if photoData != nil {
                saved.remotePhotoURL = remote.photoURL
            }
        }
        catch {
            print("Pull failed for \(remote.id): \(error.localizedDescription)")
        }
    }

    private func resolvePhotoForPull(remote: RemoteMemory, uid: String) async -> Data? {
        if let blobData = remote.photoData { return blobData }

        if let photoURL = remote.photoURL {
            let storagePath = "users/\(uid)/memories/\(remote.id.uuidString)/photo.jpg"
            let data = await downloadPhotoFromStorage(path: storagePath)
            return data
        }

        return nil
    }

    // MARK: - Conflict resolution

    private func resolveConflict(local: Memory, remote: RemoteMemory, uid: String) async {
        if local.lastModifiedAt > remote.lastModifiedAt {
            await pushMemoryToRemote(local, uid: uid)
        }
        else if remote.lastModifiedAt > local.lastModifiedAt {
            await updateLocalFromRemote(local: local, remote: remote, uid: uid)
        }
    }

    private func updateLocalFromRemote(local: Memory, remote: RemoteMemory, uid: String) async {
        local.songID = remote.songID
        local.songTitle = remote.songTitle
        local.artistName = remote.artistName
        local.trackArtworkURLString = remote.trackArtworkURLString
        local.memoryTitle = remote.memoryTitle
        local.note = remote.note
        local.date = remote.date
        local.locationName = remote.locationName
        local.tagsStorage = remote.tagsStorage
        local.isFavorite = remote.isFavorite
        local.lastModifiedAt = remote.lastModifiedAt

        let photoData = await resolvePhotoForPull(remote: remote, uid: uid)
        local.photoData = photoData
        if photoData != nil {
            local.remotePhotoURL = remote.photoURL
        }
    }

    // MARK: - Photo upload / download (Storage strategy)

    private func uploadPhoto(memoryID: UUID, photoData: Data, uid: String) async throws -> String {
        let compressed = UIImage.cm_compress(
            data: photoData,
            maxDimension: 1200,
            quality: 0.7
        ) ?? photoData

        let ref = Storage.storage().reference()
            .child("users/\(uid)/memories/\(memoryID.uuidString)/photo.jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(compressed, metadata: metadata)
        let downloadURL = try await ref.downloadURL()
        return downloadURL.absoluteString
    }

    private func downloadPhotoFromStorage(path: String) async -> Data? {
        let ref = Storage.storage().reference().child(path)
        do {
            let data = try await ref.data(maxSize: PhotoConstants.maxDownloadSize)
            guard UIImage(data: data) != nil else { return nil }
            return data
        }
        catch {
            print("Storage download failed for \(path): \(error)")
            return nil
        }
    }

    // MARK: - Firestore serialization

    private func remoteData(from memory: Memory, storagePhotoURL: String?) -> [String: Any] {
        var data: [String: Any] = [
            "id": memory.id.uuidString,
            "songID": memory.songID,
            "songTitle": memory.songTitle,
            "artistName": memory.artistName,
            "createdAt": Timestamp(date: memory.createdAt),
            "memoryTitle": memory.memoryTitle,
            "note": memory.note,
            "date": Timestamp(date: memory.date),
            "tagsStorage": memory.tagsStorage,
            "isFavorite": memory.isFavorite,
            "lastModifiedAt": Timestamp(date: memory.lastModifiedAt),
        ]

        if let trackArtworkURLString = memory.trackArtworkURLString {
            data["trackArtworkURLString"] = trackArtworkURLString
        }

        if let locationName = memory.locationName {
            data["locationName"] = locationName
        }

        switch photoStrategy {
        case .firestoreBlob:
            if let photoData = memory.photoData {
                let compressed = UIImage.cm_compress(
                    data: photoData,
                    maxDimension: 1200,
                    quality: 0.7
                ) ?? photoData
                data["photoData"] = compressed
            }

        case .firebaseStorage:
            if let storagePhotoURL {
                data["photoURL"] = storagePhotoURL
            }
        }

        return data
    }
}

// MARK: - Constants

private enum PhotoConstants {
    static let maxDownloadSize: Int64 = 5 * 1024 * 1024
}

// MARK: - RemoteMemory

private struct RemoteMemory {
    let id: UUID
    let songID: String
    let songTitle: String
    let artistName: String
    let trackArtworkURLString: String?
    let createdAt: Date
    let memoryTitle: String
    let note: String
    let date: Date
    let locationName: String?
    let tagsStorage: String
    let isFavorite: Bool
    let lastModifiedAt: Date
    let photoURL: String?
    let photoData: Data?

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let songID = data["songID"] as? String,
            let songTitle = data["songTitle"] as? String,
            let artistName = data["artistName"] as? String,
            let createdAtTimestamp = data["createdAt"] as? Timestamp,
            let memoryTitle = data["memoryTitle"] as? String,
            let note = data["note"] as? String,
            let dateTimestamp = data["date"] as? Timestamp,
            let tagsStorage = data["tagsStorage"] as? String,
            let isFavorite = data["isFavorite"] as? Bool,
            let lastModifiedAtTimestamp = data["lastModifiedAt"] as? Timestamp
        else {
            return nil
        }

        self.id = id
        self.songID = songID
        self.songTitle = songTitle
        self.artistName = artistName
        self.trackArtworkURLString = data["trackArtworkURLString"] as? String
        self.createdAt = createdAtTimestamp.dateValue()
        self.memoryTitle = memoryTitle
        self.note = note
        self.date = dateTimestamp.dateValue()
        self.locationName = data["locationName"] as? String
        self.tagsStorage = tagsStorage
        self.isFavorite = isFavorite
        self.lastModifiedAt = lastModifiedAtTimestamp.dateValue()
        self.photoURL = data["photoURL"] as? String
        self.photoData = data["photoData"] as? Data
    }
}
