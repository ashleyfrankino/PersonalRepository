import SwiftUI

struct LayoutModel: Identifiable, Codable {
    let id: UUID
    var pages: [PageLayout]
    var style: LayoutStyle

    init(style: LayoutStyle = .classic) {
        self.id = UUID()
        self.pages = []
        self.style = style
    }
}

struct PageLayout: Identifiable, Codable {
    let id: UUID
    var photoItems: [PhotoPlacement]
    var pageNumber: Int
    var template: PageTemplate

    init(pageNumber: Int, template: PageTemplate) {
        self.id = UUID()
        self.photoItems = []
        self.pageNumber = pageNumber
        self.template = template
    }
}

struct PhotoPlacement: Identifiable, Codable {
    let id: UUID
    let photoId: UUID
    var frame: CGRect
    var rotation: Double

    init(photoId: UUID, frame: CGRect, rotation: Double = 0) {
        self.id = UUID()
        self.photoId = photoId
        self.frame = frame
        self.rotation = rotation
    }
}

enum LayoutStyle: String, Codable, CaseIterable {
    case classic = "Classic"
    case modern = "Modern"
    case magazine = "Magazine"
    case collage = "Collage"
    case minimal = "Minimal"
}

enum PageTemplate: String, Codable, CaseIterable {
    case single = "Single Photo"
    case twoVertical = "Two Vertical"
    case twoHorizontal = "Two Horizontal"
    case grid4 = "Grid 4"
    case grid6 = "Grid 6"
    case asymmetric = "Asymmetric"
}
