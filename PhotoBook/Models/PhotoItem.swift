import SwiftUI
import Photos

struct PhotoItem: Identifiable, Codable {
    let id: UUID
    let assetIdentifier: String
    var image: UIImage?
    var qualityScore: Double
    var timestamp: Date
    var metadata: PhotoMetadata

    init(asset: PHAsset) {
        self.id = UUID()
        self.assetIdentifier = asset.localIdentifier
        self.qualityScore = 0.0
        self.timestamp = asset.creationDate ?? Date()
        self.metadata = PhotoMetadata(
            width: asset.pixelWidth,
            height: asset.pixelHeight,
            location: asset.location
        )
    }

    enum CodingKeys: String, CodingKey {
        case id, assetIdentifier, qualityScore, timestamp, metadata
    }
}

struct PhotoMetadata: Codable {
    let width: Int
    let height: Int
    let location: CLLocation?

    enum CodingKeys: String, CodingKey {
        case width, height
    }

    init(width: Int, height: Int, location: CLLocation?) {
        self.width = width
        self.height = height
        self.location = location
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        location = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}
