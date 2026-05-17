import MusicKit
import SwiftUI

struct TrackPlayerView<ViewModel: TrackPlayerViewModel>: View {
    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Spacing.xl) {
                artworkCardView(geometry: geometry)

                VStack(spacing: Spacing.xl) {
                    trackMetaView
                    progressSectionView
                    controlsView
                    Spacer()
                    createMemoryButton
                }
                .frame(maxWidth: Layout.contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.onCloseTap) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.cmTextPrimary)
                        .frame(width: Layout.closeButtonSize, height: Layout.closeButtonSize)
                        .background(Color.cmPrimaryLight.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .background { backgroundView }
        .onChange(of: viewModel.currentTrack?.id) { _, _ in
            isEditingProgress = false
            progressValue = 0
        }
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties
    
    @StateObject private var viewModel: ViewModel
    @State private var progressValue: TimeInterval = 0
    @State private var isEditingProgress = false

    private var displayedTime: TimeInterval {
        isEditingProgress ? progressValue : viewModel.playbackTime
    }

    private var remainingTime: TimeInterval {
        max(viewModel.duration - displayedTime, 0)
    }

    // MARK: - Private view properties and methods

    private var backgroundView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let track = viewModel.currentTrack {
                BlurredArtworkOverlay(track: track)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            Color.black
                .opacity(Layout.dimOpacity)
                .ignoresSafeArea()
        }
    }

    private func artworkCardView(geometry: GeometryProxy) -> some View {
        Group {
            if let track = viewModel.currentTrack {
                TrackArtworkView(
                    track: track,
                    size: min(geometry.size.width, Layout.maxArtworkSize)
                )
            }
            else {
                RoundedRectangle(cornerRadius: Layout.artworkCornerRadius)
                    .fill(Color.cmBackgroundLight)
                    .frame(height: min(geometry.size.width, Layout.maxArtworkSize))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: min(geometry.size.width, Layout.maxArtworkSize))
        .clipShape(RoundedRectangle(cornerRadius: Layout.artworkCornerRadius))
        .padding(.top, -Layout.artworkTopInset)
    }

    private var trackMetaView: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(viewModel.currentTrack?.title ?? "Неизвестный трек")
                .font(.cmMemoryTitle)
                .foregroundStyle(Color.cmTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.currentTrack?.artistName ?? "Неизвестный артист")
                .font(.cmSubtitle)
                .foregroundStyle(Color.cmTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var progressSectionView: some View {
        VStack(spacing: Spacing.xs) {
            PlaybackSlider(
                value: Binding(
                    get: { displayedTime },
                    set: { progressValue = $0 }
                ),
                bounds: 0...max(viewModel.duration, 1),
                tint: Color.cmTextPrimary.opacity(0.65),
                onEditingChanged: handleProgressEditingChanged
            )
            .frame(height: Layout.sliderHeight)

            progressTimeView
        }
    }

    private var progressTimeView: some View {
        HStack {
            Text(format(time: displayedTime))
                .font(.cmMeta)
                .foregroundStyle(Color.cmTextSecondary)

            Spacer()

            Text("-\(format(time: remainingTime))")
                .font(.cmMeta)
                .foregroundStyle(Color.cmTextSecondary)
        }
    }

    private var controlsView: some View {
        HStack(spacing: Layout.controlsSpacing) {
            Button(action: handleSkipBackwardTap) {
                Image(systemName: "backward.fill")
                    .font(.system(size: Layout.secondaryControlSize, weight: .bold))
            }
            .buttonStyle(PlayerControlButtonStyle())
            .foregroundStyle(Color.cmTextPrimary)

            Button(action: handlePlaybackToggleTap) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: Layout.primaryControlSize, weight: .bold))
                    .frame(width: Layout.primaryHitArea, height: Layout.primaryHitArea)
            }
            .buttonStyle(PlayerControlButtonStyle())
            .foregroundStyle(Color.cmTextPrimary)

            Button(action: handleSkipForwardTap) {
                Image(systemName: "forward.fill")
                    .font(.system(size: Layout.secondaryControlSize, weight: .bold))
            }
            .buttonStyle(PlayerControlButtonStyle())
            .foregroundStyle(Color.cmTextPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var createMemoryButton: some View {
        Button(action: { viewModel.onCreateMemoryTap() }) {
            Label("Создать воспоминание", systemImage: "plus")
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.currentTrack == nil)
    }

    private func handlePlaybackToggleTap() {
        Task {
            await viewModel.onPlaybackToggleTap()
        }
    }

    private func handleSkipBackwardTap() {
        Task {
            await viewModel.onSkipBackwardTap()
        }
    }

    private func handleSkipForwardTap() {
        Task {
            await viewModel.onSkipForwardTap()
        }
    }

    private func handleProgressEditingChanged(_ isEditing: Bool) {
        if isEditing {
            progressValue = viewModel.playbackTime
            isEditingProgress = true
        }
        else {
            viewModel.onSeek(to: progressValue)
            isEditingProgress = false
        }
    }

    private func format(time: TimeInterval) -> String {
        let totalSeconds = max(Int(time.rounded()), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct PlaybackSlider: UIViewRepresentable {
    @Binding var value: TimeInterval
    let bounds: ClosedRange<TimeInterval>
    let tint: Color
    let onEditingChanged: (Bool) -> Void

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
        slider.isContinuous = true
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.touchDown(_:)),
            for: .touchDown
        )
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.touchUp(_:)),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
        )
        return slider
    }

    func updateUIView(_ slider: UISlider, context: Context) {
        context.coordinator.parent = self
        slider.minimumTrackTintColor = UIColor(tint)
        slider.minimumValue = Float(bounds.lowerBound)
        slider.maximumValue = Float(bounds.upperBound)

        if !context.coordinator.isDragging {
            let newValue = Float(value)
            if abs(slider.value - newValue) > 0.01 {
                slider.setValue(newValue, animated: false)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject {
        var parent: PlaybackSlider
        var isDragging = false

        init(parent: PlaybackSlider) {
            self.parent = parent
        }

        @objc func valueChanged(_ slider: UISlider) {
            parent.value = TimeInterval(slider.value)
        }

        @objc func touchDown(_ slider: UISlider) {
            isDragging = true
            parent.onEditingChanged(true)
        }

        @objc func touchUp(_ slider: UISlider) {
            isDragging = false
            parent.onEditingChanged(false)
        }
    }
}

private struct PlayerControlButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.75

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

private struct BlurredArtworkOverlay: View {
    let track: LibraryTrack

    var body: some View {
        Group {
            if let artwork = track.artwork {
                ArtworkImage(
                    artwork,
                    width: Layout.blurredArtworkSize,
                    height: Layout.blurredArtworkSize
                )
            }
            else if let url = track.artworkURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
                .frame(width: Layout.blurredArtworkSize, height: Layout.blurredArtworkSize)
            }
        }
        .blur(radius: Layout.blurredArtworkBlur)
        .scaleEffect(Layout.blurredArtworkScale)
        .opacity(Layout.blurredArtworkOpacity)
        .allowsHitTesting(false)
    }
}

private enum Layout {
    static let maxArtworkSize: CGFloat = 520
    static let artworkTopInset: CGFloat = 18
    static let artworkCornerRadius: CGFloat = 20
    static let contentMaxWidth: CGFloat = 360
    static let controlsSpacing: CGFloat = 48
    static let primaryControlSize: CGFloat = 46
    static let secondaryControlSize: CGFloat = 30
    static let primaryHitArea: CGFloat = 72
    static let closeButtonSize: CGFloat = 52
    static let dimOpacity: CGFloat = 0.18
    static let blurredArtworkSize: CGFloat = 1024
    static let blurredArtworkBlur: CGFloat = 60
    static let blurredArtworkScale: CGFloat = 1.3
    static let blurredArtworkOpacity: CGFloat = 0.7
    static let sliderHeight: CGFloat = 30
}

#Preview {
    TrackPlayerView(viewModel: TrackPlayerViewModelImpl(
        router: TrackPlayerRouterImpl(appRouter: AppRouter()),
        playerService: PlayerServiceImpl(musicService: MockMusicService())
    ))
}
