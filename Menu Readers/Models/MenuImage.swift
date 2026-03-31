import Foundation
import SwiftData

@Model
final class MenuImage {
    @Attribute(.externalStorage)
    var imageData: Data = Data()
    var extractedText: String = ""
    var sortOrder: Int = 0
    var capturedAt: Date = Date.now

    var brightnessAdjustment: Double = 0.0
    var contrastAdjustment: Double = 1.0
    var warmthAdjustment: Double = 6500.0
    var sharpnessAdjustment: Double = 0.0
    var hasManualAdjustments: Bool = false

    var session: MenuSession?

    init(imageData: Data, sortOrder: Int = 0) {
        self.imageData = imageData
        self.sortOrder = sortOrder
        self.capturedAt = .now
    }
}
