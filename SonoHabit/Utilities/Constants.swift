import Foundation

/// アプリケーション全体で使用する定数
struct Constants {
    /// ファイル関連の定数
    struct Files {
        /// 最大録音時間（秒）
        static let maxRecordingDuration: TimeInterval = 3600 // 60分
        
        /// デフォルト保存形式
        static let defaultRecordingFormat = "m4a"
        
        /// 対応しているオーディオ形式
        static let supportedAudioFormats = ["mp3", "m4a", "wav", "aac"]
    }
    
    /// メトロノーム関連の定数
    struct Metronome {
        /// 最小BPM
        static let minBPM = 40
        
        /// 最大BPM
        static let maxBPM = 240
        
        /// デフォルトBPM
        static let defaultBPM = 120
        
        /// デフォルトの拍子
        static let defaultTimeSignature = "4/4"
        
        /// 拍子の選択肢
        static let timeSignatureOptions = ["2/4", "3/4", "4/4", "5/4", "6/8", "7/8", "9/8", "12/8"]
    }
    
    /// UIに関する定数
    struct UI {
        /// アニメーション時間
        static let standardAnimationDuration = 0.3
        
        /// トランジション時間
        static let standardTransitionDuration = 0.2
    }
    
    /// 通知関連の定数
    struct Notifications {
        /// 録音完了通知の識別子
        static let recordingCompletedNotificationName = "com.SonoHabit.recordingCompleted"
        
        /// 同期状態変更通知の識別子
        static let syncStatusChangedNotificationName = "com.SonoHabit.syncStatusChanged"
    }
} 