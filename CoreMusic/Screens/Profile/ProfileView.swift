import SwiftUI

struct ProfileView: View {
    // MARK: - Properties

    let totalMemories: Int
    let favoriteMemories: Int
    let totalTracks: Int

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    avatarSection
                    statsSection
                    Spacer()
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xl)
            }
            .background(Color.cmBackgroundPrimary)
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.cmPrimaryLight)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: { }) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                        Text("Выйти из аккаунта")
                    }
                    .font(.cmBody.weight(.medium))
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Private properties

    @Environment(\.dismiss) private var dismiss
    @AppStorage("profile_name") private var profileName = "Меломан"
    @FocusState private var isNameFocused: Bool

    // MARK: - Private views

    private var avatarSection: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "person.crop.square.fill")
                .font(.system(size: Layout.avatarSize))
                .foregroundStyle(Color.cmPrimaryLight)
                .background(
                    RoundedRectangle(cornerRadius: Layout.avatarCornerRadius)
                        .fill(Color.cmPrimaryLight.opacity(0.15))
                        .frame(width: Layout.avatarBgSize, height: Layout.avatarBgSize)
                )

            TextField("Имя", text: $profileName)
                .font(.cmSectionTitle)
                .foregroundStyle(Color.cmTextPrimary)
                .multilineTextAlignment(.center)
                .focused($isNameFocused)
                .tint(.cmPrimaryLight)
        }
        .onTapGesture {
            isNameFocused = false
        }
    }

    private var statsSection: some View {
        VStack(spacing: Spacing.sm) {
            statRow(
                value: totalMemories,
                label: "Кол-во воспоминаний",
                icon: "star.fill",
                color: .yellow
            )

            statRow(
                value: favoriteMemories,
                label: "Избранных воспоминаний",
                icon: "heart.fill",
                color: .pink
            )

            statRow(
                value: totalTracks,
                label: "Кол-во треков",
                icon: "music.note.list",
                color: .cmPrimaryLight
            )
        }
    }

    private func statRow(value: Int, label: String, icon: String, color: Color) -> some View {
        HStack {
            Spacer()

            VStack(alignment: .center, spacing: Spacing.xs) {
                Text("\(value)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.cmTextPrimary)
                    .monospacedDigit()

                Text(label)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
            }

            Spacer()
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                .fill(Color.cmBackgroundLight)
        )
        .overlay(alignment: .topTrailing) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .offset(x: 6, y: -4)
        }
    }
}

// MARK: - Private types

private enum Layout {
    static let avatarSize: CGFloat = 80
    static let avatarBgSize: CGFloat = 100
    static let avatarCornerRadius: CGFloat = 24
    static let cardCornerRadius: CGFloat = 16
}
