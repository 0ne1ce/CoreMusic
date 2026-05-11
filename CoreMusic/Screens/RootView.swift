import SwiftUI

struct RootView: View {
    // MARK: - Properties

    let factories: RootScreenFactories
    let createMemoryFactory: CreateMemoryFactory
    let trackPlayerFactory: TrackPlayerFactory
    let memoryCarouselFactory: MemoryCarouselFactory
    let authFactory: AuthFactory

    // MARK: - Body

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingFlowView(onFinish: { hasCompletedOnboarding = true })
        }
        else {
            MainTabView(
                factories: factories,
                createMemoryFactory: createMemoryFactory,
                trackPlayerFactory: trackPlayerFactory,
                memoryCarouselFactory: memoryCarouselFactory,
                authFactory: authFactory
            )
        }
    }

    // MARK: - Private properties

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
}
