import SwiftUI
import UIKit

final class NativeGlassHeaderController: UIHostingController<NativeGlassHeader> {
    init(onMenu: @escaping () -> Void, onNewChat: @escaping () -> Void) {
        super.init(rootView: NativeGlassHeader(onMenu: onMenu, onNewChat: onNewChat))
        view.backgroundColor = .clear
        view.isOpaque = false
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct NativeGlassHeader: View {
    let onMenu: () -> Void
    let onNewChat: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onMenu) {
                HStack(spacing: 9) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 23, height: 23)
                    Image("AuraMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .accessibilityHidden(true)
                }
                .frame(height: 48)
                .padding(.horizontal, 13)
                .contentShape(.rect)
            }
            .buttonStyle(NativeGlassButtonStyle(cornerRadius: 24))
            .accessibilityLabel("Abrir menu")

            Spacer(minLength: 12)

            Button(action: onNewChat) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 48, height: 48)
                    .contentShape(.circle)
            }
            .buttonStyle(NativeGlassButtonStyle(cornerRadius: 24))
            .accessibilityLabel("Novo chat")
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

private struct NativeGlassButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                configuration.label
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                configuration.label
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 0.7)
                    }
            }
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
