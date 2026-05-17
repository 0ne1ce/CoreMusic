import SwiftUI

struct MainTabView: View {
    // MARK: - Properties

    let factories: RootScreenFactories
    let createMemoryFactory: CreateMemoryFactory
    let trackPlayerFactory: TrackPlayerFactory
    let memoryCarouselFactory: MemoryCarouselFactory
    let authFactory: AuthFactory

    // MARK: - Body

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
            .tint(.cmPrimaryLight)

            MiniPlayerOverlay()
        }
        .ignoresSafeArea(.keyboard)
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

    // MARK: - Private properties

    @Environment(AppRouter.self) private var appRouter
    @EnvironmentObject private var authService: AuthServiceImpl
    @AppStorage("hasCompletedAuth") private var hasCompletedAuth = false

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
        EmptyView()
    }

    @ViewBuilder
    private func coverRoot(for cover: AppCover) -> some View {
        switch cover {
        case let .createMemory(songID):
            createMemoryFactory.makeCreateMemoryScreen(songID: songID)
        case let .editMemory(memoryID):
            createMemoryFactory.makeEditMemoryScreen(memoryID: memoryID)
        case .player:
            trackPlayerFactory.makeTrackPlayerScreen()
        case let .memoryCarousel(startMemoryID, memoryIDs):
            memoryCarouselFactory.makeMemoryCarouselScreen(startMemoryID: startMemoryID, memoryIDs: memoryIDs)
        case .auth:
            authFactory.makeAuthScreen(onSkip: handleAuthComplete)
                .onChange(of: authService.currentUser) { _, newUser in
                    if newUser != nil {
                        handleAuthComplete()
                    }
                }
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .player:
            trackPlayerFactory.makeTrackPlayerScreen()
        case let .profile(totalMemories, favoriteMemories, totalTracks):
            ProfileView(
                totalMemories: totalMemories,
                favoriteMemories: favoriteMemories,
                totalTracks: totalTracks
            )
        }
    }

    private func handleAuthComplete() {
        hasCompletedAuth = true
        appRouter.dismissCover()
    }
}

// MARK: - MiniPlayerOverlay

// @0ne1ce: Isolated subscriber to PlayerServiceImpl so the heavy `MainTabView` body
// is not re-evaluated on every playbackTime update.
private struct MiniPlayerOverlay: View {
    @EnvironmentObject private var playerService: PlayerServiceImpl
    @Environment(AppRouter.self) private var appRouter

    var body: some View {
        if let currentTrack = playerService.currentTrack {
            if playerService.currentQueue.count > 1 {
                SwipeableMiniPlayerView(
                    playerService: playerService,
                    onTap: handleTap
                )
                .padding(.bottom, Layout.miniPlayerBottomPadding)
            }
            else {
                MiniPlayerView(
                    track: currentTrack,
                    playerService: playerService,
                    onTap: handleTap
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Layout.miniPlayerBottomPadding)
            }
        }
    }

    private func handleTap() {
        guard let currentTrackID = playerService.currentTrackID else { return }
        appRouter.presentSheet(.player(songID: currentTrackID))
    }
}

private enum Layout {
    static let miniPlayerBottomPadding: CGFloat = 64
}
