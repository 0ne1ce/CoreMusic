import SwiftUI

struct HomeView<ViewModel: HomeViewModel>: View {
    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.hasAnyContent {
                contentView
            }
            else {
                generalEmptyState
            }
        }
        .navigationTitle(viewModel.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.cmBackgroundPrimary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { viewModel.onProfileTap() } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.cmPrimaryLight)
                }
            }
        }
        .task { await viewModel.onAppear() }
        .onChange(of: appRouter.presentedCover) { _, newValue in
            if newValue == nil {
                Task { await viewModel.onAppear() }
            }
        }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel
    @Environment(AppRouter.self) private var appRouter

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                recentMemoriesSection
                recentTracksSection
                cityTourSection
                favoritesSection

                Rectangle()
                    .fill(.clear)
                    .frame(height: Layout.bottomSpacer)
            }
            .padding(.top, Spacing.sm)
        }
        .scrollContentBackground(.hidden)
    }

    private var recentMemoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: "Недавние воспоминания") {
                viewModel.onSectionTap(.recentMemories)
            }
            .padding(.horizontal, Spacing.lg)

            if viewModel.recentMemories.isEmpty {
                memoriesEmptyState
            }
            else {
                memoriesCarousel(
                    memories: viewModel.recentMemories,
                    section: .recentMemories
                )
            }
        }
    }

    @ViewBuilder
    private var recentTracksSection: some View {
        if viewModel.isLoadingTracks {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeaderView(title: "Недавно добавленные") {
                    viewModel.onSectionTap(.recentTracks)
                }
                .padding(.horizontal, Spacing.lg)

                tracksLoadingPlaceholder
            }
        }
        else if !viewModel.recentTracks.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeaderView(title: "Недавно добавленные") {
                    viewModel.onSectionTap(.recentTracks)
                }
                .padding(.horizontal, Spacing.lg)

                tracksPagedCarousel
            }
        }
    }

    private var tracksLoadingPlaceholder: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(0..<Layout.tracksPerPage, id: \.self) { _ in
                TrackCardSkeleton()
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private var cityTourSection: some View {
        if !viewModel.cityTourMemories.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeaderView(title: "Тур по городам") {
                    viewModel.onSectionTap(.cityTour)
                }
                .padding(.horizontal, Spacing.lg)

                cityTourCarousel(memories: viewModel.cityTourMemories)
            }
        }
    }

    private func cityTourCarousel(memories: [Memory]) -> some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: Spacing.md) {
                ForEach(memories) { memory in
                    Button {
                        viewModel.onMemoryTap(memory, in: .cityTour)
                    } label: {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            MemoryCardView(
                                memory: memory,
                                onFavoriteTap: { viewModel.onFavoriteTap(memory) }
                            )
                            .frame(width: Layout.memoryCardSize, height: Layout.memoryCardSize)

                            if let city = memory.locationName, !city.isEmpty {
                                MemoryTagView(text: city)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var favoritesSection: some View {
        if !viewModel.favoriteMemories.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeaderView(title: "Избранное") {
                    viewModel.onSectionTap(.favorites)
                }
                .padding(.horizontal, Spacing.lg)

                memoriesCarousel(
                    memories: viewModel.favoriteMemories,
                    section: .favorites
                )
            }
        }
    }

    private func memoriesCarousel(memories: [Memory], section: HomeSection) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.md) {
                ForEach(memories) { memory in
                    Button {
                        viewModel.onMemoryTap(memory, in: section)
                    } label: {
                        MemoryCardView(
                            memory: memory,
                            onFavoriteTap: { viewModel.onFavoriteTap(memory) }
                        )
                        .frame(width: Layout.memoryCardSize, height: Layout.memoryCardSize)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private var tracksPagedCarousel: some View {
        let pages = stride(from: 0, to: viewModel.recentTracks.count, by: Layout.tracksPerPage)
            .map { Array(viewModel.recentTracks[$0..<min($0 + Layout.tracksPerPage, viewModel.recentTracks.count)]) }

        return ScrollView(.horizontal) {
            HStack(spacing: Spacing.md) {
                ForEach(Array(pages.enumerated()), id: \.offset) { _, page in
                    trackPage(tracks: page)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, Spacing.lg + Spacing.sm)
        .padding(.leading, -Spacing.sm)
        .scrollIndicators(.hidden)
    }

    private func trackPage(tracks: [LibraryTrack]) -> some View {
        VStack(spacing: Spacing.sm) {
            ForEach(tracks) { track in
                Button {
                    Task { await viewModel.onTrackTap(track) }
                } label: {
                    TrackCardView(
                        model: TrackCardModel(
                            track: track,
                            playbackState: viewModel.playbackState(for: track.id)
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var memoriesEmptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(Color.cmTextSecondary)

            Text("Сохраните первый момент")
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: Layout.memoryCardSize)
    }

    private var generalEmptyState: some View {
        EmptyStateView(
            systemImage: "music.note.house",
            title: "Здесь пока пусто",
            subtitle: "Импортируйте треки и создайте первое воспоминание."
        )
    }
}

// MARK: - Private types

private enum Layout {
    static let memoryCardSize: CGFloat = 224
    static let tracksPerPage = 3
    static let bottomSpacer: CGFloat = 40
}
