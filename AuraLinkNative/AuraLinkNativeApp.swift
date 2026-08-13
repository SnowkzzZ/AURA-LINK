import SwiftUI
import AVFoundation

@main
struct AuraLinkNativeApp: App {
    init() {
        AudioSessionCoordinator.prepareForAuraVoice()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(AuraTheme.electricBlue)
        }
    }
}

private enum AudioSessionCoordinator {
    static func prepareForAuraVoice() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetoothHFP]
        )
    }
}
