import SwiftUI

struct OnboardingThirdSlideView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image.cmOnboarding4
                .resizable()
                .scaledToFit()
            
            memoryTitle
        }
        .overlay(alignment: .topTrailing) {
            FavoriteButton(isFavorite: $isFavorite, onTap: {})
                .padding(.top, Spacing.lg)
                .padding(.trailing, Spacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(height: 282)
        .padding(.horizontal, Spacing.md)
    }
    
    @State private var isFavorite = false

    private var memoryTitle: some View {
        Text("Поход")
            .font(.cmCallout)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .background(.ultraThinMaterial)

    }
}
