import FirebaseCore
import SwiftData
import SwiftUI

@main
struct CoreMusicApp: App {
    // MARK: - Internal types

    enum BootstrapState {
        case ready(AppDependencies)
        case failed(String)
    }

    // MARK: - Initializer

    init() {
        FirebaseApp.configure()
        _bootstrapState = State(initialValue: Self.makeBootstrapState())
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            switch bootstrapState {
            case let .ready(deps):
                RootView(
                    factories: deps.factories,
                    createMemoryFactory: deps.createMemoryFactory,
                    trackPlayerFactory: deps.trackPlayerFactory,
                    memoryCarouselFactory: deps.memoryCarouselFactory,
                    authFactory: deps.authFactory
                )
                .environment(deps.appRouter)
                .environmentObject(deps.playerService)
                .environmentObject(deps.authService)
                .modelContainer(deps.modelContainer)
            case let .failed(message):
                EmptyStateView(
                    systemImage: "exclamationmark.triangle",
                    title: "Не удалось запустить приложение",
                    subtitle: message
                )
                .background(Color.cmBackgroundPrimary)
            }
        }
    }

    // MARK: - Private properties

    @State private var bootstrapState: BootstrapState

    // MARK: - Private methods

    private static func makeBootstrapState() -> BootstrapState {
        do {
            return .ready(try AppDependencies.live())
        }
        catch {
            return .failed("Не удалось инициализировать локальное хранилище данных.")
        }
    }
}
