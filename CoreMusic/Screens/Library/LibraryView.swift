import SwiftUI

struct LibraryView<ViewModel: LibraryViewModel>: View {
    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(viewModel.title)
                .font(.cmScreenTitle)
                .foregroundStyle(Color.cmTextPrimary)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.lg)
        .background(Color.cmBackgroundPrimary)
        .task { await viewModel.onAppear() }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel

    // MARK: - Private View methods and properties

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .requestingAuthorization:
            statusTextView("Запрашиваем доступ к Apple Music…")
        case .loading:
            loadingView
        case .denied:
            deniedView
        case .empty:
            statusTextView("В Вашей медиатеке нет треков. Сначала нужно добавить треки в Apple Music.")
        case let .error(message):
            errorView(message)
        case let .loaded(sections):
            loadedSummaryView(sections)
        }
    }
    
    private var loadingView: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ProgressView()
            statusTextView("Загружаем медиатеку…")
        }
    }
    
    private var deniedView: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Доступ к медиатеке запрещён")
                .font(.cmCardTitle)
                .foregroundStyle(Color.cmTextPrimary)
            statusTextView("Откройте настройки и разрешите CoreMusic доступ к Apple Music.")
            Button("Открыть настройки") { viewModel.openSettings() }
                .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(message)
                .font(.cmCallout)
                .foregroundStyle(Color.cmDanger)
            Button("Повторить") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    @ViewBuilder
    private func loadedSummaryView(_ sections: [LibrarySection]) -> some View {
        let total = sections.reduce(0) { $0 + $1.tracks.count }

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                statusTextView("Загружено \(total) треков в \(sections.count) секциях")

                ForEach(sections) { section in
                    HStack {
                        Text(section.title)
                            .font(.cmCardTitle)
                            .foregroundStyle(Color.cmTextPrimary)
                        Spacer()
                        Text("\(section.tracks.count)")
                            .font(.cmFootnote)
                            .foregroundStyle(Color.cmTextSecondary)
                    }
                    .padding(.top, Spacing.xs)
                }
            }
        }
    }

    private func statusTextView(_ text: String) -> some View {
        Text(text)
            .font(.cmCallout)
            .foregroundStyle(Color.cmTextSecondary)
    }
}
