import UIKit
import Capacitor
import AVFoundation
import Photos
import WebKit
import SwiftUI

final class AuraBridgeViewController: CAPBridgeViewController, WKScriptMessageHandler, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    private let permissionsBridgeName = "auraPermissions"
    private let audioBridgeName = "auraAudio"
    private var permissionsBridgeInstalled = false
    private var nativeAudioPlayer: AVAudioPlayer?
    private let nativeSpeechSynthesizer = AVSpeechSynthesizer()
    private var nativeAudioRequestId: String?
    private var nativeSpeechRequestId: String?
    private var nativeHeaderController: NativeGlassHeaderController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNativeKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNativeKeyboard()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        layoutNativeHeader()
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
            nativeSpeechSynthesizer.delegate = self
            permissionsBridgeInstalled = true
        }
        installNativeHeaderIfNeeded()
    }

    private func installNativeHeaderIfNeeded() {
        guard nativeHeaderController == nil else {
            layoutNativeHeader()
            return
        }

        let controller = NativeGlassHeaderController(
            onMenu: { [weak self] in
                self?.triggerWebEvent("aura-native-open-sidebar")
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.76)
            },
            onNewChat: { [weak self] in
                self?.triggerWebEvent("aura-native-new-chat")
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.76)
            }
        )
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        nativeHeaderController = controller
        layoutNativeHeader()
    }

    private func layoutNativeHeader() {
        guard let header = nativeHeaderController?.view else { return }
        header.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: 72)
        view.bringSubviewToFront(header)
    }

    private func triggerWebEvent(_ name: String) {
        guard let webView else { return }
        webView.evaluateJavaScript("window.dispatchEvent(new CustomEvent('\(name)'));", completionHandler: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
        traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
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
