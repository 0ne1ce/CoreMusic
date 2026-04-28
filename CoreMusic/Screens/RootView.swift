import SwiftUI

struct RootView: View {
    // MARK: - Properties

    let factories: RootScreenFactories
    let createMemoryFactory: CreateMemoryFactory
    let trackPlayerFactory: TrackPlayerFactory
    let memoryCarouselFactory: MemoryCarouselFactory
    let playerService: PlayerServiceImpl

    // MARK: - Body

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView(
                factories: factories,
                createMemoryFactory: createMemoryFactory,
                trackPlayerFactory: trackPlayerFactory,
                memoryCarouselFactory: memoryCarouselFactory,
                playerService: playerService
            )
        }
        else {
            OnboardingFlowView(onFinish: { hasCompletedOnboarding = true })
        }
    }
    
    // MARK: - Private properties
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
}
