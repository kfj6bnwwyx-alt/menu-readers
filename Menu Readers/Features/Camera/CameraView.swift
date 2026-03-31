import SwiftUI
import SwiftData
import AVFoundation
import PhotosUI

struct CameraView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isAuthorized {
                CameraPreviewRepresentable(session: viewModel.cameraService.session)
                    .ignoresSafeArea()

                cameraOverlay
            } else {
                noPermissionView
            }

            if viewModel.isProcessing {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .task {
            await viewModel.checkPermission()
            viewModel.setupQRDetection()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .alert("QR Menu Found", isPresented: $viewModel.showingQRAlert) {
            Button("Open & Capture") {
                viewModel.showingQRWebCapture = true
            }
            Button("Cancel", role: .cancel) {
                viewModel.detectedQRURL = nil
            }
        } message: {
            Text("Found a menu link. Open it to capture?")
        }
        .fullScreenCover(isPresented: $viewModel.showingQRWebCapture) {
            if let urlString = viewModel.detectedQRURL {
                QRWebCaptureView(urlString: urlString) { image in
                    if let image {
                        viewModel.saveImage(image, to: modelContext, appState: appState)
                    }
                    viewModel.detectedQRURL = nil
                    viewModel.showingQRWebCapture = false
                }
            }
        }
        .photosPicker(
            isPresented: $viewModel.showingPhotoPicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images
        )
        .onChange(of: viewModel.selectedPhotoItem) { _, newValue in
            Task {
                if let image = await viewModel.processPickedPhoto(newValue) {
                    viewModel.saveImage(image, to: modelContext, appState: appState)
                    dismiss()
                }
            }
        }
    }

    private var cameraOverlay: some View {
        ZStack {
            // Top gradient
            VStack {
                LinearGradient(
                    colors: [.black.opacity(0.5), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 110)
                Spacer()
            }

            // Bottom gradient
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
            }

            // Top controls
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Spacer()

                    Button(action: { viewModel.toggleTorch() }) {
                        Image(systemName: viewModel.cameraService.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(viewModel.cameraService.isTorchOn ? Color(hex: 0xFFB547) : .white)
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
            }

            // Bottom controls — glassmorphic capsule
            VStack {
                Spacer()

                HStack(spacing: 40) {
                    // Photo picker with capture count badge
                    Button(action: { viewModel.showingPhotoPicker = true }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
                            )
                            .overlay(alignment: .topTrailing) {
                                if viewModel.captureCount > 0 {
                                    Text("\(viewModel.captureCount)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 26, height: 26)
                                        .background(Color.amber, in: RoundedRectangle(cornerRadius: 13))
                                        .offset(x: 6, y: -8)
                                }
                            }
                    }

                    // Shutter button
                    Button(action: {
                        Task {
                            if let image = await viewModel.capturePhoto() {
                                viewModel.saveImage(image, to: modelContext, appState: appState)
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 3)
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(.white)
                                .frame(width: 60, height: 60)
                        }
                    }

                    // QR scan
                    Button(action: {
                        viewModel.detectedQRURL = nil
                        viewModel.setupQRDetection()
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .frame(height: 88)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.bottom, 20)
            }

            // "Angle corrected" toast
            if viewModel.showAngleCorrectedToast {
                VStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.amber)
                        Text("Angle corrected")
                            .font(.dmSans(13, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 200, height: 40)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 140)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { viewModel.showAngleCorrectedToast = false }
                        }
                    }
                }
                .animation(.easeInOut, value: viewModel.showAngleCorrectedToast)
            }
        }
    }

    private var noPermissionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Camera Access Required")
                .font(.title3.weight(.semibold))
            Text("Open Settings to grant camera access.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
