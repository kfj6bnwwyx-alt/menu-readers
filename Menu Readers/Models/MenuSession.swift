import Foundation
import SwiftData

@Model
final class MenuSession {
    var capturedAt: Date = Date.now
    var expiresAt: Date = Date.now.addingTimeInterval(86400)

    @Relationship(deleteRule: .cascade, inverse: \MenuImage.session)
    var images: [MenuImage]?

    var sortedImages: [MenuImage] {
        (images ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var isExpired: Bool {
        Date.now > expiresAt
    }

    init() {
        self.capturedAt = .now
        self.expiresAt = Date.now.addingTimeInterval(86400)
    }
}
