import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class CameraViewModel {
    let cameraService = CameraService()
    let enhancementService = ImageEnhancementService()

    var isAuthorized = false
    var capturedImage: UIImage?
    var showingPhotoPicker = false
    var selectedPhotoItem: PhotosPickerItem?
    var isProcessing = false
    var captureCount = 0
    var showAngleCorrectedToast = false

    // QR
    var detectedQRURL: String?
    var showingQRAlert = false
    var showingQRWebCapture = false

    func checkPermission() async {
        isAuthorized = await cameraService.requestPermission()
        if isAuthorized {
            cameraService.startSession()
        }
    }

    func setupQRDetection() {
        cameraService.onQRCodeDetected = { [weak self] value in
            guard let self, self.detectedQRURL == nil else { return }
            if value.hasPrefix("http://") || value.hasPrefix("https://") {
                self.detectedQRURL = value
                self.showingQRAlert = true
            }
        }
    }

    func capturePhoto() async -> UIImage? {
        isProcessing = true
        defer { isProcessing = false }

        guard let photo = await cameraService.capturePhoto() else { return nil }
        let corrected = await PerspectiveCorrectionService.correctPerspective(photo)
        let wasCorrected = corrected !== photo
        let enhanced = enhancementService.autoEnhance(corrected)
        capturedImage = enhanced
        captureCount += 1
        if wasCorrected {
            showAngleCorrectedToast = true
        }
        return enhanced
    }

    func processPickedPhoto(_ item: PhotosPickerItem?) async -> UIImage? {
        guard let item else { return nil }
        isProcessing = true
        defer { isProcessing = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return nil }

        let corrected = await PerspectiveCorrectionService.correctPerspective(image)
        let wasCorrected = corrected !== image
        let enhanced = enhancementService.autoEnhance(corrected)
        capturedImage = enhanced
        captureCount += 1
        if wasCorrected {
            showAngleCorrectedToast = true
        }
        return enhanced
    }

    func saveImage(_ image: UIImage, to context: ModelContext, appState: AppState) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }

        let session = findOrCreateSession(in: context, interval: appState.sessionGroupingInterval)
        let sortOrder = (session.images?.count ?? 0)
        let menuImage = MenuImage(imageData: data, sortOrder: sortOrder)
        menuImage.session = session
        context.insert(menuImage)

        try? context.save()
    }

    private func findOrCreateSession(in context: ModelContext, interval: TimeInterval) -> MenuSession {
        let cutoff = Date.now.addingTimeInterval(-interval)
        let predicate = #Predicate<MenuSession> { session in
            session.capturedAt > cutoff
        }
        let descriptor = FetchDescriptor<MenuSession>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let newSession = MenuSession()
        context.insert(newSession)
        return newSession
    }

    func toggleTorch() {
        cameraService.toggleTorch()
    }

    func stopCamera() {
        cameraService.stopSession()
    }
}
