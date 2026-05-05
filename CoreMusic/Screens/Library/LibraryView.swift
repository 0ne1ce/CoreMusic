import SwiftUI

struct LibraryView<ViewModel: LibraryViewModel>: View {
    // MARK: - Body

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.cmBackgroundPrimary)
            .task {
                await viewModel.onAppear()
            }
            .navigationTitle(viewModel.title)
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhaseChange(newPhase)
            }
    }
    // MARK: - Private properties and methods

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .requestingAuthorization, .loading:
            loadingView
        case .denied:
            deniedView
        case .empty:
            emptyView
        case let .error(message):
            errorView(message)
        case let .loaded(sections):
            loadedView(allSections: sections, displayed: viewModel.displayedSections)
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            Spacer()

            ProgressView()

            Text("Загружаем медиатеку…")
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.xl)
    }

    private var deniedView: some View {
        EmptyStateView(
            systemImage: "music.note.list",
            title: "Доступ к медиатеке запрещён",
            subtitle: "Откройте настройки и разрешите CoreMusic доступ к Apple Music.",
            actionTitle: "Открыть настройки",
            action: { viewModel.openSettings() }
        )
    }

    private var emptyView: some View {
        EmptyStateView(
            systemImage: "music.note",
            title: "Нет треков",
            subtitle: "Добавьте треки в Apple Music и вернитесь сюда."
        )
    }

    private func errorView(_ message: String) -> some View {
        EmptyStateView(
            systemImage: "exclamationmark.triangle",
            title: "Не удалось загрузить медиатеку",
            subtitle: message,
            actionTitle: "Повторить",
            action: { 
                Task { await viewModel.retry() }
            }
        )
    }

    private func loadedView(allSections: [LibrarySection], displayed: [LibrarySection]) -> some View {
        List {
            SearchTextField(text: Binding(
                get: { viewModel.searchInput },
                set: { viewModel.searchInput = $0 }
            ))
            .listRowInsets(EdgeInsets(
                top: Spacing.sm,
                leading: Spacing.lg,
                bottom: Spacing.sm,
                trailing: Spacing.lg
            ))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if displayed.isEmpty && !allSections.isEmpty {
                EmptyStateView(systemImage: "magnifyingglass", title: "Ничего не найдено", subtitle: "Попробуйте изменить запрос")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            else {
                displayedTracks(displayed)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(Color.cmBackgroundPrimary)
    }
    
    private func displayedTracks(_ displayed: [LibrarySection]) -> some View {
        ForEach(displayed) { section in
            sectionHeaderRow(section.title)

            ForEach(section.tracks) { track in
                Button(action: { handleTrackTap(track, sections: displayed) }) {
                    TrackCardView(
                        model: TrackCardModel(
                            track: track,
                            playbackState: viewModel.playbackState(for: track.id)
                        )
                    )
                }
                .buttonStyle(.plain)
                    .listRowInsets(
                        EdgeInsets(
                            top: Spacing.xs,
                            leading: Spacing.md,
                            bottom: .zero,
                            trailing: Spacing.md
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .contentShape(Rectangle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            viewModel.onTrackAddTap(track)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .labelStyle(.iconOnly)
                        .tint(Color.cmPrimaryLight)
                    }
            }
        }
    }

    private func sectionHeaderRow(_ title: String) -> some View {
        Text(title)
            .font(.cmSecondary.weight(.semibold))
            .foregroundStyle(Color.cmTextSecondary)
            .listRowInsets(EdgeInsets(top: 12, leading: 24, bottom: 0, trailing: 24))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            Task {
                await viewModel.onSceneDidBecomeActive()
            }
        case .inactive, .background:
            return
        @unknown default:
            return
        }
    }

    private func handleTrackTap(_ track: LibraryTrack, sections: [LibrarySection]) {
        let queueTracks = sections.flatMap(\.tracks)
        Task {
            await viewModel.onTrackTap(track, queueTracks: queueTracks)
        }
    }
}
