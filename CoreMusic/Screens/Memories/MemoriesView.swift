import SwiftUI

struct MemoriesView<ViewModel: MemoriesViewModel>: View {
    // MARK: - Properties

    @StateObject private var viewModel: ViewModel

    // MARK: - Body

    var body: some View {
        contentView
            .navigationTitle(viewModel.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.lg)
            .background(Color.cmBackgroundPrimary)
            .onAppear {
                viewModel.onAppear()
            }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
            List {
                ForEach(viewModel.memories) { memory in
                    MemoryListItemView(memory: memory)
                        .listRowInsets(
                            EdgeInsets(
                                top: Spacing.xs,
                                leading: .zero,
                                bottom: .zero,
                                trailing: .zero
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.onDeleteTap(memory)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                                    .tint(.danger)
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.cmBackgroundPrimary)
        }
    }
}
