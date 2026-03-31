import SwiftUI

struct AdjustmentPanel: View {
    @Bindable var menuImage: MenuImage
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Adjust")
                    .font(.fraunces(22, weight: .semibold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Button("Done", action: onDismiss)
                    .font(.dmSans(16, weight: .semibold))
                    .foregroundStyle(Color.amber)
            }

            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.subtleBorder)
                .frame(width: 40, height: 4)

            // Sliders
            VStack(spacing: 28) {
                sliderRow(
                    label: "Brightness",
                    value: $menuImage.brightnessAdjustment,
                    range: -0.5...0.5,
                    displayValue: String(format: "%+.0f", menuImage.brightnessAdjustment * 100)
                )

                sliderRow(
                    label: "Contrast",
                    value: $menuImage.contrastAdjustment,
                    range: 0.5...2.0,
                    displayValue: String(format: "%.0f", (menuImage.contrastAdjustment - 1.0) * 100)
                )

                sliderRow(
                    label: "Warmth",
                    value: $menuImage.warmthAdjustment,
                    range: 3000...9000,
                    displayValue: String(format: "%.0fK", menuImage.warmthAdjustment)
                )

                sliderRow(
                    label: "Sharpness",
                    value: $menuImage.sharpnessAdjustment,
                    range: 0...2.0,
                    displayValue: String(format: "%.0f", menuImage.sharpnessAdjustment * 50)
                )

                // Reset button
                Button {
                    menuImage.brightnessAdjustment = 0.0
                    menuImage.contrastAdjustment = 1.0
                    menuImage.warmthAdjustment = 6500.0
                    menuImage.sharpnessAdjustment = 0.0
                    menuImage.hasManualAdjustments = false
                } label: {
                    Text("Reset to Auto-Enhance")
                        .font(.dmSans(15, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.border, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(Color.cardBg)
        )
        .presentationDetents([.height(480)])
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
        .onChange(of: menuImage.brightnessAdjustment) { _, _ in menuImage.hasManualAdjustments = true }
        .onChange(of: menuImage.contrastAdjustment) { _, _ in menuImage.hasManualAdjustments = true }
        .onChange(of: menuImage.warmthAdjustment) { _, _ in menuImage.hasManualAdjustments = true }
        .onChange(of: menuImage.sharpnessAdjustment) { _, _ in menuImage.hasManualAdjustments = true }
    }

    private func sliderRow(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        displayValue: String
    ) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(label)
                    .font(.dmSans(16, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(displayValue)
                    .font(.dmSans(14, weight: .medium).monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
            }
            Slider(value: value, in: range)
                .tint(Color.amber)
        }
    }
}
