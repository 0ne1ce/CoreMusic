import SwiftUI

struct MemoriesView<ViewModel: MemoriesViewModel>: View {
    // MARK: - Properties

    @StateObject private var viewModel: ViewModel

    // MARK: - Body

    var body: some View {
        contentView
            .navigationTitle(viewModel.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.cmBackgroundPrimary)
            .onAppear {
                viewModel.onAppear()
            }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    // MARK: - Private methods

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
                .frame(maxWidth: .infinity)
            Spacer()
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

    private var memoriesGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(Array(viewModel.memories.enumerated()), id: \.offset) { index, memory in
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
            .padding(.top, Spacing.sm)
        }
        .scrollContentBackground(.hidden)
        .background(Color.cmBackgroundPrimary)
    }
}
