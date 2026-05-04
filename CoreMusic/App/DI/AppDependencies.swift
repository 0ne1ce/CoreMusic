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
    let authService: AuthServiceImpl
    let createMemoryFactory: CreateMemoryFactory
    let trackPlayerFactory: TrackPlayerFactory
    let memoryCarouselFactory: MemoryCarouselFactory
    let authFactory: AuthFactory
    let factories: RootScreenFactories

    // MARK: - Public methods

    static func live() throws -> AppDependencies {
        let appRouter = AppRouter()
        let modelContainer = try AppDependencies.makeModelContainer(isStoredInMemoryOnly: false)
        let musicService: any MusicService = MusicServiceImpl()
        let playerService = PlayerServiceImpl(musicService: musicService)
        let memoryRepository: MemoryRepository = SwiftDataMemoryRepository(modelContainer: modelContainer)
        let authService = AuthServiceImpl()
        // TODO: Uncomment after adding Sign in with Apple capability
        // authService.startListening()
        let makeLocationSearchService: @MainActor () -> LocationSearchService = {
            LocationSearchServiceImpl()
        }
        let createMemoryFactory = CreateMemoryFactory(
            externalDeps: CreateMemoryExternalDeps(
                appRouter: appRouter,
                musicService: musicService,
                playerService: playerService,
                memoryRepository: memoryRepository,
                makeLocationSearchService: makeLocationSearchService
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
        let authFactory = AuthFactory(
            externalDeps: AuthExternalDeps(authService: authService)
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
            authService: authService,
            createMemoryFactory: createMemoryFactory,
            trackPlayerFactory: trackPlayerFactory,
            memoryCarouselFactory: memoryCarouselFactory,
            authFactory: authFactory,
            factories: factories
        )
    }

    static func preview() throws -> AppDependencies {
        let appRouter = AppRouter()
        let modelContainer = try AppDependencies.makeModelContainer(isStoredInMemoryOnly: true)
        let musicService: any MusicService = MockMusicService()
        let playerService = PlayerServiceImpl(musicService: musicService)
        let memoryRepository: MemoryRepository = SwiftDataMemoryRepository(modelContainer: modelContainer)
        let authService = AuthServiceImpl()
        let makeLocationSearchService: @MainActor () -> LocationSearchService = {
            MockLocationSearchService()
        }
        let createMemoryFactory = CreateMemoryFactory(
            externalDeps: CreateMemoryExternalDeps(
                appRouter: appRouter,
                musicService: musicService,
                playerService: playerService,
                memoryRepository: memoryRepository,
                makeLocationSearchService: makeLocationSearchService
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
        let authFactory = AuthFactory(
            externalDeps: AuthExternalDeps(authService: authService)
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
            authService: authService,
            createMemoryFactory: createMemoryFactory,
            trackPlayerFactory: trackPlayerFactory,
            memoryCarouselFactory: memoryCarouselFactory,
            authFactory: authFactory,
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
