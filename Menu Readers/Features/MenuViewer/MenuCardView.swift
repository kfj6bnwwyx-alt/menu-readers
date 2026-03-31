import SwiftUI

struct MenuCardView: View {
    let menuImage: MenuImage
    let redLightMode: Bool
    let enhancementService: ImageEnhancementService

    @State private var displayImage: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            if let displayImage {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .gesture(zoomGesture)
                    .gesture(dragGesture)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(duration: 0.3)) {
                            if scale > 1.0 {
                                scale = 1.0
                                offset = .zero
                            } else {
                                scale = 2.5
                            }
                            lastScale = scale
                            lastOffset = offset
                        }
                    }
            } else {
                ProgressView()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .clipped()
        .task(id: menuImage.id) {
            loadImage()
        }
        .onChange(of: redLightMode) {
            loadImage()
        }
        .onChange(of: menuImage.hasManualAdjustments) {
            loadImage()
        }
    }

    private func loadImage() {
        guard let original = UIImage(data: menuImage.imageData) else { return }

        if menuImage.hasManualAdjustments {
            let adjusted = enhancementService.applyAdjustments(
                to: original,
                brightness: menuImage.brightnessAdjustment,
                contrast: menuImage.contrastAdjustment,
                warmth: menuImage.warmthAdjustment,
                sharpness: menuImage.sharpnessAdjustment
            )
            displayImage = redLightMode ? enhancementService.applyRedLightFilter(to: adjusted) : adjusted
        } else {
            let enhanced = enhancementService.autoEnhance(original)
            displayImage = redLightMode ? enhancementService.applyRedLightFilter(to: enhanced) : enhanced
        }
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                scale = min(max(newScale, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.0 {
                    withAnimation(.spring(duration: 0.3)) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}
