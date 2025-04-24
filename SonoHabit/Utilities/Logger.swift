import Foundation
import os.log

/// アプリケーション内のログ出力を管理するクラス
class Logger {
    // カテゴリー別のOSログオブジェクト
    static let appLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.SonoHabit", category: "App")
    static let dataLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.SonoHabit", category: "Data")
    static let audioLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.SonoHabit", category: "Audio")
    static let uiLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.SonoHabit", category: "UI")
    static let syncLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.SonoHabit", category: "Sync")
    
    // MARK: - 一般ログメソッド
    
    /// デバッグログを出力する
    static func debug(_ message: String, category: OSLog = appLog) {
        #if DEBUG
        os_log(.debug, log: category, "%{public}@", message)
        #endif
    }
    
    /// 情報ログを出力する
    static func info(_ message: String, category: OSLog = appLog) {
        os_log(.info, log: category, "%{public}@", message)
    }
    
    /// 警告ログを出力する
    static func warning(_ message: String, category: OSLog = appLog) {
        os_log(.error, log: category, "⚠️ %{public}@", message)
    }
    
    /// エラーログを出力する
    static func error(_ message: String, error: Error? = nil, category: OSLog = appLog) {
        if let error = error {
            os_log(.error, log: category, "❌ %{public}@: %{public}@", message, error.localizedDescription)
        } else {
            os_log(.error, log: category, "❌ %{public}@", message)
        }
    }
    
    // MARK: - カテゴリー別ショートカットメソッド
    
    /// アプリケーション全般に関するログ
    static func appDebug(_ message: String) {
        debug(message, category: appLog)
    }
    
    /// データ操作に関するログ
    static func dataDebug(_ message: String) {
        debug(message, category: dataLog)
    }
    
    /// オーディオ処理に関するログ
    static func audioDebug(_ message: String) {
        debug(message, category: audioLog)
    }
    
    /// UI操作に関するログ
    static func uiDebug(_ message: String) {
        debug(message, category: uiLog)
    }
    
    /// 同期に関するログ
    static func syncDebug(_ message: String) {
        debug(message, category: syncLog)
    }
} 