import SwiftUI

struct PagePreviewView: View {
    let page: PageLayout
    let photos: [PhotoItem]

    // Scale factor for preview (from 72 DPI to screen display)
    private let scaleFactor: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Page background
                Rectangle()
                    .fill(Color.white)
                    .shadow(radius: 5)

                // Photo placements
                ForEach(page.photoItems) { placement in
                    if let photo = photos.first(where: { $0.id == placement.photoId }) {
                        PhotoPlacementView(
                            photo: photo,
                            placement: placement,
                            scaleFactor: scaleFactor
                        )
                    }
                }
            }
            .frame(
                width: 576 * scaleFactor,  // 8 inches at 72 DPI
                height: 720 * scaleFactor  // 10 inches at 72 DPI
            )
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .background(Color.gray.opacity(0.2))
    }
}

struct PhotoPlacementView: View {
    let photo: PhotoItem
    let placement: PhotoPlacement
    let scaleFactor: CGFloat

    var body: some View {
        Group {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: placement.frame.width * scaleFactor,
                        height: placement.frame.height * scaleFactor
                    )
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(
                        width: placement.frame.width * scaleFactor,
                        height: placement.frame.height * scaleFactor
                    )
            }
        }
        .cornerRadius(2)
        .rotationEffect(.degrees(placement.rotation))
        .position(
            x: (placement.frame.midX * scaleFactor),
            y: (placement.frame.midY * scaleFactor)
        )
    }
}

#Preview {
    PagePreviewView(
        page: PageLayout(pageNumber: 1, template: .grid4),
        photos: []
    )
}
