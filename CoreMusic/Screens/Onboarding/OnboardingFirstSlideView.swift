import SwiftUI

struct OnboardingFirstSlideView: View {
    let onSwipeTrack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Свайпните трек влево, чтобы продолжить")
                .font(.cmFootnote)
                .foregroundStyle(Color.cmTextSecondary)

            TrackCardView(
                model: .onboarding,
                onReveal: onSwipeTrack
            )
        }
        .padding(.horizontal, Spacing.lg)
    }
}

fileprivate extension TrackCardModel {
    static let onboarding = TrackCardModel(
        id: "onboarding-track-example",
        title: "Ваш трек",
        artist: "Ваш любимый артист",
        artworkURL: nil
    )
}
