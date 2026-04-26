import Foundation

@MainActor
struct AppDependencies {

    // MARK: - Properties

    let appRouter: AppRouter
    let factories: ScreenFactories

    // MARK: - Public methods

    static func live() -> AppDependencies {
        let appRouter = AppRouter()
        let factories = ScreenFactories(
            homeFactory: HomeFactory(
                externalDeps: HomeExternalDeps(appRouter: appRouter)
            ),
            libraryFactory: LibraryFactory(
                externalDeps: LibraryExternalDeps(appRouter: appRouter)
            ),
            memoriesFactory: MemoriesFactory(
                externalDeps: MemoriesExternalDeps(appRouter: appRouter)
            )
        )

        return AppDependencies(
            appRouter: appRouter,
            factories: factories
        )
    }
}
