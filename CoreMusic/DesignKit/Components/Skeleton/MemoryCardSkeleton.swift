import SwiftUI

struct MemoryCardSkeleton: View {
    // MARK: - Body

    var body: some View {
        Color.cmBackgroundLight
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
            .cmShimmering()
    }
}

// MARK: - Private types

private enum Layout {
    static let cornerRadius: CGFloat = 20
}
