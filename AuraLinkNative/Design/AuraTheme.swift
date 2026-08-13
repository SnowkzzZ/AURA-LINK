import SwiftUI

enum AuraTheme {
    static let electricBlue = Color(red: 0.18, green: 0.48, blue: 1.00)
    static let iris = Color(red: 0.49, green: 0.35, blue: 0.98)
    static let cyan = Color(red: 0.18, green: 0.86, blue: 0.98)

    static var auraGradient: LinearGradient {
        LinearGradient(colors: [cyan, electricBlue, iris], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct AuraBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
            Circle()
                .fill(AuraTheme.cyan.opacity(colorScheme == .dark ? 0.18 : 0.12))
                .frame(width: 360)
                .blur(radius: 80)
                .offset(x: 150, y: -310)
            Circle()
                .fill(AuraTheme.iris.opacity(colorScheme == .dark ? 0.20 : 0.10))
                .frame(width: 300)
                .blur(radius: 90)
                .offset(x: -160, y: 330)
        }
        .ignoresSafeArea()
    }
}

struct AuraOrb: View {
    var size: CGFloat = 38

    var body: some View {
        ZStack {
            Circle().fill(AuraTheme.auraGradient)
            Circle().fill(.white.opacity(0.52)).frame(width: size * 0.32).blur(radius: size * 0.08)
            Circle().stroke(.white.opacity(0.45), lineWidth: 1)
        }
        .frame(width: size, height: size)
        .shadow(color: AuraTheme.electricBlue.opacity(0.34), radius: size * 0.25, y: size * 0.12)
        .accessibilityHidden(true)
    }
}

extension View {
    @ViewBuilder
    func auraGlass(cornerRadius: CGFloat = 24) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

