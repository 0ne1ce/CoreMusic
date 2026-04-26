import SwiftUI

struct RootView: View {
    let factories: ScreenFactories

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView(factories: factories)
        }
        else {
            OnboardingFlowView(onFinish: { hasCompletedOnboarding = true })
        }
    }

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
}
