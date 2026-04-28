import SwiftUI

struct HomeView<ViewModel: HomeViewModel>: View {
    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()
            
            EmptyStateView(
                systemImage: "memories",
                title: "Здесь пока пусто. Продолжайте добовлять воспоминания!"
            )
            
            Spacer()
        }
        .navigationTitle(viewModel.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.lg)
        .background(Color.cmBackgroundPrimary)
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel
}
