import SwiftUI

extension Font {
    /// Fraunces variable font — used for titles/headings
    static func fraunces(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Fraunces", size: size).weight(weight)
    }

    /// DM Sans variable font — used for body/UI text
    static func dmSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans 9pt", size: size).weight(weight)
    }

    /// Inter variable font — kept for compatibility
    static func inter(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("InterVariable", size: size).weight(weight)
    }
}
