import SwiftUI

struct EmptyStateView: View {
    let onCapture: () -> Void
    let onImport: () -> Void
    let onScanQR: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("No Menus Yet")
                    .font(.fraunces(22, weight: .semibold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.textPrimary)

                Text("Capture a menu to get started")
                    .font(.dmSans(16))
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: 12) {
                Button(action: onCapture) {
                    Text("Take Photo")
                        .font(.dmSans(16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .background(Color.amber)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button(action: onImport) {
                    Text("Import from Photos")
                        .font(.dmSans(16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.border, lineWidth: 1)
                )

                Button(action: onScanQR) {
                    Text("Scan QR Menu")
                        .font(.dmSans(16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.border, lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
