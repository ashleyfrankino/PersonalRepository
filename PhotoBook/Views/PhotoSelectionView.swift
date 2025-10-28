import SwiftUI
import PhotosUI

struct PhotoSelectionView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var layoutEngine: LayoutEngine
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingPermissionAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if photoManager.selectedPhotos.isEmpty {
                    emptyStateView
                } else {
                    photoGridView
                }
            }
            .navigationTitle("Select Photos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 100,
                            matching: .images
                        ) {
                            Label("Add Photos", systemImage: "plus")
                        }

                        if !photoManager.selectedPhotos.isEmpty {
                            Button(role: .destructive, action: {
                                photoManager.clearPhotos()
                            }) {
                                Label("Clear All", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Photo Access Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings", action: openSettings)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please grant photo library access in Settings to select photos for your photobook.")
            }
            .onChange(of: selectedItems) { oldValue, newValue in
                Task {
                    await loadSelectedPhotos(newValue)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Photos Selected")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the menu button above to add photos from your library")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 100,
                matching: .images
            ) {
                Label("Select Photos", systemImage: "photo.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 10)
            ], spacing: 10) {
                ForEach(Array(photoManager.selectedPhotos.enumerated()), id: \.element.id) { index, photo in
                    PhotoThumbnailView(photo: photo, index: index)
                }
            }
            .padding()

            if photoManager.isLoading {
                ProgressView("Loading photos...")
                    .padding()
            }
        }
    }

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        var assets: [PHAsset] = []

        for item in items {
            if let assetIdentifier = item.itemIdentifier,
               let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject {
                assets.append(asset)
            }
        }

        photoManager.addPhotos(assets)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct PhotoThumbnailView: View {
    @EnvironmentObject var photoManager: PhotoManager
    let photo: PhotoItem
    let index: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                    )
            }

            Button(action: {
                photoManager.removePhoto(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .padding(4)
        }
    }
}

#Preview {
    PhotoSelectionView()
        .environmentObject(PhotoManager())
        .environmentObject(LayoutEngine())
}
