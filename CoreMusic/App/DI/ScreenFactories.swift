import Foundation

@MainActor
struct ScreenFactories {

    // MARK: - Properties

    let homeFactory: HomeFactory
    let libraryFactory: LibraryFactory
    let memoriesFactory: MemoriesFactory

    // MARK: - Methods

    func makeCreateMemoryFactory(songID: String, appRouter: AppRouter) -> CreateMemoryFactory {
        CreateMemoryFactory(externalDeps: CreateMemoryExternalDeps(appRouter: appRouter))
    }
}
