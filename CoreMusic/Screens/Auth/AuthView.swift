import AuthenticationServices
import SwiftUI

struct AuthView<ViewModel: AuthViewModel>: View {
    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Импортируйте\nсвою медиатеку")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.cmTextPrimary)

            Spacer()

            Image.cmAppleMusicLogo
                .resizable()
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .clipShape(RoundedRectangle(cornerRadius: Layout.iconCornerRadius))

            Spacer()
            Spacer()

            // TODO: Uncomment after adding Sign in with Apple capability
            // SignInWithAppleButton(
            //     .signIn,
            //     onRequest: { request in
            //         viewModel.prepareAppleRequest(request)
            //     },
            //     onCompletion: { result in
            //         Task { await viewModel.handleAppleResult(result) }
            //     }
            // )
            // .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            // .frame(height: Layout.buttonHeight)
            // .clipShape(RoundedRectangle(cornerRadius: Layout.buttonCornerRadius))
            // .padding(.horizontal, Spacing.lg)
            // .disabled(viewModel.isAuthenticating)
            stubSignInButton
                .padding(.horizontal, Spacing.lg)
                .disabled(viewModel.isAuthenticating)

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

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel
    @Environment(\.colorScheme) private var colorScheme

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

    // TODO: Remove stubSignInButton after adding SignInWithAppleButton
    private var stubSignInButton: some View {
        let isDark = colorScheme == .dark
        let background: Color = isDark ? .white : .black
        let foreground: Color = isDark ? .black : .white

        return Button {
            Task { await viewModel.signInStub() }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "applelogo")
                    .font(.system(size: 18, weight: .medium))
                Text("Sign in with Apple")
                    .font(.system(size: 19, weight: .medium))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonCornerRadius))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Layout

private enum Layout {
    static let iconSize: CGFloat = 192
    static let iconCornerRadius: CGFloat = 32
    static let buttonHeight: CGFloat = 52
    static let buttonCornerRadius: CGFloat = 14
}
