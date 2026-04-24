import SwiftUI

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<count, id: \.self) { pageIndex in
                Capsule()
                    .fill(pageIndex == currentIndex 
                          ? Color.cmPrimarySecondary
                          : Color.cmTextSecondary
                    )
                    .frame(
                        width: pageIndex == currentIndex ? currentIndexWidth : indexSize,
                        height: indexSize
                    )
            }
        }
        .animation(.easeOut(duration: 0.3), value: currentIndex)
    }
    
    private let indexSize: Double = 6
    private let currentIndexWidth: Double = 28
}

#Preview {
    VStack(spacing: Spacing.lg) {
        PageIndicator(count: 3, currentIndex: 0)
        PageIndicator(count: 3, currentIndex: 1)
        PageIndicator(count: 3, currentIndex: 2)
    }
    .padding()
}
