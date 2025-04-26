import Foundation
import SwiftData

@Model
class MetronomeSettings {
    // 基本設定
    var bpm: Int
    var timeSignature: TimeSignature
    var measuresCount: Int
    var repetitionCount: Int
    var clickSound: ClickSound
    var isAccentEnabled: Bool
    
    // BPM自動段階上昇設定
    var isProgressionEnabled: Bool
    var targetBpm: Int?
    var bpmIncrement: Int
    var incrementMeasures: Int
    
    // 拍子設定用の列挙型
    enum TimeSignature: String, Codable, CaseIterable {
        case fourFour = "4/4"
        case threeFour = "3/4"
        case twoFour = "2/4"
        case sixEight = "6/8"
        case fiveFour = "5/4"
        
        var beatsPerMeasure: Int {
            switch self {
            case .fourFour: return 4
            case .threeFour: return 3
            case .twoFour: return 2
            case .sixEight: return 6
            case .fiveFour: return 5
            }
        }
    }
    
    // クリック音設定用の列挙型
    enum ClickSound: String, Codable, CaseIterable {
        case click = "Click"
        case wood = "Wood"
        case digital = "Digital"
        case beep = "Beep"
        
        var filename: String {
            switch self {
            case .click: return "metronome-click"
            case .wood: return "metronome-wood"
            case .digital: return "metronome-digital"
            case .beep: return "metronome-beep"
            }
        }
        
        var accentFilename: String {
            return "\(filename)-accent"
        }
    }
    
    init(
        bpm: Int = 120,
        timeSignature: TimeSignature = .fourFour,
        measuresCount: Int = 4,
        repetitionCount: Int = 0,  // 0は無限繰り返し
        clickSound: ClickSound = .click,
        isAccentEnabled: Bool = true,
        isProgressionEnabled: Bool = false,
        targetBpm: Int? = nil,
        bpmIncrement: Int = 5,
        incrementMeasures: Int = 4
    ) {
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.measuresCount = measuresCount
        self.repetitionCount = repetitionCount
        self.clickSound = clickSound
        self.isAccentEnabled = isAccentEnabled
        self.isProgressionEnabled = isProgressionEnabled
        self.targetBpm = targetBpm
        self.bpmIncrement = bpmIncrement
        self.incrementMeasures = incrementMeasures
    }
} 