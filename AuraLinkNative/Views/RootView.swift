import SwiftUI

struct RootView: View {
    @State private var webState = AuraWebState()

    var body: some View {
        ZStack {
            AuraBackground()

            AuraWebView(state: webState)
                .opacity(webState.hasRenderedContent ? 1 : 0)

            if !webState.hasRenderedContent && webState.errorMessage == nil {
                LaunchExperience()
                    .transition(.opacity)
            }

            if let errorMessage = webState.errorMessage {
                ConnectionRecoveryView(message: errorMessage) {
                    webState.retry()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .background(Color(.systemBackground))
        .animation(.smooth(duration: 0.42), value: webState.hasRenderedContent)
        .animation(.smooth(duration: 0.3), value: webState.errorMessage)
    }
}

private struct LaunchExperience: View {
    @State private var breathing = false

    var body: some View {
        VStack(spacing: 18) {
            AuraOrb(size: 64)
                .scaleEffect(breathing ? 1.04 : 0.94)
                .shadow(color: AuraTheme.electricBlue.opacity(0.28), radius: breathing ? 28 : 14)

            VStack(spacing: 6) {
                Text("Aura Link")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                Text("Preparando seu espaço")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView()
                .controlSize(.small)
                .tint(AuraTheme.electricBlue)
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 30)
        .auraGlass(cornerRadius: 32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Abrindo o Aura Link")
        .task {
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                breathing = true
            }
        }
    }
}

private struct ConnectionRecoveryView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 31, weight: .medium))
                .foregroundStyle(AuraTheme.auraGradient)

            VStack(spacing: 7) {
                Text("Não foi possível conectar")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: retry) {
                Label("Tentar novamente", systemImage: "arrow.clockwise")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
        }
        .frame(maxWidth: 330)
        .padding(28)
        .auraGlass(cornerRadius: 30)
        .padding(24)
    }
}
