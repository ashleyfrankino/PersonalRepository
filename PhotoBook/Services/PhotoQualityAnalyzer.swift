import SwiftUI
import Vision
import CoreImage
import CoreML

class PhotoQualityAnalyzer {

    static let shared = PhotoQualityAnalyzer()

    private init() {}

    // Analyze photo quality using multiple metrics
    func analyzePhoto(_ image: UIImage) async -> Double {
        guard let ciImage = CIImage(image: image) else {
            return 0.5
        }

        let sharpnessScore = await calculateSharpness(ciImage)
        let exposureScore = await calculateExposure(ciImage)
        let compositionScore = await calculateComposition(image)

        // Weighted average
        let totalScore = (sharpnessScore * 0.4) + (exposureScore * 0.3) + (compositionScore * 0.3)

        return min(max(totalScore, 0.0), 1.0)
    }

    // Calculate sharpness using Laplacian variance
    private func calculateSharpness(_ ciImage: CIImage) async -> Double {
        let context = CIContext()

        // Convert to grayscale
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)

        guard let outputImage = grayscaleFilter?.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return 0.5
        }

        // Simple edge detection approach
        let edgeFilter = CIFilter(name: "CIEdges")
        edgeFilter?.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        edgeFilter?.setValue(1.0, forKey: kCIInputIntensityKey)

        guard let edgeImage = edgeFilter?.outputImage else {
            return 0.5
        }

        // Calculate variance (proxy for sharpness)
        // Higher variance = sharper image
        let sharpness = calculateImageVariance(edgeImage, context: context)

        // Normalize to 0-1 range (adjust these thresholds based on testing)
        return min(sharpness / 50.0, 1.0)
    }

    // Calculate exposure quality
    private func calculateExposure(_ ciImage: CIImage) async -> Double {
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return 0.5
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let imageContext = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return 0.5
        }

        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Calculate average brightness
        var totalBrightness: Double = 0
        for i in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let r = Double(pixelData[i])
            let g = Double(pixelData[i + 1])
            let b = Double(pixelData[i + 2])

            // Calculate perceived brightness
            let brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            totalBrightness += brightness
        }

        let avgBrightness = totalBrightness / Double(width * height)

        // Ideal exposure is around 0.5, penalize both under and overexposure
        let exposureScore = 1.0 - abs(avgBrightness - 0.5) * 2.0

        return max(exposureScore, 0.0)
    }

    // Calculate composition score using face detection and rule of thirds
    private func calculateComposition(_ image: UIImage) async -> Double {
        guard let ciImage = CIImage(image: image) else {
            return 0.5
        }

        // Use Vision framework for face detection
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        do {
            try handler.perform([request])

            guard let observations = request.results else {
                return 0.5
            }

            if observations.isEmpty {
                // No faces, score based on general composition
                return 0.6
            }

            // Check if faces are well-positioned (rule of thirds)
            var compositionScore = 0.0
            for observation in observations {
                let faceRect = observation.boundingBox

                // Check if face center is near rule of thirds points
                let centerX = faceRect.midX
                let centerY = faceRect.midY

                // Rule of thirds lines at 1/3 and 2/3
                let idealX = [0.33, 0.67]
                let idealY = [0.33, 0.67]

                var minDistance = Double.infinity
                for ix in idealX {
                    for iy in idealY {
                        let distance = sqrt(pow(centerX - ix, 2) + pow(centerY - iy, 2))
                        minDistance = min(minDistance, distance)
                    }
                }

                // Convert distance to score (closer to rule of thirds = better)
                let faceScore = max(0.0, 1.0 - (minDistance * 2))
                compositionScore = max(compositionScore, faceScore)
            }

            return compositionScore

        } catch {
            return 0.5
        }
    }

    private func calculateImageVariance(_ ciImage: CIImage, context: CIContext) -> Double {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return 0.0
        }

        // Sample pixels to calculate variance
        let width = min(cgImage.width, 100)
        let height = min(cgImage.height, 100)

        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let imageContext = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return 0.0
        }

        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Calculate variance of grayscale values
        var sum: Double = 0
        var sumSquares: Double = 0
        let count = width * height

        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let gray = Double(pixelData[i])
            sum += gray
            sumSquares += gray * gray
        }

        let mean = sum / Double(count)
        let variance = (sumSquares / Double(count)) - (mean * mean)

        return sqrt(variance)
    }
}
