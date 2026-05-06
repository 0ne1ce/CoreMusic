import SwiftUI

struct TrackCardSkeleton: View {
    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.md) {
            artworkPlaceholder

            VStack(alignment: .leading, spacing: Layout.lineSpacing) {
                linePlaceholder(width: Layout.titleWidth, height: Layout.titleHeight)
                linePlaceholder(width: Layout.subtitleWidth, height: Layout.subtitleHeight)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Layout.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                .fill(Color.cmBackgroundLight)
        )
        .cmShimmering()
    }

    // MARK: - Private properties

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: Layout.artworkCornerRadius)
            .fill(Color.cmBackgroundGlobal.opacity(Layout.placeholderOpacity))
            .frame(width: Layout.artworkSize, height: Layout.artworkSize)
    }

    // MARK: - Private methods

    private func linePlaceholder(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Layout.lineCornerRadius)
            .fill(Color.cmBackgroundGlobal.opacity(Layout.placeholderOpacity))
            .frame(width: width, height: height)
    }
}

// MARK: - Private types

private enum Layout {
    static let cardHeight: CGFloat = 64
    static let cardCornerRadius: CGFloat = 12
    static let artworkSize: CGFloat = 44
    static let artworkCornerRadius: CGFloat = 8
    static let lineSpacing: CGFloat = 6
    static let lineCornerRadius: CGFloat = 4
    static let titleWidth: CGFloat = 160
    static let titleHeight: CGFloat = 12
    static let subtitleWidth: CGFloat = 100
    static let subtitleHeight: CGFloat = 10
    static let placeholderOpacity: CGFloat = 0.18
}
