import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

@Observable
final class ImageEnhancementService {
    private let context = CIContext()

    func autoEnhance(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let enhanced = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputBrightnessKey: 0.05,
            kCIInputContrastKey: 1.15,
            kCIInputSaturationKey: 1.05
        ])
        .applyingFilter("CISharpenLuminance", parameters: [
            kCIInputSharpnessKey: 0.4
        ])
        return render(enhanced, size: image.size)
    }

    func applyAdjustments(
        to image: UIImage,
        brightness: Double,
        contrast: Double,
        warmth: Double,
        sharpness: Double
    ) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        var result = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputBrightnessKey: brightness,
            kCIInputContrastKey: contrast
        ])

        result = result.applyingFilter("CITemperatureAndTint", parameters: [
            "inputNeutral": CIVector(x: warmth, y: 0)
        ])

        if sharpness > 0 {
            result = result.applyingFilter("CISharpenLuminance", parameters: [
                kCIInputSharpnessKey: sharpness
            ])
        }

        return render(result, size: image.size)
    }

    func applyRedLightFilter(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let source: CIImage
        if isBrightImage(ciImage) {
            // Invert bright/white images so they become dark, then apply red tint
            source = ciImage.applyingFilter("CIColorInvert")
        } else {
            source = ciImage
        }

        let matrix = source.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0.5, y: 0.15, z: 0.1, w: 0),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputBiasVector": CIVector(x: 0.05, y: 0, z: 0, w: 0)
        ])
        return render(matrix, size: image.size)
    }

    /// Checks if the image is predominantly bright (e.g. white background menu)
    private func isBrightImage(_ ciImage: CIImage) -> Bool {
        // Sample average brightness using CIAreaAverage
        let extent = ciImage.extent
        let average = ciImage.applyingFilter("CIAreaAverage", parameters: [
            kCIInputExtentKey: CIVector(x: extent.origin.x, y: extent.origin.y,
                                         z: extent.size.width, w: extent.size.height)
        ])
        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(average,
                       toBitmap: &pixel,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        let brightness = (Double(pixel[0]) + Double(pixel[1]) + Double(pixel[2])) / (3.0 * 255.0)
        return brightness > 0.55
    }

    private func render(_ ciImage: CIImage, size: CGSize) -> UIImage {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}
