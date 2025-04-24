import Foundation
import SwiftData

@Model
final class UserSettings {
    // 基本設定
    var id: UUID
    var createdAt: Date

    // メトロノーム設定
    var defaultBPM: Int
    var defaultTimeSignatureNumerator: Int
    var defaultTimeSignatureDenominator: Int
    var metronomeSound: String
    var accentSound: String

    // 録音設定
    var audioFormat: AudioFormat
    var audioBitRate: Int
    var automaticNaming: Bool

    // その他
    var darkModeEnabled: Bool?
    var lastViewedMenuID: UUID?

    init(
        defaultBPM: Int = 120,
        defaultTimeSignatureNumerator: Int = 4,
        defaultTimeSignatureDenominator: Int = 4,
        metronomeSound: String = "click",
        accentSound: String = "accent",
        audioFormat: AudioFormat = .m4a,
        audioBitRate: Int = 128000,
        automaticNaming: Bool = true
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.defaultBPM = defaultBPM
        self.defaultTimeSignatureNumerator = defaultTimeSignatureNumerator
        self.defaultTimeSignatureDenominator = defaultTimeSignatureDenominator
        self.metronomeSound = metronomeSound
        self.accentSound = accentSound
        self.audioFormat = audioFormat
        self.audioBitRate = audioBitRate
        self.automaticNaming = automaticNaming
    }
}

enum AudioFormat: String, Codable {
    case m4a
    case mp3
    case wav

    var fileExtension: String {
        self.rawValue
    }

    var mimeType: String {
        switch self {
        case .m4a:
            return "audio/m4a"
        case .mp3:
            return "audio/mpeg"
        case .wav:
            return "audio/wav"
        }
    }
}
