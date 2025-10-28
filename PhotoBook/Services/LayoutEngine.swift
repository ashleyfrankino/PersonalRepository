import SwiftUI
import Combine

class LayoutEngine: ObservableObject {
    @Published var currentLayout: LayoutModel?
    @Published var isGenerating = false

    private let qualityAnalyzer = PhotoQualityAnalyzer.shared

    // Generate layout from photos using AI-powered arrangement
    func generateLayout(from photos: [PhotoItem], style: LayoutStyle = .classic) async {
        await MainActor.run {
            isGenerating = true
        }

        // Analyze all photos for quality
        var analyzedPhotos = photos
        for i in 0..<analyzedPhotos.count {
            if let image = analyzedPhotos[i].image {
                let qualityScore = await qualityAnalyzer.analyzePhoto(image)
                analyzedPhotos[i].qualityScore = qualityScore
            }
        }

        // Sort and organize photos
        let organizedPhotos = organizePhotos(analyzedPhotos)

        // Create layout
        let layout = createLayout(from: organizedPhotos, style: style)

        await MainActor.run {
            self.currentLayout = layout
            self.isGenerating = false
        }
    }

    // Organize photos based on quality, chronology, and other factors
    private func organizePhotos(_ photos: [PhotoItem]) -> [PhotoItem] {
        // Sort by multiple criteria
        return photos.sorted { photo1, photo2 in
            // Primary: timestamp (chronological order)
            if photo1.timestamp != photo2.timestamp {
                return photo1.timestamp < photo2.timestamp
            }

            // Secondary: quality score (higher quality first)
            return photo1.qualityScore > photo2.qualityScore
        }
    }

    // Create layout with intelligent page arrangement
    private func createLayout(from photos: [PhotoItem], style: LayoutStyle) -> LayoutModel {
        var layout = LayoutModel(style: style)
        var remainingPhotos = photos

        var pageNumber = 1

        while !remainingPhotos.isEmpty {
            let (page, usedPhotos) = createPage(
                from: remainingPhotos,
                pageNumber: pageNumber,
                style: style
            )

            layout.pages.append(page)
            remainingPhotos.removeFirst(usedPhotos)
            pageNumber += 1
        }

        return layout
    }

    // Create a single page with optimal template selection
    private func createPage(
        from photos: [PhotoItem],
        pageNumber: Int,
        style: LayoutStyle
    ) -> (PageLayout, Int) {

        // Select template based on style and available photos
        let template = selectTemplate(for: photos.count, style: style, pageNumber: pageNumber)

        let photosPerPage = photosRequired(for: template)
        let photosToUse = Array(photos.prefix(photosPerPage))

        var page = PageLayout(pageNumber: pageNumber, template: template)

        // Calculate frames for each photo based on template
        let frames = calculateFrames(for: template)

        for (index, photo) in photosToUse.enumerated() {
            guard index < frames.count else { break }

            let placement = PhotoPlacement(
                photoId: photo.id,
                frame: frames[index],
                rotation: 0
            )

            page.photoItems.append(placement)
        }

        return (page, photosToUse.count)
    }

    // Select appropriate template based on context
    private func selectTemplate(for photoCount: Int, style: LayoutStyle, pageNumber: Int) -> PageTemplate {
        // First page - use single photo for impact
        if pageNumber == 1 && photoCount > 0 {
            return .single
        }

        switch style {
        case .classic:
            // Alternate between single and double photos
            return pageNumber % 2 == 0 ? .twoVertical : .single

        case .modern:
            // Use grid layouts
            return photoCount >= 4 ? .grid4 : .twoHorizontal

        case .magazine:
            // Asymmetric layouts
            return .asymmetric

        case .collage:
            // Maximum photos per page
            return photoCount >= 6 ? .grid6 : .grid4

        case .minimal:
            // Single or two photos max
            return photoCount >= 2 ? .twoHorizontal : .single
        }
    }

    // Get number of photos required for template
    private func photosRequired(for template: PageTemplate) -> Int {
        switch template {
        case .single: return 1
        case .twoVertical, .twoHorizontal: return 2
        case .grid4, .asymmetric: return 4
        case .grid6: return 6
        }
    }

    // Calculate frames for photos based on template
    private func calculateFrames(for template: PageTemplate) -> [CGRect] {
        // Standard photobook page size (8x10 inches at 72 DPI)
        let pageWidth: CGFloat = 576  // 8 inches
        let pageHeight: CGFloat = 720 // 10 inches
        let margin: CGFloat = 36      // 0.5 inch margin

        let contentWidth = pageWidth - (margin * 2)
        let contentHeight = pageHeight - (margin * 2)

        switch template {
        case .single:
            return [
                CGRect(x: margin, y: margin, width: contentWidth, height: contentHeight)
            ]

        case .twoVertical:
            let halfHeight = (contentHeight - margin) / 2
            return [
                CGRect(x: margin, y: margin, width: contentWidth, height: halfHeight),
                CGRect(x: margin, y: margin + halfHeight + margin, width: contentWidth, height: halfHeight)
            ]

        case .twoHorizontal:
            let halfWidth = (contentWidth - margin) / 2
            return [
                CGRect(x: margin, y: margin, width: halfWidth, height: contentHeight),
                CGRect(x: margin + halfWidth + margin, y: margin, width: halfWidth, height: contentHeight)
            ]

        case .grid4:
            let halfWidth = (contentWidth - margin) / 2
            let halfHeight = (contentHeight - margin) / 2
            return [
                CGRect(x: margin, y: margin, width: halfWidth, height: halfHeight),
                CGRect(x: margin + halfWidth + margin, y: margin, width: halfWidth, height: halfHeight),
                CGRect(x: margin, y: margin + halfHeight + margin, width: halfWidth, height: halfHeight),
                CGRect(x: margin + halfWidth + margin, y: margin + halfHeight + margin, width: halfWidth, height: halfHeight)
            ]

        case .grid6:
            let thirdWidth = (contentWidth - (margin * 2)) / 3
            let halfHeight = (contentHeight - margin) / 2
            return [
                CGRect(x: margin, y: margin, width: thirdWidth, height: halfHeight),
                CGRect(x: margin + thirdWidth + margin, y: margin, width: thirdWidth, height: halfHeight),
                CGRect(x: margin + (thirdWidth + margin) * 2, y: margin, width: thirdWidth, height: halfHeight),
                CGRect(x: margin, y: margin + halfHeight + margin, width: thirdWidth, height: halfHeight),
                CGRect(x: margin + thirdWidth + margin, y: margin + halfHeight + margin, width: thirdWidth, height: halfHeight),
                CGRect(x: margin + (thirdWidth + margin) * 2, y: margin + halfHeight + margin, width: thirdWidth, height: halfHeight)
            ]

        case .asymmetric:
            // Large photo on left, three smaller on right
            let largeWidth = contentWidth * 0.6
            let smallWidth = contentWidth * 0.4 - margin
            let thirdHeight = (contentHeight - (margin * 2)) / 3
            return [
                CGRect(x: margin, y: margin, width: largeWidth, height: contentHeight),
                CGRect(x: margin + largeWidth + margin, y: margin, width: smallWidth, height: thirdHeight),
                CGRect(x: margin + largeWidth + margin, y: margin + thirdHeight + margin, width: smallWidth, height: thirdHeight),
                CGRect(x: margin + largeWidth + margin, y: margin + (thirdHeight + margin) * 2, width: smallWidth, height: thirdHeight)
            ]
        }
    }
}
