import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MenuViewerView()
            .onAppear {
                CleanupService.deleteExpiredSessions(in: modelContext)
            }
    }
}
