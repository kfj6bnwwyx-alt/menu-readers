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
        let matrix = ciImage.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0.5, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
        ])
        return render(matrix, size: image.size)
    }

    private func render(_ ciImage: CIImage, size: CGSize) -> UIImage {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}
