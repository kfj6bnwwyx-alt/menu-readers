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
            // Session picker (always visible — shows time even for single session)
            sessionPicker

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

            // Card fan stack
            cardStack
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            let threshold: CGFloat = 60
                            if value.translation.width < -threshold {
                                withAnimation(.spring(duration: 0.35)) {
                                    viewModel.currentImageIndex = min(viewModel.currentImageIndex + 1,
                                                                      viewModel.currentImages.count - 1)
                                }
                            } else if value.translation.width > threshold {
                                withAnimation(.spring(duration: 0.35)) {
                                    viewModel.currentImageIndex = max(viewModel.currentImageIndex - 1, 0)
                                }
                            }
                        }
                )

            // Page dots + label
            if viewModel.currentImages.count > 1 {
                VStack(spacing: 8) {
                    pageDots
                    Text("Page \(viewModel.currentImageIndex + 1) of \(viewModel.currentImages.count)")
                        .font(.dmSans(11, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top, 4)
            }

            // Hint row
            Text("Long press to expand  \u{00B7}  Swipe to browse")
                .font(.dmSans(12))
                .foregroundStyle(Color.textTertiary)
                .frame(height: 40)

            // Bottom bar
            bottomBar
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            // Back cards (behind current)
            ForEach(Array(viewModel.currentImages.enumerated().reversed()), id: \.element.id) { index, _ in
                let distance = index - viewModel.currentImageIndex
                if distance > 0 && distance <= 3 {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(distance == 1 ? Color.surfaceBg : Color.surfaceBg.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.subtleBorder, lineWidth: 1)
                        )
                        .frame(width: 300 - CGFloat(distance * 10),
                               height: 430 - CGFloat(distance * 20))
                        .rotationEffect(.degrees(Double(distance) * 4))
                        .shadow(color: .black.opacity(0.3), radius: CGFloat(distance * 8),
                                y: CGFloat(distance * 4))
                }
            }

            // Main card
            if let currentImage = viewModel.currentImage {
                MenuCardView(
                    menuImage: currentImage,
                    redLightMode: appState.isRedLightMode,
                    enhancementService: viewModel.enhancementService
                )
                .frame(width: 300, height: 430)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.subtleBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 32, y: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page Dots

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.currentImages.count, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentImageIndex ? Color.amber : Color.subtleBorder)
                    .frame(width: index == viewModel.currentImageIndex ? 8 : 6,
                           height: index == viewModel.currentImageIndex ? 8 : 6)
            }
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
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(Color.cardBg)
    }
}
