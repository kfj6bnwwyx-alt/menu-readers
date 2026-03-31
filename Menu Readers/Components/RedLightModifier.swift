import SwiftUI

struct RedLightModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .tint(isActive ? Color.redPrimary : Color.amber)
            .preferredColorScheme(.dark)
            .overlay {
                if isActive {
                    Color.red.opacity(0.12)
                        .blendMode(.multiply)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .colorMultiply(isActive ? Color(red: 1.0, green: 0.3, blue: 0.3) : .white)
    }
}

extension View {
    func redLightMode(_ isActive: Bool) -> some View {
        modifier(RedLightModifier(isActive: isActive))
    }
}
