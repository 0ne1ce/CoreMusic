import SwiftUI

struct OnboardingSlidesView: View {
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Slide.allCases) { slide in
                    slideView(for: slide)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            }
            .frame(
                width: geo.size.width * CGFloat(slideCount),
                height: geo.size.height,
                alignment: .leading
            )
            .offset(x: -CGFloat(slideIndex) * geo.size.width)
            .animation(.easeInOut(duration: 0.5), value: slideIndex)
        }
        .clipped()
        .safeAreaInset(edge: .bottom) {
            bottomElements
        }
    }
    
    private enum Slide: String, CaseIterable, Identifiable {
        case first
        case second
        case third
        
        // @0ne1ce: for Identifiable conformance, so we can use slide easily in ForEach above
        var id: String { self.rawValue }
        
        var title: String {
            switch self {
            case .first:
                "Создавайте воспоминание для трека по свайпу"
            case .second:
                "Прослушивайте свои воспоминания"
            case .third:
                "Добавляйте лучшие моменты из жизни в избранное"
            }
        }
    }
    
    @State private var slideIndex: Int = 0
    @State private var didSwipeTrack: Bool = false

    private let slideCount = 3

    @ViewBuilder
    private func slideView(for slide: Slide) -> some View {
        ScrollView {
            VStack(spacing: 64) {
                slideTitle(slide.title)
                
                slideContent(for: slide)
            }
            .padding(.top, Spacing.md)
        }
        .padding(.top, Spacing.md)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func slideTitle(_ title: String) -> some View {
        Text(title)
            .font(.cmScreenTitle)
            .foregroundStyle(Color.cmTextPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private func slideContent(for slide: Slide) -> some View {
        switch slide {
        case .first:
            OnboardingFirstSlideView(onSwipeTrack: { didSwipeTrack = true })
        case .second:
            OnboardingSecondSlideView()
        case .third:
            OnboardingThirdSlideView()
        }
    }

    private var bottomElements: some View {
        VStack(spacing: Spacing.lg) {
            PageIndicator(count: slideCount, currentIndex: slideIndex)

            Button("Продолжить", action: nextStepOfOnboarding)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!didSwipeTrack)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    private func nextStepOfOnboarding() {
        if slideIndex < slideCount - 1 {
            slideIndex += 1
        } else {
            onFinish()
        }
    }
}
