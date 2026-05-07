import SwiftUI

struct AnimatedMeshGradient: View {
    // MARK: - Properties

    let primary: Color
    let secondary: Color

    // MARK: - Body

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = Float(context.date.timeIntervalSince(startDate))
            let phase = elapsed * Constants.angularRate

            MeshGradient(
                width: Constants.gridSize,
                height: Constants.gridSize,
                points: meshPoints(phase: phase),
                colors: meshColors
            )
        }
    }

    // MARK: - Private types

    private enum Constants {
        static let cycleDuration: Float = 8
        static let gridSize: Int = 3
        static let amplitude: Float = 0.15
        static let amplitudeSmall: Float = 0.1
        static let angularRate: Float = 2 * .pi / cycleDuration
    }

    // MARK: - Private properties

    @State private var startDate = Date()

    private var meshColors: [Color] {
        [
            primary.opacity(0.85), secondary,             primary,
            secondary,             primary, secondary.opacity(0.15),
            primary.opacity(0.4),  secondary.opacity(0.1), primary.opacity(0.45)
        ]
    }

    // MARK: - Private methods

    private func meshPoints(phase: Float) -> [SIMD2<Float>] {
        [
            SIMD2(0, 0),
            SIMD2(0.5, 0),
            SIMD2(1, 0),

            SIMD2(0, 0.5),
            SIMD2(
                0.5 + Constants.amplitude * sin(phase),
                0.5 + Constants.amplitude * cos(phase * 0.7)
            ),
            SIMD2(1, 0.5 + Constants.amplitudeSmall * sin(phase * 1.3)),

            SIMD2(0, 1),
            SIMD2(0.5 + Constants.amplitudeSmall * cos(phase * 0.8), 1),
            SIMD2(1, 1)
        ]
    }
}

#Preview {
    AnimatedMeshGradient(primary: .cmPrimary, secondary: .cmPrimaryLight)
        .ignoresSafeArea()
}
