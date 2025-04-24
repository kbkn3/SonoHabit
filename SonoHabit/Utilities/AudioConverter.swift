import Foundation
import AVFoundation

/// オーディオファイル形式変換を行うクラス
class AudioConverter {
    /// シングルトンインスタンス
    static let shared = AudioConverter()
    
    private init() {}
    
    /// オーディオファイルをMP3に変換する
    /// - Parameters:
    ///   - sourceURL: 変換元ファイルのURL
    ///   - destinationURL: 変換後ファイルの保存先URL
    ///   - bitRate: ビットレート (kbps)
    ///   - completion: 完了ハンドラ
    func convertToMP3(sourceURL: URL, destinationURL: URL, bitRate: Int = 128, completion: @escaping (Result<URL, Error>) -> Void) {
        // TODO: AVAudioConverterを使用した変換処理を実装する
        // 現在はシンプルな実装として、ファイルコピーのみを行う
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            completion(.success(destinationURL))
        } catch {
            Logger.error("オーディオ変換に失敗: \(error.localizedDescription)", error: error, category: Logger.audioLog)
            completion(.failure(error))
        }
    }
    
    /// オーディオファイルのフォーマット情報を取得する
    /// - Parameter fileURL: オーディオファイルURL
    /// - Returns: オーディオフォーマット情報（サンプルレート、チャンネル数、ビットレート等）
    func getAudioFileInfo(fileURL: URL) -> [String: Any]? {
        let asset = AVAsset(url: fileURL)
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            return nil
        }
        
        let format = audioTrack.formatDescriptions.first as? CMAudioFormatDescription
        var info: [String: Any] = [:]
        
        info["duration"] = asset.duration.seconds
        info["fileSize"] = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        
        // 以下は可能であれば取得
        if let basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(format!) {
            info["sampleRate"] = basicDescription.pointee.mSampleRate
            info["channelCount"] = basicDescription.pointee.mChannelsPerFrame
            info["bitsPerChannel"] = basicDescription.pointee.mBitsPerChannel
        }
        
        return info
    }
    
    /// 対応しているオーディオ形式かどうかを確認する
    /// - Parameter fileURL: チェックするファイルのURL
    /// - Returns: 対応しているかどうか
    func isSupportedAudioFormat(fileURL: URL) -> Bool {
        let fileExtension = fileURL.pathExtension.lowercased()
        return Constants.Files.supportedAudioFormats.contains(fileExtension)
    }
} 