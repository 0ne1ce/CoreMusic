import SwiftUI

struct OnboardingSecondSlideView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(Array(photos.enumerated()), id: \.offset) { _, photo in
                    photo
                        .resizable()
                        .scaledToFill()
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content.offset(x: phase.value * -120)
                        }
                        .containerRelativeFrame(.horizontal)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .scrollTargetLayout()
        }
        .safeAreaPadding(.horizontal, sidePeek)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: slideHeight)
    }

    private let photos: [Image] = [
        .cmOnboarding1,
        .cmOnboarding2,
        .cmOnboarding3
    ]

    private let sidePeek: CGFloat = Spacing.xl
    private let aspectRatio: CGFloat = 338 / 423
    private let slideHeight: CGFloat = 430
}
