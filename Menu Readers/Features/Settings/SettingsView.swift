import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var showingClearConfirmation = false

    private var groupingMinutes: Binding<Double> {
        Binding(
            get: { appState.sessionGroupingInterval / 60 },
            set: { appState.sessionGroupingInterval = $0 * 60 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Text("Settings")
                    .font(.fraunces(22, weight: .semibold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Button("Done") { dismiss() }
                    .font(.dmSans(16, weight: .semibold))
                    .foregroundStyle(Color.amber)
            }
            .frame(height: 52)
            .padding(.horizontal, 24)

            // Scrollable content
            ScrollView {
                VStack(spacing: 32) {
                    // DISPLAY section
                    settingsSection("DISPLAY") {
                        settingsCard {
                            @Bindable var state = appState
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.destructive)
                                    Text("Red Light Mode")
                                        .font(.dmSans(16, weight: .medium))
                                        .foregroundStyle(Color.textPrimary)
                                }
                                Spacer()
                                Toggle("", isOn: $state.isRedLightMode)
                                    .labelsHidden()
                                    .tint(.red)
                            }
                        }
                    }

                    // SESSION GROUPING section
                    settingsSection("SESSION GROUPING") {
                        settingsCard {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Time Window")
                                        .font(.dmSans(16, weight: .medium))
                                        .foregroundStyle(Color.textPrimary)
                                    Spacer()
                                    Text("\(Int(appState.sessionGroupingInterval / 60)) min")
                                        .font(.dmSans(16, weight: .medium).monospacedDigit())
                                        .foregroundStyle(Color.textSecondary)
                                }

                                Slider(value: groupingMinutes, in: 5...120, step: 5)
                                    .tint(Color.amber)

                                Text("Photos taken within this window are grouped as one session.")
                                    .font(.dmSans(13))
                                    .foregroundStyle(Color.textTertiary)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    // DATA section
                    settingsSection("DATA") {
                        Button {
                            showingClearConfirmation = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.destructive)
                                Text("Clear All Menus")
                                    .font(.dmSans(16, weight: .medium))
                                    .foregroundStyle(Color.destructive)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }

                    // ABOUT section
                    settingsSection("ABOUT") {
                        settingsCard {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Version")
                                        .font(.dmSans(16, weight: .medium))
                                        .foregroundStyle(Color.textPrimary)
                                    Spacer()
                                    Text("1.0")
                                        .font(.dmSans(16))
                                        .foregroundStyle(Color.textSecondary)
                                }

                                Rectangle()
                                    .fill(Color.border)
                                    .frame(height: 1)

                                HStack {
                                    Text("Auto-Expiration")
                                        .font(.dmSans(16, weight: .medium))
                                        .foregroundStyle(Color.textPrimary)
                                    Spacer()
                                    Text("24 hours")
                                        .font(.dmSans(16))
                                        .foregroundStyle(Color.textSecondary)
                                }

                                Rectangle()
                                    .fill(Color.border)
                                    .frame(height: 1)

                                Text("Menu photos are automatically deleted 24 hours after capture. No data leaves your device.")
                                    .font(.dmSans(13))
                                    .foregroundStyle(Color.textTertiary)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(Color.themeBg)
        .confirmationDialog(
            "Clear All Menus?",
            isPresented: $showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                CleanupService.deleteAllSessions(in: modelContext)
            }
        } message: {
            Text("This will delete all saved menu photos. This cannot be undone.")
        }
    }

    // MARK: - Helpers

    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.dmSans(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(Color.textSecondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func settingsCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 16))
    }
}
