import SwiftUI
import SwiftData

@main
struct Menu_ReadersApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MenuSession.self,
            MenuImage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(.dark)
                .tint(Color.amber)
                .redLightMode(appState.isRedLightMode)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    let context = sharedModelContainer.mainContext
                    CleanupService.deleteExpiredSessions(in: context)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
