import SwiftUI

@main
struct CoreMusicApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingFlowView(onFinish: { }) // TODO: route to main app and check for onboarding completion flag in db
        }
    }
}
