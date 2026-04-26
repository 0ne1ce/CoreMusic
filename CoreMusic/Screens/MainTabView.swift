import SwiftUI

struct MainTabView: View {
    // MARK: - Properties

    let factories: ScreenFactories

    // MARK: - Body

    var body: some View {
        @Bindable var appRouter = appRouter

        TabView(selection: $appRouter.selectedTab) {
            tabStack(path: $appRouter.homePath) { factories.homeFactory.makeHomeScreen() }
                .tabItem { Label("Главная", systemImage: "house") }
                .tag(AppRouter.Tab.home)

            tabStack(path: $appRouter.libraryPath) { factories.libraryFactory.makeLibraryScreen() }
                .tabItem { Label("Медиатека", systemImage: "music.note.list") }
                .tag(AppRouter.Tab.library)

            tabStack(path: $appRouter.memoriesPath) { factories.memoriesFactory.makeMemoriesScreen() }
                .tabItem { Label("Воспоминания", systemImage: "greetingcard") }
                .tag(AppRouter.Tab.memories)
        }
        .fullScreenCover(item: $appRouter.presentedCover) { cover in
            NavigationStack(path: $appRouter.coverPath) {
                coverRoot(for: cover)
                    .navigationDestination(for: AppPushRoute.self) { route in
                        destination(for: route)
                    }
            }
        }
    }
    
    // MARK: - Private properties
    
    @Environment(AppRouter.self) private var appRouter

    // MARK: - Private methods

    @ViewBuilder
    private func tabStack<Content: View>(
        path: Binding<NavigationPath>,
        @ViewBuilder root: () -> Content
    ) -> some View {
        NavigationStack(path: path) {
            root()
                .navigationDestination(for: AppPushRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: AppPushRoute) -> some View {
        switch route {
        case let .createMemory(songID):
            let createMemoryFactory = factories.makeCreateMemoryFactory(songID: songID, appRouter: appRouter)
            createMemoryFactory.makeCreateMemoryScreen(songID: songID)
        }
    }

    @ViewBuilder
    private func coverRoot(for cover: AppCover) -> some View {
        switch cover {
        case let .createMemory(songID):
            let createMemoryFactory = factories.makeCreateMemoryFactory(songID: songID, appRouter: appRouter)
            createMemoryFactory.makeCreateMemoryScreen(songID: songID)
        case let .player(songID):
            Text("TODO Player: \(songID)")
        }
    }
}
