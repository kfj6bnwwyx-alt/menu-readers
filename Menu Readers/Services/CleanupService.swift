import Foundation
import SwiftData

struct CleanupService {
    static func deleteExpiredSessions(in context: ModelContext) {
        let now = Date.now
        let predicate = #Predicate<MenuSession> { session in
            session.expiresAt < now
        }
        let descriptor = FetchDescriptor<MenuSession>(predicate: predicate)

        do {
            let expired = try context.fetch(descriptor)
            for session in expired {
                context.delete(session)
            }
            if !expired.isEmpty {
                try context.save()
            }
        } catch {
            print("Cleanup error: \(error)")
        }
    }

    static func deleteAllSessions(in context: ModelContext) {
        let descriptor = FetchDescriptor<MenuSession>()
        do {
            let all = try context.fetch(descriptor)
            for session in all {
                context.delete(session)
            }
            try context.save()
        } catch {
            print("Delete all error: \(error)")
        }
    }
}
