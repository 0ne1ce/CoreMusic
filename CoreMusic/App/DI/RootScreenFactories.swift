import Foundation

@MainActor
struct RootScreenFactories {
    let homeFactory: HomeFactory
    let libraryFactory: LibraryFactory
    let memoriesFactory: MemoriesFactory
}
