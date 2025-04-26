import Foundation
import AVFoundation

/// メトロノームのアクセントパターンを管理するサービス
class MetronomeAccentService {
    // アクセントパターンの種類
    enum AccentPattern: String, CaseIterable, Identifiable {
        case standard     // 標準（小節の最初にアクセント）
        case offBeat      // 裏拍にアクセント
        case custom       // カスタムパターン
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .standard: return "標準"
            case .offBeat: return "裏拍"
            case .custom: return "カスタム"
            }
        }
    }
    
    /// 指定された拍子とパターンに基づいて、アクセントパターンの配列を生成する
    /// - Parameters:
    ///   - beatsPerMeasure: 拍子の分子（1小節あたりの拍数）
    ///   - pattern: アクセントパターンの種類
    ///   - customPattern: カスタムパターンの場合、アクセント位置を表す配列 (0-indexed)
    /// - Returns: 各拍のアクセント状態を表す真偽値の配列（true=アクセント）
    func generateAccentPattern(beatsPerMeasure: Int, pattern: AccentPattern, customPattern: [Int]? = nil) -> [Bool] {
        var accentPattern = Array(repeating: false, count: beatsPerMeasure)
        
        switch pattern {
        case .standard:
            // 標準パターン: 小節の最初の拍のみアクセント
            if beatsPerMeasure > 0 {
                accentPattern[0] = true
            }
            
        case .offBeat:
            // 裏拍パターン: 偶数拍にアクセント（0-indexedなので奇数インデックス）
            for i in 0..<beatsPerMeasure {
                accentPattern[i] = (i % 2 == 1)
            }
            
        case .custom:
            // カスタムパターン: 指定された位置にアクセント
            if let customPattern = customPattern {
                for position in customPattern {
                    if position >= 0 && position < beatsPerMeasure {
                        accentPattern[position] = true
                    }
                }
            }
        }
        
        return accentPattern
    }
    
    /// 拍子に基づいて一般的なアクセントパターンを生成する
    /// - Parameter beatsPerMeasure: 拍子の分子（1小節あたりの拍数）
    /// - Returns: 各拍のアクセント状態を表す真偽値の配列
    func getDefaultAccentPatternForTimeSignature(beatsPerMeasure: Int) -> [Bool] {
        var accentPattern = Array(repeating: false, count: beatsPerMeasure)
        
        switch beatsPerMeasure {
        case 2: // 2/4, 2/2など
            accentPattern[0] = true
            
        case 3: // 3/4, 3/8など
            accentPattern[0] = true
            
        case 4: // 4/4など
            accentPattern[0] = true
            // 3拍目に弱いアクセントを付けることもあるが、ここではシンプルにする
            
        case 5: // 5/4, 5/8など
            // 一般的には2+3または3+2で分割
            accentPattern[0] = true
            accentPattern[3] = true // 3+2の場合
            
        case 6: // 6/8など
            // 一般的には2拍ごとにアクセント（複合拍子）
            accentPattern[0] = true
            accentPattern[3] = true
            
        case 7: // 7/8など
            // 一般的には2+2+3または3+2+2など
            accentPattern[0] = true
            accentPattern[3] = true // 3+2+2の場合
            accentPattern[5] = true
            
        case 9: // 9/8など
            // 一般的には3拍ごとにアクセント
            accentPattern[0] = true
            accentPattern[3] = true
            accentPattern[6] = true
            
        case 12: // 12/8など
            // 一般的には3拍ごとにアクセント
            accentPattern[0] = true
            accentPattern[3] = true
            accentPattern[6] = true
            accentPattern[9] = true
            
        default:
            // その他の拍子は最初の拍のみアクセント
            if beatsPerMeasure > 0 {
                accentPattern[0] = true
            }
        }
        
        return accentPattern
    }
} 