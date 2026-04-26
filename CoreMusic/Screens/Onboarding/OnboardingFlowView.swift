import SwiftUI

struct OnboardingFlowView: View {
    let onFinish: () -> Void

    var body: some View {
        bodyContent
            .background(Color.cmBackgroundPrimary)
    }
    
    @State private var showingSlides = false
    private let logoSize: CGFloat = 180

    @ViewBuilder
    private var bodyContent: some View {
        if showingSlides {
            OnboardingSlidesView(onFinish: onFinish)
        }
        else {
            welcomeScreen
        }
    }

    private var welcomeScreen: some View {
        VStack(alignment: .center, spacing: Spacing.xxl) {
            Text("Добро пожаловать в CoreMusic")
                .font(.cmScreenTitle)
                .foregroundStyle(Color.cmTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)

            Spacer()

            Image.cmLogo
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: logoSize, height: logoSize)
                .foregroundStyle(Color.cmTextPrimary)

            Spacer()
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: Spacing.xs) {
                Button("Онбординг") {
                    withAnimation(.easeInOut(duration: 0.15)) { showingSlides = true }
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Пропустить", action: onFinish)
                    .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
        }
    }
}
