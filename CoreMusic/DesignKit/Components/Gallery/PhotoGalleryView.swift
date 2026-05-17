import SwiftUI

struct PhotoGalleryView: View {
    // MARK: - Properties

    let image: UIImage
    let onClose: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            ZoomableImageView(image: image)
                .ignoresSafeArea()

            closeButton
        }
        .statusBarHidden()
        .transition(.opacity)
    }

    // MARK: - Private views

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: Layout.closeButtonSize, height: Layout.closeButtonSize)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .padding(.leading, Spacing.lg)
        .padding(.top, Spacing.sm)
    }
}

// MARK: - ZoomableImageView

private struct ZoomableImageView: View {
    let image: UIImage

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        magnifyGesture(in: size),
                        panGesture(in: size)
                    )
                )
                .onTapGesture(count: 2) { handleDoubleTap() }
        }
    }

    // MARK: - Gestures

    private func magnifyGesture(in size: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let proposed = lastScale * value.magnification
                scale = max(Layout.minScale, min(proposed, Layout.maxScale))
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= Layout.minScale {
                    resetTransform()
                }
                else {
                    clampAndCommit(in: size)
                }
            }
    }

    private func panGesture(in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > Layout.minScale else { return }
                let proposed = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                offset = clamp(offset: proposed, in: size)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    // MARK: - Helpers

    private func clamp(offset: CGSize, in size: CGSize) -> CGSize {
        let maxX = max(0, (size.width * (scale - 1)) / 2)
        let maxY = max(0, (size.height * (scale - 1)) / 2)
        return CGSize(
            width: min(maxX, max(-maxX, offset.width)),
            height: min(maxY, max(-maxY, offset.height))
        )
    }

    private func clampAndCommit(in size: CGSize) {
        let clamped = clamp(offset: offset, in: size)
        if clamped != offset {
            withAnimation(.spring(response: 0.3)) {
                offset = clamped
            }
        }
        lastOffset = clamped
    }

    private func resetTransform() {
        withAnimation(.spring(response: 0.3)) {
            scale = Layout.minScale
            offset = .zero
        }
        lastScale = Layout.minScale
        lastOffset = .zero
    }

    private func handleDoubleTap() {
        if scale > Layout.minScale {
            resetTransform()
        }
        else {
            withAnimation(.spring(response: 0.3)) {
                scale = Layout.doubleTapScale
            }
            lastScale = Layout.doubleTapScale
        }
    }
}

// MARK: - Private types

private enum Layout {
    static let closeButtonSize: CGFloat = 32
    static let minScale: CGFloat = 1
    static let maxScale: CGFloat = 5
    static let doubleTapScale: CGFloat = 3
}
