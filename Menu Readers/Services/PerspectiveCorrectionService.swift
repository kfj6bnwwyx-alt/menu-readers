import UIKit
import Vision
import CoreImage

struct PerspectiveCorrectionService {
    private static let context = CIContext()

    static func correctPerspective(_ image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let rectangles = await detectRectangle(in: cgImage)
        guard let observation = rectangles else { return image }

        let ciImage = CIImage(cgImage: cgImage)
        let imageSize = ciImage.extent.size

        // Vision returns normalized coordinates (0-1) with origin at bottom-left
        let topLeft = CIVector(
            x: observation.topLeft.x * imageSize.width,
            y: observation.topLeft.y * imageSize.height
        )
        let topRight = CIVector(
            x: observation.topRight.x * imageSize.width,
            y: observation.topRight.y * imageSize.height
        )
        let bottomLeft = CIVector(
            x: observation.bottomLeft.x * imageSize.width,
            y: observation.bottomLeft.y * imageSize.height
        )
        let bottomRight = CIVector(
            x: observation.bottomRight.x * imageSize.width,
            y: observation.bottomRight.y * imageSize.height
        )

        let corrected = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": topLeft,
            "inputTopRight": topRight,
            "inputBottomLeft": bottomLeft,
            "inputBottomRight": bottomRight
        ])

        guard let outputCG = context.createCGImage(corrected, from: corrected.extent) else {
            return image
        }
        return UIImage(cgImage: outputCG)
    }

    private static func detectRectangle(in cgImage: CGImage) async -> VNRectangleObservation? {
        await withCheckedContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                guard error == nil,
                      let results = request.results as? [VNRectangleObservation],
                      let best = results.first else {
                    continuation.resume(returning: nil)
                    return
                }
                // Only correct if confidence is high enough to avoid false positives
                if best.confidence > 0.6 {
                    continuation.resume(returning: best)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            request.minimumConfidence = 0.5
            request.maximumObservations = 1
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 1.0

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
}
