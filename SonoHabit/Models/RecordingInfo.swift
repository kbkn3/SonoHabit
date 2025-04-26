import Foundation
import SwiftData

/// 録音情報を管理するモデル
@Model
class RecordingInfo {
    // メタデータ
    var title: String
    var recordedAt: Date
    var duration: TimeInterval
    var filePath: String // ローカルファイルへのパス
    
    // 録音設定
    var inputSource: String? // 使用した入力ソース
    var fileFormat: AudioFileFormat
    var sampleRate: Int
    var bitRate: Int
    
    // 自己評価
    var selfEvaluation: Int? // 1-3のスケール（nil=未評価）
    var evaluationNotes: String
    
    // 関連付け
    @Relationship(deleteRule: .cascade, inverse: \PracticeItem.recordings)
    var practiceItem: PracticeItem?
    
    // 録音ファイル形式
    enum AudioFileFormat: String, Codable, CaseIterable {
        case mp3 = "MP3"
        case m4a = "M4A"
        case wav = "WAV"
        
        var fileExtension: String {
            rawValue.lowercased()
        }
        
        var mimeType: String {
            switch self {
            case .mp3: return "audio/mpeg"
            case .m4a: return "audio/m4a"
            case .wav: return "audio/wav"
            }
        }
    }
    
    init(
        title: String = "録音",
        recordedAt: Date = Date(),
        duration: TimeInterval = 0,
        filePath: String,
        inputSource: String? = nil,
        fileFormat: AudioFileFormat = .m4a,
        sampleRate: Int = 44100,
        bitRate: Int = 128000,
        selfEvaluation: Int? = nil,
        evaluationNotes: String = "",
        practiceItem: PracticeItem? = nil
    ) {
        self.title = title
        self.recordedAt = recordedAt
        self.duration = duration
        self.filePath = filePath
        self.inputSource = inputSource
        self.fileFormat = fileFormat
        self.sampleRate = sampleRate
        self.bitRate = bitRate
        self.selfEvaluation = selfEvaluation
        self.evaluationNotes = evaluationNotes
        self.practiceItem = practiceItem
    }
    
    // 日付と時刻のフォーマット済み文字列を取得
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: recordedAt)
    }
    
    // 録音時間のフォーマット済み文字列を取得
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // ファイルサイズを取得（ファイルが存在する場合）
    func getFileSize() -> Int64? {
        let fileManager = FileManager.default
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            return attributes[.size] as? Int64
        } catch {
            print("ファイルサイズの取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // フォーマット済みファイルサイズを取得
    var formattedFileSize: String {
        guard let size = getFileSize() else {
            return "不明"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    // ファイルが存在するかチェック
    var fileExists: Bool {
        FileManager.default.fileExists(atPath: filePath)
    }
} 