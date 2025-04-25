import Foundation
import SwiftData

@Model
final class UserSettings {
    // アプリ全体の設定
    var lastOpenedMenuId: PersistentIdentifier?
    var defaultMetronomeSound: String
    var defaultMetronomeBPM: Int
    var defaultTimeSignature: String
    var showWelcomeScreen: Bool
    
    // オーディオ設定
    var recordingQuality: String
    var recordingFormat: String
    var useInputBoost: Bool
    var inputGain: Double
    
    init(defaultMetronomeSound: String = "click",
         defaultMetronomeBPM: Int = 100,
         defaultTimeSignature: String = "4/4",
         showWelcomeScreen: Bool = true,
         recordingQuality: String = "medium",
         recordingFormat: String = "m4a",
         useInputBoost: Bool = false,
         inputGain: Double = 1.0) {
        self.defaultMetronomeSound = defaultMetronomeSound
        self.defaultMetronomeBPM = defaultMetronomeBPM
        self.defaultTimeSignature = defaultTimeSignature
        self.showWelcomeScreen = showWelcomeScreen
        self.recordingQuality = recordingQuality
        self.recordingFormat = recordingFormat
        self.useInputBoost = useInputBoost
        self.inputGain = inputGain
    }
} 