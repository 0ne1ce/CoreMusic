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
                interactionMode: .swipeReveal(onReveal: onSwipeTrack)
            )
        }
        .padding(.horizontal, Spacing.lg)
    }
}

fileprivate extension TrackCardModel {
    static let onboarding = TrackCardModel(
        track: LibraryTrack(
            id: "onboarding-track-example",
            title: "Ваш трек",
            artistName: "Ваш любимый артист",
            artwork: nil,
            artworkURL: nil,
            libraryAddedDate: nil,
            durationSeconds: nil
        )
    )
}
