import SwiftUI
import SwiftData

@main
struct CoreMusicApp: App {
    // MARK: - Internal types

    enum BootstrapState {
        case ready(AppDependencies)
        case failed(String)
    }

    // MARK: - Properties

    @State private var bootstrapState = CoreMusicApp.makeBootstrapState()

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
                    playerService: deps.playerService
                )
                .environment(deps.appRouter)
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
