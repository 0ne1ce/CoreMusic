import SwiftUI

struct MemoriesView<ViewModel: MemoriesViewModel>: View {
    // MARK: - Body

    var body: some View {
        contentView
            .navigationTitle(viewModel.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.cmBackgroundPrimary)
            .onAppear {
                viewModel.onAppear()
            }
            // @0ne1ce: trick to update memories after deletion of memory in CreateMemoryScreen
            .onChange(of: appRouter.presentedCover) { _, newValue in
                if newValue == nil {
                    viewModel.onAppear()
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

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    // MARK: - Private methods

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            memoriesLoadingPlaceholder
        }
        else if let errorMessage = viewModel.errorMessage {
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: "Что-то пошло не так",
                subtitle: errorMessage,
                actionTitle: "Повторить",
                action: viewModel.retry
            )
        }
        else if viewModel.memories.isEmpty {
            EmptyStateView(
                systemImage: "sparkles.rectangle.stack",
                title: "Пока нет воспоминаний",
                subtitle: "Сохрани первый момент, связанный с любимым треком."
            )
        }
        else {
            memoriesGridView
        }
    }

    private var memoriesLoadingPlaceholder: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(0..<Layout.skeletonCount, id: \.self) { _ in
                MemoryCardSkeleton()
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
    }

    private var memoriesGridView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                SearchTextField(text: Binding(
                    get: { viewModel.searchInput },
                    set: { viewModel.searchInput = $0 }
                ))
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)

                if viewModel.displayedMemories.isEmpty {
                    EmptyStateView(systemImage: "magnifyingglass", title: "Ничего не найдено", subtitle: "Попробуйте изменить запрос")
                }
                else {
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(Array(viewModel.displayedMemories.enumerated()), id: \.offset) { index, memory in
                        Button {
                            viewModel.onMemoryTap(memory)
                        } label: {
                            MemoryCardView(
                                memory: memory,
                                onFavoriteTap: { viewModel.onFavoriteTap(memory) }
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                viewModel.onFavoriteTap(memory)
                            } label: {
                                Label(
                                    memory.isFavorite ? "Убрать из избранного" : "В избранное",
                                    systemImage: memory.isFavorite ? "heart.slash" : "heart"
                                )
                            }

                            Button(role: .destructive) {
                                viewModel.onDeleteTap(memory)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                        .zIndex(Double(index))
                    }
                }
                .padding(.horizontal, Spacing.lg)
                }

                // @0ne1ce: adding extra space in the bottom of ScrollView, because mini player isn't in .safeAreaInset(.bottom, ...)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 80)
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(Color.cmBackgroundPrimary)
    }
}

// MARK: - Private types

private enum Layout {
    static let skeletonCount = 6
}
