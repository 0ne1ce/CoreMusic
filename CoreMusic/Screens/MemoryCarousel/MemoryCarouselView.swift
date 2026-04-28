import SwiftUI

struct MemoryCarouselView<ViewModel: MemoryCarouselViewModel>: View {
    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea() // TODO: MeshGradient?

            if viewModel.memories.isEmpty {
                EmptyStateView(
                    systemImage: "sparkles.rectangle.stack",
                    title: "Нет воспоминаний",
                    subtitle: "Все воспоминания были удалены."
                )
            }
            else {
                carouselView
                topBar
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties and methods

    @StateObject private var viewModel: ViewModel
    @State private var isScrollReady = false

    private var carouselView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: Layout.cardSpacing) {
                    ForEach(viewModel.memories) { memory in
                        cardView(for: memory)
                            .containerRelativeFrame(.horizontal)
                            .id(memory.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, Layout.sidePeek)
            .scrollPosition(id: $viewModel.currentMemoryID)
            .scrollIndicators(.hidden)
            .opacity(isScrollReady ? 1 : 0)
            .onAppear {
                guard let targetID = viewModel.currentMemoryID else {
                    isScrollReady = true
                    return
                }
                DispatchQueue.main.async {
                    proxy.scrollTo(targetID, anchor: .center)
                    isScrollReady = true
                }
            }
        }
    }

    private func cardView(for memory: Memory) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: Layout.topBarReserve)

            VStack(alignment: .leading, spacing: 0) {
                heroSection(for: memory)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    titleSection(for: memory)
                    trackSection(for: memory)

                    if !memory.note.isEmpty {
                        noteSection(for: memory)
                    }

                    tagsSection(for: memory)
                }
                .padding(Spacing.lg)

                Spacer(minLength: 0)
            }
            .background(
                RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                    .fill(Color.cmPrimarySecondary.opacity(0.15))
            )
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))

            Spacer()
                .frame(height: Layout.bottomPadding)
        }
    }

    private func heroSection(for memory: Memory) -> some View {
        let parallaxAmount = Layout.parallaxOffset

        return Color.clear
            .aspectRatio(Layout.photoAspectRatio, contentMode: .fit)
            .background { heroContent(for: memory, parallaxAmount: parallaxAmount) }
            .clipped()
    }

    @ViewBuilder
    private func heroContent(for memory: Memory, parallaxAmount: CGFloat) -> some View {
        if let uiImage = viewModel.heroImage(for: memory) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .scrollTransition(axis: .horizontal) { content, phase in
                    content.offset(x: phase.value * -parallaxAmount)
                }
        }
        else if let urlString = memory.trackArtworkURLString,
                let url = URL(string: urlString) {
            let placeholder = heroPlaceholder

            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content.offset(x: phase.value * -parallaxAmount)
                        }
                default:
                    placeholder
                }
            }
        }
        else {
            heroPlaceholder
        }
    }

    private var heroPlaceholder: some View {
        LinearGradient(
            colors: [Color.cmPrimarySecondary, Color.cmPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "music.note")
                .font(.system(size: Layout.placeholderIconSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private func titleSection(for memory: Memory) -> some View {
        HStack(alignment: .center) {
            Text(memory.memoryTitle)
                .font(.cmMemoryTitle)
                .foregroundStyle(.white)

            Spacer()

            FavoriteButton(
                isFavorite: .init(
                    get: { memory.isFavorite },
                    set: { _ in }
                ),
                onTap: { viewModel.onFavoriteTap(memory) }
            )
        }
    }

    private func trackSection(for memory: Memory) -> some View {
        Button {
            viewModel.onPlayTap(memory)
        } label: {
            TrackCardView(model: viewModel.trackCardModel(for: memory))
        }
        .buttonStyle(.plain)
    }

    private func noteSection(for memory: Memory) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.cmPrimarySecondary)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Заметка")
                    .font(.cmFootnote)
                    .foregroundStyle(.white.opacity(0.5))

                Text(memory.note)
                    .font(.cmBody)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(6)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func tagsSection(for memory: Memory) -> some View {
        let allTags = getTags(for: memory)

        return HStack(spacing: Spacing.sm) {
            ForEach(allTags, id: \.self) { tag in
                Text(tag)
                    .font(.cmFootnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs + 2)
                    .background(
                        Capsule().fill(.white.opacity(0.12))
                    )
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func getTags(for memory: Memory) -> [String] {
        var result: [String] = []

        if let location = memory.locationName, !location.isEmpty {
            result.append(location)
        }

        result.append(viewModel.formattedDate(for: memory))
        result.append(contentsOf: viewModel.tags(for: memory))

        return result
    }

    private var topBar: some View {
        HStack {
            Button { viewModel.onClose() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: Layout.closeButtonSize, height: Layout.closeButtonSize)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Spacer()

            Text("\(viewModel.currentIndex + 1) / \(viewModel.memories.count)")
                .font(.cmFootnote)
                .foregroundStyle(.white.opacity(0.7))
                .monospacedDigit()

            Spacer()

            Color.clear
                .frame(width: Layout.closeButtonSize, height: Layout.closeButtonSize)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }
}

// MARK: - Private types

private enum Layout {
    static let sidePeek: CGFloat = 24
    static let cardSpacing: CGFloat = 12
    static let cardCornerRadius: CGFloat = 24
    static let topBarReserve: CGFloat = 48
    static let bottomPadding: CGFloat = 16
    static let photoAspectRatio: CGFloat = 0.82
    static let parallaxOffset: CGFloat = 80
    static let placeholderIconSize: CGFloat = 48
    static let closeButtonSize: CGFloat = 32
}
