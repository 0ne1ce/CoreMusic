import Foundation

@MainActor
struct AppDependencies {

    // MARK: - Properties

    let appRouter: AppRouter
    let musicService: any MusicService
    let factories: ScreenFactories

    // MARK: - Public methods

    static func live() -> AppDependencies {
        let appRouter = AppRouter()
        let musicService: any MusicService = MusicServiceImpl()
        let factories = AppDependencies.makeFactories(
            appRouter: appRouter,
            musicService: musicService
        )

        return AppDependencies(
            appRouter: appRouter,
            musicService: musicService,
            factories: factories
        )
    }

    static func preview() -> AppDependencies {
        let appRouter = AppRouter()
        let musicService: any MusicService = MockMusicService()
        let factories = AppDependencies.makeFactories(
            appRouter: appRouter,
            musicService: musicService
        )

        return AppDependencies(
            appRouter: appRouter,
            musicService: musicService,
            factories: factories
        )
    }

    // MARK: - Private methods

    private static func makeFactories(
        appRouter: AppRouter,
        musicService: any MusicService
    ) -> ScreenFactories {
        ScreenFactories(
            homeFactory: HomeFactory(
                externalDeps: HomeExternalDeps(appRouter: appRouter)
            ),
            libraryFactory: LibraryFactory(
                externalDeps: LibraryExternalDeps(
                    appRouter: appRouter,
                    musicService: musicService
                )
            ),
            memoriesFactory: MemoriesFactory(
                externalDeps: MemoriesExternalDeps(appRouter: appRouter)
            )
        )
    }
}
