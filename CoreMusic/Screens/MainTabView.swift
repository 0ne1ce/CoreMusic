import SwiftUI

struct MainTabView: View {
    // MARK: - Properties

    let factories: RootScreenFactories
    let createMemoryFactory: CreateMemoryFactory
    let trackPlayerFactory: TrackPlayerFactory
    let memoryCarouselFactory: MemoryCarouselFactory
    @ObservedObject var playerService: PlayerServiceImpl
    
    @Environment(AppRouter.self) private var appRouter

    var body: some View {
        @Bindable var appRouter = appRouter

        ZStack(alignment: .bottom) {
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
            .tint(.cmPrimarySecondary)

            if let currentTrack = playerService.currentTrack {
                MiniPlayerView(
                    track: currentTrack,
                    playerService: playerService,
                    onTap: handleMiniPlayerTap
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Layout.miniPlayerBottomPadding)
            }
        }
        .fullScreenCover(item: $appRouter.presentedCover) { cover in
            NavigationStack(path: $appRouter.coverPath) {
                coverRoot(for: cover)
                    .navigationDestination(for: AppPushRoute.self) { route in
                        destination(for: route)
                    }
            }
        }
        .sheet(item: $appRouter.presentedSheet) { sheet in
            sheetView(for: sheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

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
            createMemoryFactory.makeCreateMemoryScreen(songID: songID)
        }
    }

    @ViewBuilder
    private func coverRoot(for cover: AppCover) -> some View {
        switch cover {
        case let .createMemory(songID):
            createMemoryFactory.makeCreateMemoryScreen(songID: songID)
        case .player:
            trackPlayerFactory.makeTrackPlayerScreen()
        case let .memoryCarousel(startMemoryID):
            memoryCarouselFactory.makeMemoryCarouselScreen(startMemoryID: startMemoryID)
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .player:
            trackPlayerFactory.makeTrackPlayerScreen()
        }
    }

    private func handleMiniPlayerTap() {
        guard let currentTrackID = playerService.currentTrackID else {
            return
        }

        appRouter.presentSheet(.player(songID: currentTrackID))
    }
}

private enum Layout {
    static let miniPlayerBottomPadding: CGFloat = 64
}
