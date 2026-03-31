import SwiftUI
import SwiftData

@Observable
final class MenuViewerViewModel {
    let enhancementService = ImageEnhancementService()

    var allSessions: [MenuSession] = []
    var currentSessionIndex = 0
    var currentImageIndex = 0
    var searchText = ""
    var showingAdjustments = false
    var showingCamera = false
    var showingQRScanner = false

    var currentSession: MenuSession? {
        guard !activeSessions.isEmpty,
              currentSessionIndex < activeSessions.count else { return nil }
        return activeSessions[currentSessionIndex]
    }

    var activeSessions: [MenuSession] {
        allSessions
            .filter { !$0.isExpired }
            .sorted { $0.capturedAt > $1.capturedAt }
    }

    var currentImages: [MenuImage] {
        currentSession?.sortedImages ?? []
    }

    var currentImage: MenuImage? {
        guard !currentImages.isEmpty,
              currentImageIndex < currentImages.count else { return nil }
        return currentImages[currentImageIndex]
    }

    var hasMenus: Bool {
        !activeSessions.isEmpty
    }

    var totalImageCount: Int {
        activeSessions.reduce(0) { $0 + ($1.images?.count ?? 0) }
    }

    func imageForDisplay(_ menuImage: MenuImage, redLightMode: Bool) -> UIImage? {
        guard let image = UIImage(data: menuImage.imageData) else { return nil }

        if menuImage.hasManualAdjustments {
            let adjusted = enhancementService.applyAdjustments(
                to: image,
                brightness: menuImage.brightnessAdjustment,
                contrast: menuImage.contrastAdjustment,
                warmth: menuImage.warmthAdjustment,
                sharpness: menuImage.sharpnessAdjustment
            )
            return redLightMode ? enhancementService.applyRedLightFilter(to: adjusted) : adjusted
        }

        let enhanced = enhancementService.autoEnhance(image)
        return redLightMode ? enhancementService.applyRedLightFilter(to: enhanced) : enhanced
    }

    func timeRemaining(for session: MenuSession) -> String {
        let remaining = session.expiresAt.timeIntervalSince(.now)
        if remaining <= 0 { return "Expired" }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        }
        return "\(minutes)m remaining"
    }

    func sessionLabel(for index: Int) -> String {
        let sessions = activeSessions
        guard index < sessions.count else { return "" }
        let session = sessions[index]
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: session.capturedAt)
    }
}
