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
    
    // アクセント設定
    var accentPattern: AccentPatternType
    var customAccentPositions: [Int]?
    
    // BPM自動段階上昇設定
    var isProgressionEnabled: Bool
    var targetBpm: Int?
    var bpmIncrement: Int
    var incrementInterval: ProgressionIntervalType
    var incrementIntervalValue: Int
    
    // 拍子設定用の列挙型
    enum TimeSignature: String, Codable, CaseIterable {
        case fourFour = "4/4"
        case threeFour = "3/4"
        case twoFour = "2/4"
        case sixEight = "6/8"
        case fiveFour = "5/4"
        case sevenEight = "7/8"
        case nineEight = "9/8"
        case twelveEight = "12/8"
        
        var beatsPerMeasure: Int {
            switch self {
            case .fourFour: return 4
            case .threeFour: return 3
            case .twoFour: return 2
            case .sixEight: return 6
            case .fiveFour: return 5
            case .sevenEight: return 7
            case .nineEight: return 9
            case .twelveEight: return 12
            }
        }
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    // クリック音設定用の列挙型
    enum ClickSound: String, Codable, CaseIterable {
        case click = "Click"
        case woodblock = "Woodblock"
        case bongo = "Bongo"
        
        var displayName: String {
            return self.rawValue
        }
        
        var normalFilename: String {
            switch self {
            case .click: return "click"
            case .woodblock: return "woodblock"
            case .bongo: return "bongo"
            }
        }
        
        var accentFilename: String {
            return "\(normalFilename)_accent"
        }
    }
    
    // アクセントパターンタイプ
    enum AccentPatternType: String, Codable, CaseIterable {
        case standard = "Standard"  // 小節の最初にアクセント
        case offBeat = "OffBeat"    // 裏拍にアクセント
        case custom = "Custom"      // カスタムパターン
        
        var displayName: String {
            switch self {
            case .standard: return "標準"
            case .offBeat: return "裏拍"
            case .custom: return "カスタム"
            }
        }
    }
    
    // BPM増加のインターバルタイプ
    enum ProgressionIntervalType: String, Codable, CaseIterable {
        case measures = "Measures"  // 小節数ごと
        case seconds = "Seconds"    // 秒数ごと
        
        var displayName: String {
            switch self {
            case .measures: return "小節数"
            case .seconds: return "秒数"
            }
        }
    }
    
    init(
        bpm: Int = 120,
        timeSignature: TimeSignature = .fourFour,
        measuresCount: Int = 4,
        repetitionCount: Int = 0,  // 0は無限繰り返し
        clickSound: ClickSound = .click,
        isAccentEnabled: Bool = true,
        accentPattern: AccentPatternType = .standard,
        customAccentPositions: [Int]? = nil,
        isProgressionEnabled: Bool = false,
        targetBpm: Int? = nil,
        bpmIncrement: Int = 5,
        incrementInterval: ProgressionIntervalType = .measures,
        incrementIntervalValue: Int = 4
    ) {
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.measuresCount = measuresCount
        self.repetitionCount = repetitionCount
        self.clickSound = clickSound
        self.isAccentEnabled = isAccentEnabled
        self.accentPattern = accentPattern
        self.customAccentPositions = customAccentPositions
        self.isProgressionEnabled = isProgressionEnabled
        self.targetBpm = targetBpm
        self.bpmIncrement = bpmIncrement
        self.incrementInterval = incrementInterval
        self.incrementIntervalValue = incrementIntervalValue
    }
    
    // BPMプログレッションの説明を生成
    func getProgressionDescription() -> String? {
        guard isProgressionEnabled, let targetBpm = targetBpm else {
            return nil
        }
        
        let direction = targetBpm > bpm ? "上昇" : "下降"
        let intervalDesc: String
        
        switch incrementInterval {
        case .measures:
            intervalDesc = "\(incrementIntervalValue)小節"
        case .seconds:
            intervalDesc = "\(incrementIntervalValue)秒"
        }
        
        return "\(bpm)から\(targetBpm)へ\(direction) (\(bpmIncrement)BPM/\(intervalDesc))"
    }
} 