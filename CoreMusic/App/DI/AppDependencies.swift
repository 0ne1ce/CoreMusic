import Foundation
import SwiftData

@MainActor
struct AppDependencies {

    // MARK: - Properties

    let appRouter: AppRouter
    let modelContainer: ModelContainer
    let musicService: any MusicService
    let playerService: PlayerServiceImpl
    let memoryRepository: MemoryRepository
    let createMemoryFactory: CreateMemoryFactory
    let trackPlayerFactory: TrackPlayerFactory
    let memoryCarouselFactory: MemoryCarouselFactory
    let factories: RootScreenFactories

    // MARK: - Public methods

    static func live() throws -> AppDependencies {
        let appRouter = AppRouter()
        let modelContainer = try AppDependencies.makeModelContainer(isStoredInMemoryOnly: false)
        let musicService: any MusicService = MusicServiceImpl()
        let playerService = PlayerServiceImpl(musicService: musicService)
        let memoryRepository: MemoryRepository = SwiftDataMemoryRepository(modelContainer: modelContainer)
        let createMemoryFactory = CreateMemoryFactory(
            externalDeps: CreateMemoryExternalDeps(
                appRouter: appRouter,
                musicService: musicService,
                playerService: playerService,
                memoryRepository: memoryRepository
            )
        )
        let trackPlayerFactory = TrackPlayerFactory(
            externalDeps: TrackPlayerExternalDeps(
                appRouter: appRouter,
                playerService: playerService
            )
        )
        let memoryCarouselFactory = MemoryCarouselFactory(
            externalDeps: MemoryCarouselExternalDeps(
                appRouter: appRouter,
                memoryRepository: memoryRepository,
                playerService: playerService
            )
        )
        let factories = AppDependencies.makeFactories(
            appRouter: appRouter,
            musicService: musicService,
            playerService: playerService,
            memoryRepository: memoryRepository
        )

        return AppDependencies(
            appRouter: appRouter,
            modelContainer: modelContainer,
            musicService: musicService,
            playerService: playerService,
            memoryRepository: memoryRepository,
            createMemoryFactory: createMemoryFactory,
            trackPlayerFactory: trackPlayerFactory,
            memoryCarouselFactory: memoryCarouselFactory,
            factories: factories
        )
    }

    static func preview() throws -> AppDependencies {
        let appRouter = AppRouter()
        let modelContainer = try AppDependencies.makeModelContainer(isStoredInMemoryOnly: true)
        let musicService: any MusicService = MockMusicService()
        let playerService = PlayerServiceImpl(musicService: musicService)
        let memoryRepository: MemoryRepository = SwiftDataMemoryRepository(modelContainer: modelContainer)
        let createMemoryFactory = CreateMemoryFactory(
            externalDeps: CreateMemoryExternalDeps(
                appRouter: appRouter,
                musicService: musicService,
                playerService: playerService,
                memoryRepository: memoryRepository
            )
        )
        let trackPlayerFactory = TrackPlayerFactory(
            externalDeps: TrackPlayerExternalDeps(
                appRouter: appRouter,
                playerService: playerService
            )
        )
        let memoryCarouselFactory = MemoryCarouselFactory(
            externalDeps: MemoryCarouselExternalDeps(
                appRouter: appRouter,
                memoryRepository: memoryRepository,
                playerService: playerService
            )
        )
        let factories = AppDependencies.makeFactories(
            appRouter: appRouter,
            musicService: musicService,
            playerService: playerService,
            memoryRepository: memoryRepository
        )

        return AppDependencies(
            appRouter: appRouter,
            modelContainer: modelContainer,
            musicService: musicService,
            playerService: playerService,
            memoryRepository: memoryRepository,
            createMemoryFactory: createMemoryFactory,
            trackPlayerFactory: trackPlayerFactory,
            memoryCarouselFactory: memoryCarouselFactory,
            factories: factories
        )
    }

    // MARK: - Private methods

    private static func makeFactories(
        appRouter: AppRouter,
        musicService: any MusicService,
        playerService: PlayerServiceImpl,
        memoryRepository: MemoryRepository
    ) -> RootScreenFactories {
        RootScreenFactories(
            homeFactory: HomeFactory(
                externalDeps: HomeExternalDeps(
                    appRouter: appRouter,
                    musicService: musicService,
                    playerService: playerService,
                    memoryRepository: memoryRepository
                )
            ),
            libraryFactory: LibraryFactory(
                externalDeps: LibraryExternalDeps(
                    appRouter: appRouter,
                    musicService: musicService,
                    playerService: playerService
                )
            ),
            memoriesFactory: MemoriesFactory(
                externalDeps: MemoriesExternalDeps(
                    appRouter: appRouter,
                    memoryRepository: memoryRepository
                )
            )
        )
    }

    private static func makeModelContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(for: Memory.self, configurations: configuration)
    }
}
