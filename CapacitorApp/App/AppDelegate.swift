import UIKit
import Capacitor
import AVFoundation
import Photos
import WebKit
import SwiftUI
import Combine

@MainActor
private final class AuraNativeGlassState: ObservableObject {
    @Published var isDark = false
    @Published var modelName = "Aura Link"

    var action: ((String, String?) -> Void)?

    func perform(_ name: String, text: String? = nil) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        action?(name, text)
    }
}

private func loadAuraNativeLogo() -> UIImage? {
    let candidates = [
        Bundle.main.path(forResource: "aura-logo-static", ofType: "png", inDirectory: "public"),
        Bundle.main.bundlePath + "/public/aura-logo-static.png"
    ]
    for path in candidates.compactMap({ $0 }) {
        if let image = UIImage(contentsOfFile: path) { return image }
    }
    return nil
}

private struct AuraNativeLeadingControls: View {
    @ObservedObject var state: AuraNativeGlassState

    private var menuButton: some View {
        Button { state.perform("menu") } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 46, height: 46)
        }
        .foregroundStyle(state.isDark ? Color.white : Color.black)
        .accessibilityLabel("Abrir menu")
    }

    private var modelButton: some View {
        Button { state.perform("model") } label: {
            Group {
                if let logo = loadAuraNativeLogo() {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }
            .frame(width: 34, height: 34)
            .frame(width: 46, height: 46)
        }
        .accessibilityLabel("Selecionar modelo. Atual: \(state.modelName)")
    }

    @available(iOS 26.0, *)
    private var liquidGlassControls: some View {
        HStack(spacing: 0) {
            menuButton
                .buttonStyle(.plain)
            modelButton
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .glassEffect(.regular.interactive(), in: Capsule())
    }

    private var compatibilityControls: some View {
        HStack(spacing: 0) {
            menuButton
                .buttonStyle(.plain)
            modelButton
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial, in: Capsule())
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.0, *) {
            liquidGlassControls
        } else {
            compatibilityControls
        }
    }
}

private struct AuraNativeSidebarTopControls: View {
    @ObservedObject var state: AuraNativeGlassState

    private func circleButton(_ action: String, systemName: String, label: String) -> some View {
        Button { state.perform(action) } label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .frame(width: 46, height: 46)
        }
        .foregroundStyle(state.isDark ? Color.white : Color.black)
        .accessibilityLabel(label)
    }

    var body: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)
            if #available(iOS 26.0, *) {
                circleButton("sidebarSearch", systemName: "magnifyingglass", label: "Pesquisar chats")
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                circleButton("sidebarNewChat", systemName: "plus", label: "Novo chat")
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
            } else {
                circleButton("sidebarSearch", systemName: "magnifyingglass", label: "Pesquisar chats")
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Circle())
                circleButton("sidebarNewChat", systemName: "plus", label: "Novo chat")
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 14)
    }
}

private struct AuraNativeSidebarBottomControls: View {
    @ObservedObject var state: AuraNativeGlassState

    private var chatButton: some View {
        Button { state.perform("sidebarNewChat") } label: {
            HStack(spacing: 9) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .medium))
                Text("Chat")
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(width: 136, height: 48)
        }
        .foregroundStyle(state.isDark ? Color.white : Color.black)
        .accessibilityLabel("Novo chat")
    }

    private var settingsButton: some View {
        Button { state.perform("sidebarSettings") } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 46, height: 46)
        }
        .foregroundStyle(state.isDark ? Color.white : Color.black)
        .accessibilityLabel("Configurações")
    }

    var body: some View {
        HStack(spacing: 12) {
            if #available(iOS 26.0, *) {
                chatButton
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                settingsButton
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
            } else {
                chatButton
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Capsule())
                settingsButton
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Circle())
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
    }
}

private struct AuraNativeNewChatControl: View {
    @ObservedObject var state: AuraNativeGlassState

    private var newChatButton: some View {
        Button { state.perform("newChat") } label: {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 19, weight: .semibold))
                .frame(width: 48, height: 48)
                .contentShape(Circle())
        }
        .foregroundStyle(state.isDark ? Color.white : Color.black)
        .accessibilityLabel("Novo chat")
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.0, *) {
            newChatButton
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            newChatButton
                .buttonStyle(.plain)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

private struct AuraNativeMicrophoneControl: View {
    @ObservedObject var state: AuraNativeGlassState
    @State private var isPressing = false

    var body: some View {
        Image(systemName: "mic")
            .font(.system(size: 15, weight: .medium))
            .frame(width: 32, height: 32)
            .contentShape(Circle())
            .scaleEffect(isPressing ? 0.9 : 1)
            .opacity(isPressing ? 0.72 : 1)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressing else { return }
                        isPressing = true
                        state.perform("micDown")
                    }
                    .onEnded { _ in
                        guard isPressing else { return }
                        isPressing = false
                        state.perform("micUp")
                    }
            )
            .accessibilityLabel("Segure para gravar")
            .animation(.easeOut(duration: 0.14), value: isPressing)
    }
}

private struct AuraNativeComposer: View {
    @ObservedObject var state: AuraNativeGlassState
    @State private var text = ""
    @FocusState private var isFocused: Bool

    private func send() {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        state.perform("send", text: value)
        text = ""
        isFocused = false
    }

    var body: some View {
        VStack(spacing: 7) {
            TextField("Como posso ajudar você hoje?", text: $text, axis: .vertical)
                .lineLimit(1...3)
                .font(.system(size: 16, weight: .regular))
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit(send)

            HStack(spacing: 3) {
                Button { state.perform("tools") } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .medium))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Mais opções")

                Spacer(minLength: 6)

                Button { state.perform("model") } label: {
                    HStack(spacing: 4) {
                        Text(state.modelName)
                            .font(.system(size: 11.5, weight: .medium))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                    }
                    .frame(height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Trocar modelo")

                Button { state.perform("voice") } label: {
                    Image(systemName: "waveform")
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Aura Voice")

                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    AuraNativeMicrophoneControl(state: state)
                } else {
                    Button(action: send) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(state.isDark ? Color.black : Color.white)
                            .frame(width: 32, height: 32)
                            .background(state.isDark ? Color.white : Color.black, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Enviar mensagem")
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .foregroundStyle(state.isDark ? Color.white : Color.black)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .bottom)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: text.isEmpty)
        .animation(.easeOut(duration: 0.2), value: state.isDark)
    }
}

final class AuraBridgeViewController: CAPBridgeViewController, WKScriptMessageHandler, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    private let permissionsBridgeName = "auraPermissions"
    private let audioBridgeName = "auraAudio"
    private let themeBridgeName = "auraTheme"
    private let nativeUIBridgeName = "auraNativeUI"
    private var permissionsBridgeInstalled = false
    private var usesDarkStatusBar = false
    private var nativeAudioPlayer: AVAudioPlayer?
    private let nativeSpeechSynthesizer = AVSpeechSynthesizer()
    private var nativeAudioRequestId: String?
    private var nativeSpeechRequestId: String?
    private let nativeGlassState = AuraNativeGlassState()
    private var nativeLeadingHost: UIHostingController<AuraNativeLeadingControls>?
    private var nativeNewChatHost: UIHostingController<AuraNativeNewChatControl>?
    private var nativeSidebarTopHost: UIHostingController<AuraNativeSidebarTopControls>?
    private var nativeSidebarBottomHost: UIHostingController<AuraNativeSidebarBottomControls>?
    private var nativeSidebarWidthConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNativeKeyboard()
        configureNativeGlassControls()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNativeKeyboard()
    }

    private func configureNativeKeyboard() {
        guard let webView else { return }

        // Mantém apenas o teclado, sem a faixa de navegação de formulários
        // (setas e botão de confirmação) que deixa o compositor alto demais.
        webView.inputAssistantItem.leadingBarButtonGroups = []
        webView.inputAssistantItem.trailingBarButtonGroups = []
        webView.scrollView.keyboardDismissMode = .interactive
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []

        if !permissionsBridgeInstalled {
            webView.configuration.userContentController.add(self, name: permissionsBridgeName)
            webView.configuration.userContentController.add(self, name: audioBridgeName)
            webView.configuration.userContentController.add(self, name: themeBridgeName)
            webView.configuration.userContentController.add(self, name: nativeUIBridgeName)
            let themeScript = WKUserScript(
                source: """
                (() => {
                  const publishAuraTheme = () => {
                    const dark = document.documentElement.classList.contains('dark');
                    window.webkit?.messageHandlers?.auraTheme?.postMessage(dark ? 'dark' : 'light');
                  };
                  new MutationObserver(publishAuraTheme).observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });
                  publishAuraTheme();
                })();
                """,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            webView.configuration.userContentController.addUserScript(themeScript)
            let nativeUIScript = WKUserScript(
                source: """
                (() => {
                  if (window.__auraNativeUIInstalled) return;
                  window.__auraNativeUIInstalled = true;
                  let timer = 0;
                  const publish = () => {
                    clearTimeout(timer);
                    timer = setTimeout(() => {
                      const root = document.documentElement;
                      const sidebarOpen = !!document.querySelector('.mobile-drawer-main.is-partitioned');
                      const dialogOpen = !!document.querySelector('[role="dialog"][data-state="open"]');
                      const hasHeader = !!document.querySelector('.mobile-header-shell');
                      const form = document.querySelector('form');
                      const input = form?.querySelector('textarea');
                      const hasComposer = !!document.querySelector('.input-glow');
                      const hasAttachments = !!form?.querySelector('button[aria-label^="Remover "]');
                      const isStudio = !!document.querySelector('.aura-studio-shell, .aura-studio-active-shell');
                      const top = hasHeader && !sidebarOpen && !dialogOpen;
                      const modelButton = document.querySelector('.mobile-header-model-button button');
                      const label = modelButton?.getAttribute('aria-label') || 'Aura Link';
                      const model = label.replace(/^Selecionar modelo\\. Atual:\\s*/i, '') || 'Aura Link';
                      root.classList.toggle('native-swiftui-glass-active', top);
                      root.classList.toggle('native-swiftui-sidebar-active', sidebarOpen && !dialogOpen);
                      window.webkit?.messageHandlers?.auraNativeUI?.postMessage({ type: 'state', top, sidebar: sidebarOpen && !dialogOpen, model });
                    }, 40);
                  };
                  const observer = new MutationObserver(publish);
                  observer.observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['class', 'data-state', 'aria-label', 'disabled'] });
                  ['pushState', 'replaceState'].forEach((name) => {
                    const original = history[name];
                    history[name] = function(...args) { const result = original.apply(this, args); publish(); return result; };
                  });
                  addEventListener('popstate', publish);
                  addEventListener('aura-native-refresh', publish);
                  publish();
                })();
                """,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            webView.configuration.userContentController.addUserScript(nativeUIScript)
            nativeSpeechSynthesizer.delegate = self
            permissionsBridgeInstalled = true
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == themeBridgeName, let theme = message.body as? String {
            usesDarkStatusBar = theme == "dark"
            nativeGlassState.isDark = usesDarkStatusBar
            view.backgroundColor = usesDarkStatusBar ? UIColor.black : UIColor(red: 0.984, green: 0.980, blue: 0.969, alpha: 1)
            webView?.isOpaque = false
            setNeedsStatusBarAppearanceUpdate()
            return
        }

        if message.name == nativeUIBridgeName,
           let payload = message.body as? [String: Any],
           payload["type"] as? String == "state" {
            let top = payload["top"] as? Bool ?? false
            let sidebar = payload["sidebar"] as? Bool ?? false
            nativeGlassState.modelName = payload["model"] as? String ?? "Aura Link"
            nativeLeadingHost?.view.isHidden = !top
            nativeNewChatHost?.view.isHidden = !top
            nativeSidebarTopHost?.view.isHidden = !sidebar
            nativeSidebarBottomHost?.view.isHidden = !sidebar
            return
        }

        guard let payload = message.body as? [String: Any] else { return }

        if message.name == audioBridgeName {
            handleNativeAudio(payload)
            return
        }

        guard message.name == permissionsBridgeName,
              let type = payload["type"] as? String else { return }

        switch type {
        case "microphone":
            requestCapturePermission(for: .audio, type: type)
        case "camera":
            requestCapturePermission(for: .video, type: type)
        case "photos":
            requestPhotoPermission(type: type)
        case "openSettings":
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            DispatchQueue.main.async {
                UIApplication.shared.open(settingsURL)
            }
        default:
            break
        }
    }

    private func configureNativeGlassControls() {
        nativeGlassState.action = { [weak self] name, text in
            self?.performNativeUIAction(name, text: text)
        }

        let leading = UIHostingController(rootView: AuraNativeLeadingControls(state: nativeGlassState))
        let newChat = UIHostingController(rootView: AuraNativeNewChatControl(state: nativeGlassState))
        let sidebarTop = UIHostingController(rootView: AuraNativeSidebarTopControls(state: nativeGlassState))
        let sidebarBottom = UIHostingController(rootView: AuraNativeSidebarBottomControls(state: nativeGlassState))

        [leading, newChat, sidebarTop, sidebarBottom].forEach { host in
            host.view.backgroundColor = .clear
            host.view.translatesAutoresizingMaskIntoConstraints = false
            host.view.isHidden = true
            addChild(host)
            view.addSubview(host.view)
            host.didMove(toParent: self)
        }

        let sidebarWidth = sidebarTop.view.widthAnchor.constraint(equalToConstant: min(view.bounds.width * 0.76, 340))
        nativeSidebarWidthConstraint = sidebarWidth
        NSLayoutConstraint.activate([
            leading.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            leading.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            leading.view.widthAnchor.constraint(equalToConstant: 104),
            leading.view.heightAnchor.constraint(equalToConstant: 52),

            newChat.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            newChat.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            newChat.view.widthAnchor.constraint(equalToConstant: 52),
            newChat.view.heightAnchor.constraint(equalToConstant: 52),

            sidebarTop.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarTop.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            sidebarTop.view.heightAnchor.constraint(equalToConstant: 58),
            sidebarWidth,

            sidebarBottom.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarBottom.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            sidebarBottom.view.widthAnchor.constraint(equalTo: sidebarTop.view.widthAnchor),
            sidebarBottom.view.heightAnchor.constraint(equalToConstant: 60)
        ])

        nativeLeadingHost = leading
        nativeNewChatHost = newChat
        nativeSidebarTopHost = sidebarTop
        nativeSidebarBottomHost = sidebarBottom
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nativeSidebarWidthConstraint?.constant = min(view.bounds.width * 0.76, 340)
    }

    private func performNativeUIAction(_ action: String, text: String?) {
        guard let webView else { return }
        if action != "send" && action != "micDown" && action != "micUp" {
            view.endEditing(true)
        }
        let script: String
        switch action {
        case "menu":
            script = "document.querySelector('[aria-label=\"Abrir menu\"]')?.click();"
        case "newChat":
            script = "document.querySelector('[aria-label=\"Novo chat\"]')?.click();"
        case "model":
            script = "document.querySelector('.mobile-header-model-button button')?.click();"
        case "tools":
            script = "document.querySelector('form input[type=\"file\"][multiple]')?.click();"
        case "voice":
            script = "document.querySelector('[aria-label=\"Aura Voice\"]')?.click();"
        case "sidebarSearch":
            script = "document.querySelector('.mobile-sidebar-top-action[aria-label*=\"Pesquisar\"],.mobile-sidebar-top-action[aria-label*=\"Search\"]')?.click();"
        case "sidebarNewChat":
            script = "(() => { const primary=document.querySelector('.mobile-sidebar-new-chat'); if (primary) primary.click(); else document.querySelector('.mobile-sidebar-top-action[aria-label*=\"Novo\"]')?.click(); })();"
        case "sidebarSettings":
            script = "document.querySelector('.mobile-sidebar-settings')?.click();"
        case "micDown":
            script = "(() => { const e=document.querySelector('.chat-voice-button'); e?.dispatchEvent(new PointerEvent('pointerdown',{bubbles:true,pointerType:'touch',pointerId:91})); })();"
        case "micUp":
            script = "(() => { const e=document.querySelector('.chat-voice-button'); e?.dispatchEvent(new PointerEvent('pointerup',{bubbles:true,pointerType:'touch',pointerId:91})); })();"
        case "send":
            let value = text ?? ""
            let data = (try? JSONSerialization.data(withJSONObject: ["value": value])) ?? Data("{\"value\":\"\"}".utf8)
            let json = String(data: data, encoding: .utf8) ?? "{\"value\":\"\"}"
            script = """
            (() => {
              const value = \(json).value;
              const input = document.querySelector('textarea:not([disabled])');
              if (!input) return;
              const setter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value')?.set;
              setter?.call(input, value);
              input.dispatchEvent(new Event('input', { bubbles: true }));
              input.dispatchEvent(new Event('change', { bubbles: true }));
              requestAnimationFrame(() => document.querySelector('[aria-label=\"Enviar mensagem\"]')?.click());
            })();
            """
        default:
            return
        }
        webView.evaluateJavaScript(script)
    }

    private func handleNativeAudio(_ payload: [String: Any]) {
        guard let action = payload["action"] as? String else { return }
        let requestId = payload["id"] as? String ?? UUID().uuidString

        switch action {
        case "playBase64":
            guard let encoded = payload["audioBase64"] as? String,
                  let data = Data(base64Encoded: encoded) else {
                publishAudioResult(id: requestId, status: "error")
                return
            }
            do {
                activateVoiceAudioSession()
                nativeSpeechSynthesizer.stopSpeaking(at: .immediate)
                nativeAudioPlayer?.stop()
                let player = try AVAudioPlayer(data: data)
                nativeAudioRequestId = requestId
                player.delegate = self
                player.volume = 1
                player.prepareToPlay()
                nativeAudioPlayer = player
                if !player.play() {
                    publishAudioResult(id: requestId, status: "error")
                }
            } catch {
                NSLog("Aura Voice native playback failed: \(error.localizedDescription)")
                publishAudioResult(id: requestId, status: "error")
            }
        case "speak":
            guard let text = payload["text"] as? String, !text.isEmpty else {
                publishAudioResult(id: requestId, status: "error")
                return
            }
            activateVoiceAudioSession()
            nativeAudioPlayer?.stop()
            nativeSpeechSynthesizer.stopSpeaking(at: .immediate)
            let utterance = AVSpeechUtterance(string: text)
            let language = payload["language"] as? String ?? "pt-BR"
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.preUtteranceDelay = 0.04
            nativeSpeechRequestId = requestId
            nativeSpeechSynthesizer.speak(utterance)
        case "stop":
            nativeAudioPlayer?.stop()
            nativeSpeechSynthesizer.stopSpeaking(at: .immediate)
            if let id = nativeAudioRequestId { publishAudioResult(id: id, status: "cancelled") }
            if let id = nativeSpeechRequestId { publishAudioResult(id: id, status: "cancelled") }
            nativeAudioRequestId = nil
            nativeSpeechRequestId = nil
        default:
            break
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let id = nativeAudioRequestId else { return }
        nativeAudioRequestId = nil
        nativeAudioPlayer = nil
        publishAudioResult(id: id, status: flag ? "finished" : "error")
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let id = nativeAudioRequestId else { return }
        nativeAudioRequestId = nil
        nativeAudioPlayer = nil
        publishAudioResult(id: id, status: "error")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let id = nativeSpeechRequestId else { return }
        nativeSpeechRequestId = nil
        publishAudioResult(id: id, status: "finished")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard let id = nativeSpeechRequestId else { return }
        nativeSpeechRequestId = nil
        publishAudioResult(id: id, status: "cancelled")
    }

    private func publishAudioResult(id: String, status: String) {
        DispatchQueue.main.async { [weak self] in
            guard let webView = self?.webView else { return }
            let script = "window.dispatchEvent(new CustomEvent('aura-native-audio-result',{detail:{id:'\(id)',status:'\(status)'}}));"
            webView.evaluateJavaScript(script)
        }
    }

    private func requestCapturePermission(for mediaType: AVMediaType, type: String) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            if mediaType == .audio { activateVoiceAudioSession() }
            publishPermissionResult(type: type, granted: true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
                if granted && mediaType == .audio { self?.activateVoiceAudioSession() }
                self?.publishPermissionResult(type: type, granted: granted)
            }
        default:
            publishPermissionResult(type: type, granted: false)
        }
    }

    private func activateVoiceAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .allowBluetoothHFP]
            )
            try session.setPreferredSampleRate(48_000)
            try session.setPreferredIOBufferDuration(0.012)
            try session.setActive(true)
        } catch {
            NSLog("Aura Voice audio session could not be activated: \(error.localizedDescription)")
        }
    }

    private func requestPhotoPermission(type: String) {
        let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch current {
        case .authorized, .limited:
            publishPermissionResult(type: type, granted: true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                self?.publishPermissionResult(
                    type: type,
                    granted: status == .authorized || status == .limited
                )
            }
        default:
            publishPermissionResult(type: type, granted: false)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        usesDarkStatusBar ? .lightContent : .darkContent
    }

    override var prefersStatusBarHidden: Bool { false }

    private func publishPermissionResult(type: String, granted: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let webView = self?.webView else { return }
            let status = granted ? "authorized" : "denied"
            let script = "window.dispatchEvent(new CustomEvent('aura-native-permission-result',{detail:{type:'\(type)',status:'\(status)'}}));"
            webView.evaluateJavaScript(script)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration",
                                          sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
