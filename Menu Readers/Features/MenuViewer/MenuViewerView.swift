import SwiftUI
import SwiftData

struct MenuViewerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \MenuSession.capturedAt, order: .reverse) private var sessions: [MenuSession]

    @State private var viewModel = MenuViewerViewModel()
    @State private var showingCamera = false
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom nav bar
            navBar

            if viewModel.hasMenus {
                menuContent
            } else {
                EmptyStateView(
                    onCapture: { showingCamera = true },
                    onImport: { showingCamera = true },
                    onScanQR: { showingCamera = true }
                )
            }
        }
        .background(Color.themeBg)
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $viewModel.showingAdjustments) {
            if let image = viewModel.currentImage {
                AdjustmentPanel(menuImage: image) {
                    viewModel.showingAdjustments = false
                }
            }
        }
        .onChange(of: sessions) {
            viewModel.allSessions = sessions
        }
        .onAppear {
            viewModel.allSessions = sessions
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Text("Menu Readers")
                .font(.fraunces(22, weight: .semibold))
                .tracking(-0.3)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            HStack(spacing: 16) {
                // Red light mode toggle dot
                Button {
                    appState.isRedLightMode.toggle()
                } label: {
                    Circle()
                        .fill(appState.isRedLightMode ? Color.red : Color.subtleBorder)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.textSecondary, lineWidth: 1.5)
                        )
                        .shadow(color: appState.isRedLightMode ? .red.opacity(0.4) : .clear, radius: 12)
                }

                // Settings gear
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 24)
    }

    // MARK: - Menu Content

    private var menuContent: some View {
        VStack(spacing: 0) {
            // Session picker
            if viewModel.activeSessions.count > 1 {
                sessionPicker
            }

            // Session expiry
            if let session = viewModel.currentSession {
                HStack {
                    Text(viewModel.timeRemaining(for: session))
                        .font(.dmSans(12, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 24)
            }

            // Image pager
            TabView(selection: $viewModel.currentImageIndex) {
                ForEach(Array(viewModel.currentImages.enumerated()), id: \.element.id) { index, menuImage in
                    MenuCardView(
                        menuImage: menuImage,
                        redLightMode: appState.isRedLightMode,
                        enhancementService: viewModel.enhancementService
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))

            // Hint row
            Text("Long press to expand  \u{00B7}  Swipe to browse")
                .font(.dmSans(12))
                .foregroundStyle(Color.textTertiary)
                .frame(height: 40)

            // Bottom bar
            bottomBar
        }
    }

    // MARK: - Session Picker

    private var sessionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(viewModel.activeSessions.enumerated()), id: \.element.id) { index, session in
                    Button {
                        viewModel.currentSessionIndex = index
                        viewModel.currentImageIndex = 0
                    } label: {
                        VStack(spacing: 2) {
                            Text(viewModel.sessionLabel(for: index))
                                .font(.dmSans(13, weight: .semibold))
                                .foregroundStyle(
                                    index == viewModel.currentSessionIndex
                                        ? Color.amber
                                        : Color.textSecondary
                                )
                            Text("\(session.sortedImages.count) pages")
                                .font(.dmSans(10, weight: .medium))
                                .foregroundStyle(
                                    index == viewModel.currentSessionIndex
                                        ? Color.amber.opacity(0.53)
                                        : Color.textTertiary
                                )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            index == viewModel.currentSessionIndex
                                ? Color.amber.opacity(0.13)
                                : Color.cardBg,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 52)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 64) {
            if viewModel.currentImage != nil {
                Button {
                    viewModel.showingAdjustments = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 24))
                        Text("Adjust")
                            .font(.dmSans(16, weight: .semibold))
                    }
                    .foregroundStyle(Color.textPrimary)
                }

                Button {
                    showingCamera = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                        Text("Camera")
                            .font(.dmSans(16, weight: .semibold))
                    }
                    .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(Color.cardBg)
    }
}
