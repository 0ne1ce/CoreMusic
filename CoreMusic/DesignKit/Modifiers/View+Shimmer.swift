import SwiftUI

extension View {
    public func cmShimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [.clear, .shimmerColor, .clear],
                    startPoint: UnitPoint(x: phase, y: 0.5),
                    endPoint: UnitPoint(x: phase + Constants.gradientWidth, y: 0.5)
                )
            }
            .mask(content)
            .onAppear { startAnimating() }
    }

    // MARK: - Private types

    private enum Constants {
        static let gradientWidth: CGFloat = 1
        static let phaseStart: CGFloat = -1
        static let phaseEnd: CGFloat = 1
        static let duration: Double = 1.6
    }

    // MARK: - Private properties

    @State private var phase: CGFloat = Constants.phaseStart

    // MARK: - Private methods

    private func startAnimating() {
        phase = Constants.phaseStart
        withAnimation(.linear(duration: Constants.duration).repeatForever(autoreverses: false)) {
            phase = Constants.phaseEnd
        }
    }
}

extension Color {
    fileprivate static let shimmerColor = Color.cmBackgroundGlobal
}
