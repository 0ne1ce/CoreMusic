import SwiftUI

struct CreateMemoryView<ViewModel: CreateMemoryViewModel>: View {
    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text(viewModel.title)
                .font(.cmScreenTitle)
                .foregroundStyle(Color.cmTextPrimary)

            Text(viewModel.songDescription)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cmBackgroundPrimary)
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { viewModel.onCloseTap() }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.cmTextPrimary)
                }
            }
        }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel
}
