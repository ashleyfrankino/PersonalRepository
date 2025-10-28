import SwiftUI
import Photos
import Combine

class PhotoManager: ObservableObject {
    @Published var selectedPhotos: [PhotoItem] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false

    private var imageManager = PHCachingImageManager()

    init() {
        checkAuthorization()
    }

    func checkAuthorization() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }
        return status == .authorized
    }

    func loadPhotos(from assets: [PHAsset]) async {
        await MainActor.run {
            isLoading = true
        }

        var photoItems: [PhotoItem] = []

        for asset in assets {
            var photoItem = PhotoItem(asset: asset)

            // Load the actual image
            if let image = await loadImage(for: asset) {
                photoItem.image = image
            }

            photoItems.append(photoItem)
        }

        await MainActor.run {
            self.selectedPhotos = photoItems
            self.isLoading = false
        }
    }

    func loadImage(for asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true

            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func addPhotos(_ assets: [PHAsset]) {
        Task {
            await loadPhotos(from: assets)
        }
    }

    func removePhoto(at index: Int) {
        guard index < selectedPhotos.count else { return }
        selectedPhotos.remove(at: index)
    }

    func clearPhotos() {
        selectedPhotos.removeAll()
    }
}
