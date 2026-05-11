import AuthenticationServices
import SwiftUI

struct AuthView<ViewModel: AuthViewModel>: View {
    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.md) {
                Text("Войдите\nв аккаунт")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cmTextPrimary)

                Text("Чтобы сохранять воспоминания\nна разных устройствах")
                    .font(.cmBody)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cmTextSecondary)
            }

            Spacer()

            Image.cmLogo
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundStyle(Color.cmTextPrimary)

            Spacer()
            Spacer()

            VStack(spacing: Spacing.sm) {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        viewModel.prepareAppleRequest(request)
                    },
                    onCompletion: { result in
                        Task { await viewModel.handleAppleResult(result) }
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: Layout.buttonHeight)
                .clipShape(RoundedRectangle(cornerRadius: Layout.buttonCornerRadius))
                .disabled(viewModel.isAuthenticating)

                if let onSkip {
                    Button("Пропустить", action: onSkip)
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(viewModel.isAuthenticating)
                }
            }
            .padding(.horizontal, Spacing.lg)

            if viewModel.isAuthenticating {
                ProgressView()
                    .padding(.top, Spacing.md)
            }
        }
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cmBackgroundPrimary)
        .alert(
            "Ошибка входа",
            isPresented: errorBinding,
            actions: {
                Button("OK", role: .cancel) {
                    viewModel.dismissError()
                }
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }

    // MARK: - Initializer

    init(viewModel: ViewModel, onSkip: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSkip = onSkip
    }

    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel
    @Environment(\.colorScheme) private var colorScheme
    private let onSkip: (() -> Void)?

    // MARK: - Private methods

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }

}

// MARK: - Layout

private enum Layout {
    static let iconSize: CGFloat = 192
    static let iconCornerRadius: CGFloat = 32
    static let buttonHeight: CGFloat = 52
    static let buttonCornerRadius: CGFloat = 14
}
