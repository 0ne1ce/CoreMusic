import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image.cmLogo
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(height: 120)
                .foregroundStyle(Color.cmTextPrimary)


            Text("Воспоминания")
                .font(.cmScreenTitle)
                .foregroundStyle(Color.cmPrimary)

            Text("Тестовый тест")
                .font(.cmSecondary)
                .foregroundStyle(Color.cmTextSecondary)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cmBackgroundPrimary)
    }
}

#Preview {
    ContentView()
}
