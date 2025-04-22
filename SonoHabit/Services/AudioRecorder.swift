import Foundation
import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject {
    // MARK: - 公開プロパティ
    
    // 録音の状態
    @Published var isRecording = false
    @Published var isDoneRecording = false
    @Published var recordingTime: TimeInterval = 0
    
    // 録音レベルメーター
    @Published var recordingLevels: [Float] = []
    
    // 録音が完了したときのURL
    @Published var recordedFileURL: URL?
    
    // エラー情報
    @Published var errorMessage: String?
    
    // MARK: - 内部プロパティ
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var audioMeteringLevelsCount = 30
    
    // デフォルト設定
    private let settings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
    ]
    
    // MARK: - 初期化
    override init() {
        super.init()
        setupNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: - 公開メソッド
    
    /// 録音を開始する
    func startRecording() {
        // 既に録音中の場合は何もしない
        if isRecording {
            return
        }
        
        // リセット
        recordingTime = 0
        recordingLevels = Array(repeating: 0, count: audioMeteringLevelsCount)
        isDoneRecording = false
        recordedFileURL = nil
        errorMessage = nil
        
        // AudioSessionの設定
        #if os(iOS) || os(watchOS) || os(tvOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            self.errorMessage = "オーディオセッションの設定に失敗しました: \(error.localizedDescription)"
            return
        }
        #endif
        
        // 一時ファイルのURLを作成
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
        
        do {
            // レコーダーの作成
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            // 録音開始
            audioRecorder?.record()
            isRecording = true
            
            // タイマーを開始して録音時間と音量レベルを更新
            startTimer()
        } catch {
            self.errorMessage = "録音の開始に失敗しました: \(error.localizedDescription)"
        }
    }
    
    /// 録音を停止する
    func stopRecording() {
        guard isRecording, let recorder = audioRecorder else { return }
        
        recorder.stop()
        isRecording = false
        recordedFileURL = recorder.url
        isDoneRecording = true
        
        timer?.invalidate()
        timer = nil
        
        // AudioSessionの非アクティブ化（iOS）
        #if os(iOS) || os(watchOS) || os(tvOS)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("オーディオセッションの非アクティブ化に失敗: \(error)")
        }
        #endif
    }
    
    /// 録音ファイルを削除する
    func deleteRecording() {
        guard let url = recordedFileURL else { return }
        
        do {
            try FileManager.default.removeItem(at: url)
            recordedFileURL = nil
            isDoneRecording = false
        } catch {
            self.errorMessage = "録音ファイルの削除に失敗しました: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 内部メソッド
    
    private func setupNotifications() {
        // 録音中断時の通知を登録
        #if os(iOS) || os(watchOS) || os(tvOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        #endif
    }
    
    private func removeNotifications() {
        #if os(iOS) || os(watchOS) || os(tvOS)
        NotificationCenter.default.removeObserver(self)
        #endif
    }
    
    @objc private func handleInterruption(notification: Notification) {
        #if os(iOS) || os(watchOS) || os(tvOS)
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            // 中断された場合は録音を停止
            if isRecording {
                stopRecording()
            }
        }
        #endif
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording, let recorder = self.audioRecorder else { return }
            
            self.recordingTime = recorder.currentTime
            
            // 音量レベルを更新
            recorder.updateMeters()
            let level = recorder.averagePower(forChannel: 0)
            var normLevel = self.normalize(level: level)
            
            // ノイズフロアを設定（値が小さすぎる場合は0とする）
            if normLevel < 0.05 {
                normLevel = 0
            }
            
            // 配列を更新
            self.recordingLevels.append(normLevel)
            if self.recordingLevels.count > self.audioMeteringLevelsCount {
                self.recordingLevels.removeFirst()
            }
        }
    }
    
    /// デシベル値（-160〜0）を0〜1の範囲に正規化
    private func normalize(level: Float) -> Float {
        // -160dbから0dbの範囲を0から1にマッピング
        let minDb: Float = -80  // 実用的な最小値
        let normalizedValue = max(0.0, min(1.0, (level - minDb) / abs(minDb)))
        return normalizedValue
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            errorMessage = "録音が正常に終了しませんでした"
        }
        
        isRecording = false
        recordedFileURL = recorder.url
        isDoneRecording = true
        
        timer?.invalidate()
        timer = nil
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            errorMessage = "録音中にエラーが発生しました: \(error.localizedDescription)"
        }
        
        isRecording = false
        timer?.invalidate()
        timer = nil
    }
} 