import Foundation
import SwiftData

/// アプリケーション内のファイル管理を行うクラス
class FileManagerService {
    // シングルトンインスタンス
    static let shared = FileManagerService()
    
    private init() {}
    
    // MARK: - ディレクトリ関連
    
    /// アプリケーションのDocumentsディレクトリのURLを取得
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// 録音ファイル保存用のディレクトリURLを取得
    func getRecordingsDirectory() -> URL {
        let documentsDir = getDocumentsDirectory()
        let recordingsDir = documentsDir.appendingPathComponent("Recordings", isDirectory: true)
        
        // ディレクトリが存在しない場合は作成
        if !FileManager.default.fileExists(atPath: recordingsDir.path) {
            do {
                try FileManager.default.createDirectory(at: recordingsDir, withIntermediateDirectories: true)
            } catch {
                print("録音ディレクトリの作成に失敗: \(error.localizedDescription)")
            }
        }
        
        return recordingsDir
    }
    
    /// 音源ファイル保存用のディレクトリURLを取得
    func getAudioSourcesDirectory() -> URL {
        let documentsDir = getDocumentsDirectory()
        let audioSourcesDir = documentsDir.appendingPathComponent("AudioSources", isDirectory: true)
        
        // ディレクトリが存在しない場合は作成
        if !FileManager.default.fileExists(atPath: audioSourcesDir.path) {
            do {
                try FileManager.default.createDirectory(at: audioSourcesDir, withIntermediateDirectories: true)
            } catch {
                print("音源ディレクトリの作成に失敗: \(error.localizedDescription)")
            }
        }
        
        return audioSourcesDir
    }
    
    // MARK: - 録音ファイル管理
    
    /// 一時ファイルを録音ファイルディレクトリに移動し、RecordingInfoモデルを作成
    func saveRecording(from tempURL: URL, for practiceItem: PracticeItem, in context: ModelContext) -> RecordingInfo? {
        let recordingsDir = getRecordingsDirectory()
        
        // ファイル名を生成（練習項目ID + タイムスタンプ）
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(practiceItem.name)_\(Int(timestamp)).m4a"
            .replacingOccurrences(of: " ", with: "_")
            .folding(options: .diacriticInsensitive, locale: .current)
        
        let destinationURL = recordingsDir.appendingPathComponent(filename)
        
        do {
            // 同名ファイルが既に存在する場合は削除
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // ファイルをコピー
            try FileManager.default.copyItem(at: tempURL, to: destinationURL)
            
            // ファイルサイズを取得
            let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // RecordingInfoモデルを作成
            let recordingInfo = RecordingInfo(
                filePath: destinationURL.lastPathComponent,
                recordedAt: Date(),
                fileSize: fileSize
            )
            recordingInfo.practiceItem = practiceItem
            
            // モデルコンテキストに追加
            context.insert(recordingInfo)
            
            return recordingInfo
        } catch {
            print("録音ファイルの保存に失敗: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 録音ファイルURLをRecordingInfoから取得
    func getRecordingURL(for recordingInfo: RecordingInfo) -> URL {
        let recordingsDir = getRecordingsDirectory()
        return recordingsDir.appendingPathComponent(recordingInfo.filePath)
    }
    
    /// 録音ファイルを削除
    func deleteRecording(_ recordingInfo: RecordingInfo, in context: ModelContext) {
        let fileURL = getRecordingURL(for: recordingInfo)
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            // モデルから削除
            context.delete(recordingInfo)
        } catch {
            print("録音ファイルの削除に失敗: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 音源ファイル管理
    
    /// 外部音源ファイルをアプリ内ディレクトリにコピーし、AudioSourceInfoモデルを作成
    func saveAudioSource(from sourceURL: URL, filename: String?, for practiceItem: PracticeItem, in context: ModelContext) -> AudioSourceInfo? {
        let audioSourcesDir = getAudioSourcesDirectory()
        
        // ファイル名を生成
        let finalFilename = filename ?? sourceURL.lastPathComponent
        let destinationURL = audioSourcesDir.appendingPathComponent(finalFilename)
        
        do {
            // 同名ファイルが既に存在する場合は別名で保存
            var uniqueDestinationURL = destinationURL
            var counter = 0
            while FileManager.default.fileExists(atPath: uniqueDestinationURL.path) {
                counter += 1
                let newFilename = "\(finalFilename.deletingPathExtension)_\(counter).\(finalFilename.pathExtension)"
                uniqueDestinationURL = audioSourcesDir.appendingPathComponent(newFilename)
            }
            
            // ファイルをコピー
            try FileManager.default.copyItem(at: sourceURL, to: uniqueDestinationURL)
            
            // ファイルサイズを取得
            let attributes = try FileManager.default.attributesOfItem(atPath: uniqueDestinationURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // AudioSourceInfoモデルを作成
            let audioSourceInfo = AudioSourceInfo(
                fileName: uniqueDestinationURL.lastPathComponent,
                displayName: finalFilename.deletingPathExtension,
                filePath: uniqueDestinationURL.lastPathComponent,
                duration: 0 // 初期値として0を設定
            )
            audioSourceInfo.practiceItem = practiceItem
            
            // モデルコンテキストに追加
            context.insert(audioSourceInfo)
            
            return audioSourceInfo
        } catch {
            print("音源ファイルの保存に失敗: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 音源ファイルURLをAudioSourceInfoから取得
    func getAudioSourceURL(for audioSourceInfo: AudioSourceInfo) -> URL {
        let audioSourcesDir = getAudioSourcesDirectory()
        return audioSourcesDir.appendingPathComponent(audioSourceInfo.filePath)
    }
    
    /// 音源ファイルを削除
    func deleteAudioSource(_ audioSourceInfo: AudioSourceInfo, in context: ModelContext) {
        let fileURL = getAudioSourceURL(for: audioSourceInfo)
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            // モデルから削除
            context.delete(audioSourceInfo)
        } catch {
            print("音源ファイルの削除に失敗: \(error.localizedDescription)")
        }
    }
}

// MARK: - 文字列拡張
fileprivate extension String {
    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }
    
    var pathExtension: String {
        (self as NSString).pathExtension
    }
} 