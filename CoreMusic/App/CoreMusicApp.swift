import SwiftUI

@main
struct CoreMusicApp: App {

    // MARK: - Properties

    @State private var deps = AppDependencies.live()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView(factories: deps.factories)
                .environment(deps.appRouter)
            // TODO: add new services, for example:
            // .environment(deps.musicService)
            // .environment(deps.playerService)
        }
    }
}
