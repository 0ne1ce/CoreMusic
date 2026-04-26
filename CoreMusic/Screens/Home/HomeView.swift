import SwiftUI

struct HomeView<ViewModel: HomeViewModel>: View {
    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(viewModel.title)
                .font(.cmScreenTitle)
                .foregroundStyle(Color.cmTextPrimary)
            
            Spacer()
        }
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
