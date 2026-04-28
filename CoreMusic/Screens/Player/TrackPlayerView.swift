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
                        .background(Color.cmPrimarySecondary.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .background(Color.cmBackgroundPrimary)
        .onAppear {
            progressValue = viewModel.playbackTime
        }
        .onChange(of: viewModel.playbackTime) { _, newValue in
            guard !isEditingProgress else {
                return
            }

            progressValue = newValue
        }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties
    
    @StateObject private var viewModel: ViewModel
    @State private var progressValue: TimeInterval = 0
    @State private var isEditingProgress = false

    private var remainingTime: TimeInterval {
        max(viewModel.duration - progressValue, 0)
    }

    // MARK: - Private view properties and methods

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
            Slider(
                value: Binding(
                    get: { progressValue },
                    set: { progressValue = $0 }
                ),
                in: 0...max(viewModel.duration, 1),
                onEditingChanged: handleProgressEditingChanged
            )
            .tint(Color.cmTextPrimary.opacity(0.65))

            progressTimeView
        }
    }
    
    private var progressTimeView: some View {
        HStack {
            Text(format(time: progressValue))
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
            .buttonStyle(.plain)
            .foregroundStyle(Color.cmTextPrimary)

            Button(action: handlePlaybackToggleTap) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: Layout.primaryControlSize, weight: .bold))
                    .frame(width: Layout.primaryHitArea, height: Layout.primaryHitArea)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.cmTextPrimary)

            Button(action: handleSkipForwardTap) {
                Image(systemName: "forward.fill")
                    .font(.system(size: Layout.secondaryControlSize, weight: .bold))
            }
            .buttonStyle(.plain)
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
        isEditingProgress = isEditing

        guard !isEditing else {
            return
        }

        viewModel.onSeek(to: progressValue)
    }

    private func format(time: TimeInterval) -> String {
        let totalSeconds = max(Int(time.rounded()), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
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
}

#Preview {
    TrackPlayerView(viewModel: TrackPlayerViewModelImpl(router: TrackPlayerRouterImpl(appRouter: AppRouter()), playerService: PlayerServiceImpl(musicService: MockMusicService())))
}
