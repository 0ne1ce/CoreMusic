import PhotosUI
import SwiftUI
import SwiftData

struct CreateMemoryView<ViewModel: CreateMemoryViewModel>: View {
    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                photoSectionView
                metadataSectionView
                selectedTrackSectionView
                locationAndTimeSectionView
                tagsSectionView

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.cmFootnote)
                        .foregroundStyle(Color.cmDanger)
                }

                saveButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.cmBackgroundPrimary)
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { viewModel.onCloseTap() }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.cmTextPrimary)
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(action: handleSaveTap) {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.canSave ? .success : Color.cmTextSecondary.opacity(0.4))
                }
                .disabled(!viewModel.canSave)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onTapGesture {
            isInputFieldFocused = false
        }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Private properties

    @StateObject private var viewModel: ViewModel
    @FocusState private var isInputFieldFocused: Bool

    // MARK: - Private methods

    @ViewBuilder
    private var photoSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Добавить фото")
                .font(.cmSecondary)
                .foregroundStyle(Color.cmTextSecondary)

            PhotosPicker(
                selection: Binding(
                    get: { viewModel.selectedPhotoItem },
                    set: { viewModel.selectedPhotoItem = $0 }
                ),
                matching: .images
            ) {
                if let photoData = viewModel.selectedPhotoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Layout.photoSize, height: Layout.photoSize)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.photoCornerRadius))
                }
                else {
                    RoundedRectangle(cornerRadius: Layout.photoCornerRadius)
                        .fill(Color.cmBackgroundLight)
                        .frame(width: Layout.photoSize, height: Layout.photoSize)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .regular))
                                .foregroundStyle(Color.cmTextSecondary)
                        }
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    private var metadataSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
//            Text("Название воспоминания")
//                .font(.cmSecondary)
//                .foregroundStyle(Color.cmTextSecondary)

            TextField(
                "Название воспоминания",
                text: Binding(
                    get: { viewModel.memoryTitle },
                    set: { viewModel.memoryTitle = $0 }
                )
            )
            .textFieldStyle(.plain)
            .font(.cmMemoryTitle)
            .tint(.primarySecondaryCm)
            .focused($isInputFieldFocused)

//            Text("Заметка (необязательно)")
//                .font(.cmSecondary)
//                .foregroundStyle(Color.cmTextSecondary)

            TextField(
                "Заметка (опционально)",
                text: Binding(
                    get: { viewModel.note },
                    set: { viewModel.note = $0 }
                )
            )
            .textFieldStyle(.plain)
            .font(.cmCardTitle)
            .tint(.primarySecondaryCm)
            .focused($isInputFieldFocused)
        }
    }

    @ViewBuilder
    private var selectedTrackSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Выбранный трек")
                .font(.cmSecondary)
                .foregroundStyle(Color.cmTextSecondary)

            if let track = viewModel.selectedTrack {
                TrackCardView(
                    model: TrackCardModel(track: track),
                    interactionMode: .plain
                )
            }
            else {
                RoundedRectangle(cornerRadius: Layout.sectionCardCornerRadius)
                    .fill(Color.cmBackgroundLight)
                    .frame(height: 86)
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }

    private var locationAndTimeSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Локация и время (необязательно)")
                .font(.cmSecondary)
                .foregroundStyle(Color.cmTextSecondary)

            VStack(alignment: .leading, spacing: Spacing.md) {
                locationSectionView

                Divider()

                dateSectionView
            }
            .padding(Spacing.md)
            .background(Color.cmBackgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: Layout.sectionCardCornerRadius))
        }
    }
    
    @ViewBuilder
    private var locationSectionView: some View {
        HStack {
            Text("Локация")
                .font(.cmBody)
                .foregroundStyle(Color.cmTextPrimary)

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { viewModel.isLocationEnabled },
                    set: { viewModel.isLocationEnabled = $0 }
                )
            )
            .labelsHidden()
            .tint(Color.cmSuccess)
        }

        if viewModel.isLocationEnabled {
            TextField(
                "Имя локации",
                text: Binding(
                    get: { viewModel.locationName },
                    set: { viewModel.locationName = $0 }
                )
            )
            .textFieldStyle(.plain)
            .tint(.primarySecondaryCm)
        }
    }
    
    @ViewBuilder
    private var dateSectionView: some View {
        HStack {
            Text("Дата")
                .font(.cmBody)
                .foregroundStyle(Color.cmTextPrimary)

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { viewModel.isDateEnabled },
                    set: { viewModel.isDateEnabled = $0 }
                )
            )
            .labelsHidden()
            .tint(Color.cmSuccess)
        }

        if viewModel.isDateEnabled {
            DatePicker(
                "Выберите дату",
                selection: Binding(
                    get: { viewModel.memoryDate },
                    set: { viewModel.memoryDate = $0 }
                ),
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .tint(.primaryCm)
        }
    }

    private var tagsSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Теги (необязательно)")
                .font(.cmSecondary)
                .foregroundStyle(Color.cmTextSecondary)

            HStack(spacing: Spacing.md) {
                TextField(
                    "Новый тег",
                    text: Binding(
                        get: { viewModel.tagInput },
                        set: { viewModel.tagInput = $0 }
                    )
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .textFieldStyle(.plain)
                .frame(height: 44)
                .background(Color.cmBackgroundLight)
                .cornerRadius(12)
                .focused($isInputFieldFocused)
                .tint(Color.cmPrimarySecondary)

                Button(action: handleAddTagTap) {
                    Text("+ Добавить")
                        .font(.cmCallout.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .background(Color.cmPrimarySecondary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if !viewModel.tags.isEmpty {
                Text("Добавленные теги")
                    .font(.cmSecondary)
                    .foregroundStyle(Color.cmTextSecondary)

                tagFlowView
            }
        }
    }

    private var tagFlowView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(viewModel.tags, id: \.self) { tag in
                    HStack(spacing: Spacing.sm) {
                        Text(tag)
                            .font(.cmCallout)
                            .foregroundStyle(Color.cmTextPrimary)

                        Button(action: {
                            viewModel.onRemoveTagTap(tag)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.cmTextSecondary.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.cmBackgroundLight)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(.horizontal, -Spacing.xl)
    }

    private var saveButton: some View {
        Button(action: handleSaveTap) {
            if viewModel.isSaving {
                ProgressView()
                    .tint(.white)
            }
            else {
                Text("Сохранить воспоминание")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canSave)
        .padding(.top, Spacing.sm)
    }

    private func handleSaveTap() {
        Task {
            await viewModel.onSaveTap()
        }
    }

    private func handleAddTagTap() {
        viewModel.onAddTagTap()
        isInputFieldFocused = false
    }
}

private enum Layout {
    static let photoSize: CGFloat = 110
    static let photoCornerRadius: CGFloat = 16
    static let sectionCardCornerRadius: CGFloat = 18
}

#Preview {
    NavigationStack {
        try! CreateMemoryView(viewModel: CreateMemoryViewModelImpl(router: CreateMemoryRouterImpl(appRouter: AppRouter()), songID: "preview-7", musicService: MockMusicService(), playerService: PlayerServiceImpl(musicService: MockMusicService()), memoryRepository: SwiftDataMemoryRepository(modelContainer: ModelContainer())))
    }
}
