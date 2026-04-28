import SwiftUI

struct PhotoGalleryView: View {
    // MARK: - Properties

    let image: UIImage
    let onClose: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            imageView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            closeButton
        }
        .statusBarHidden()
        .transition(.opacity)
    }

    // MARK: - Private properties

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    @GestureState private var magnifyBy: CGFloat = 1

    // MARK: - Private views

    private var imageView: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale * magnifyBy)
            .offset(offset)
            .gesture(magnificationGesture)
            .gesture(dragGesture)
            .onTapGesture(count: 2, perform: handleDoubleTap)
            .animation(.spring(response: 0.3), value: scale)
            .animation(.spring(response: 0.3), value: offset)
    }

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

    // MARK: - Private methods

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                let newScale = lastScale * value.magnification
                scale = max(Layout.minScale, min(newScale, Layout.maxScale))
                lastScale = scale
                clampOffset()

                if scale <= Layout.minScale {
                    resetTransform()
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
                clampOffset()
            }
    }

    private func handleDoubleTap() {
        if scale > 1 {
            resetTransform()
        }
        else {
            scale = Layout.doubleTapScale
            lastScale = scale
        }
    }

    private func resetTransform() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }

    private func clampOffset() {
        guard scale > 1 else {
            offset = .zero
            lastOffset = .zero
            return
        }

        let maxOffsetX = (scale - 1) * UIScreen.main.bounds.width / 2
        let maxOffsetY = (scale - 1) * UIScreen.main.bounds.height / 2

        offset.width = min(maxOffsetX, max(-maxOffsetX, offset.width))
        offset.height = min(maxOffsetY, max(-maxOffsetY, offset.height))
        lastOffset = offset
    }
}

// MARK: - Private types

private enum Layout {
    static let closeButtonSize: CGFloat = 32
    static let minScale: CGFloat = 1
    static let maxScale: CGFloat = 5
    static let doubleTapScale: CGFloat = 3
}
