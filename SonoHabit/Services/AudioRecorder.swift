import Foundation
import AVFoundation
import Combine

/// 録音機能を提供するクラス
class AudioRecorder: ObservableObject {
    // 録音の状態
    enum RecordingState {
        case stopped       // 停止中
        case recording     // 録音中
        case paused        // 一時停止中
        case error(String) // エラー
    }
    
    // 公開プロパティ
    @Published var state: RecordingState = .stopped
    @Published var elapsedTime: TimeInterval = 0
    @Published var isPeakMeterEnabled: Bool = true
    @Published var peakPower: Float = 0.0 // 0.0-1.0の範囲
    
    // 録音設定
    var fileFormat: RecordingInfo.AudioFileFormat = .m4a
    var sampleRate: Int = 44100
    var bitRate: Int = 128000
    var meterUpdateInterval: TimeInterval = 0.05
    
    // プライベートプロパティ
    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private var recordingStartTime: Date?
    private var recordingPausedTime: TimeInterval = 0
    private var inputManager: AudioInputManager?
    private var recordingFilePath: URL?
    
    // 初期化
    init(inputManager: AudioInputManager? = nil) {
        self.inputManager = inputManager
    }
    
    deinit {
        stopRecording()
    }
    
    /// 録音を開始
    func startRecording(title: String = "録音", practiceItemId: String? = nil) -> URL? {
        // すでに録音中の場合は何もしない
        if case .recording = state { return recordingFilePath }
        
        // 一時停止中なら再開
        if case .paused = state {
            resumeRecording()
            return recordingFilePath
        }
        
        // オーディオセッションをセットアップ
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            state = .error("オーディオセッション設定エラー: \(error.localizedDescription)")
            return nil
        }
        
        // 録音ファイルのパスを生成
        let fileName = "\(title)_\(DateFormatter.filenameDateFormatter.string(from: Date())).\(fileFormat.fileExtension)"
        
        // 録音フォルダの作成と取得
        guard let directoryURL = getOrCreateRecordingsDirectory() else {
            state = .error("録音ディレクトリの作成に失敗しました")
            return nil
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        recordingFilePath = fileURL
        
        // 録音の設定
        let settings: [String: Any] = [
            AVFormatIDKey: getFormatID(),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: bitRate,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        // レコーダーの作成
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = isPeakMeterEnabled
            
            if audioRecorder?.record() == true {
                state = .recording
                recordingStartTime = Date()
                startMeterTimer()
                return fileURL
            } else {
                state = .error("録音の開始に失敗しました")
                return nil
            }
        } catch {
            state = .error("録音設定エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 録音を一時停止
    func pauseRecording() {
        guard case .recording = state, let audioRecorder = audioRecorder else { return }
        
        audioRecorder.pause()
        state = .paused
        
        // 経過時間を保存
        if let startTime = recordingStartTime {
            recordingPausedTime = elapsedTime
            recordingStartTime = nil
        }
        
        // メーターの更新を停止
        stopMeterTimer()
    }
    
    /// 録音を再開
    func resumeRecording() {
        guard case .paused = state, let audioRecorder = audioRecorder else { return }
        
        if audioRecorder.record() {
            state = .recording
            recordingStartTime = Date()
            startMeterTimer()
        } else {
            state = .error("録音の再開に失敗しました")
        }
    }
    
    /// 録音を停止
    @discardableResult
    func stopRecording() -> URL? {
        // 録音中または一時停止中でなければ何もしない
        guard case .recording = state || case .paused = state, 
              let audioRecorder = audioRecorder else { 
            return nil
        }
        
        // メーターの更新を停止
        stopMeterTimer()
        
        // 録音を停止
        audioRecorder.stop()
        
        let url = recordingFilePath
        
        // 状態をリセット
        state = .stopped
        elapsedTime = 0
        recordingStartTime = nil
        recordingPausedTime = 0
        peakPower = 0.0
        
        // オーディオセッションを非アクティブにする（必要に応じて）
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("オーディオセッション非アクティブ化エラー: \(error.localizedDescription)")
        }
        
        return url
    }
    
    /// メーター更新タイマーを開始
    private func startMeterTimer() {
        if !isPeakMeterEnabled { return }
        
        meterTimer = Timer.scheduledTimer(withTimeInterval: meterUpdateInterval, repeats: true) { [weak self] _ in
            self?.updateMeters()
        }
    }
    
    /// メーター更新タイマーを停止
    private func stopMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }
    
    /// メーターの更新
    private func updateMeters() {
        guard let audioRecorder = audioRecorder, isPeakMeterEnabled else { return }
        
        audioRecorder.updateMeters()
        
        // 全チャンネルの最大ピークパワーを取得
        var maxPower: Float = -160.0 // 最小値
        for i in 0..<audioRecorder.numberOfChannels {
            let power = audioRecorder.peakPower(forChannel: i)
            maxPower = max(maxPower, power)
        }
        
        // デシベルを0-1の範囲に変換（-60dBから0dBを0-1にマッピング）
        let normalizedPower = (maxPower + 60.0) / 60.0
        DispatchQueue.main.async {
            self.peakPower = max(0.0, min(1.0, normalizedPower))
            
            // 経過時間の更新
            if let startTime = self.recordingStartTime {
                self.elapsedTime = self.recordingPausedTime + Date().timeIntervalSince(startTime)
            }
        }
    }
    
    /// 録音フォルダを取得または作成
    private func getOrCreateRecordingsDirectory() -> URL? {
        let fileManager = FileManager.default
        
        do {
            // アプリのDocumentsディレクトリを取得
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // 録音ファイル用のサブディレクトリを作成
            let recordingsDirectory = documentsDirectory.appendingPathComponent("Recordings", isDirectory: true)
            
            // ディレクトリが存在しない場合は作成
            if !fileManager.fileExists(atPath: recordingsDirectory.path) {
                try fileManager.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
            }
            
            return recordingsDirectory
        } catch {
            print("録音ディレクトリの作成エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// ファイル形式に対応するFormatIDを取得
    private func getFormatID() -> UInt32 {
        switch fileFormat {
        case .mp3:
            return kAudioFormatMPEG4AAC // iOS標準ではMP3エンコードがないため、AACを使用
        case .m4a:
            return kAudioFormatMPEG4AAC
        case .wav:
            return kAudioFormatLinearPCM
        }
    }
    
    /// 録音ファイルの情報を取得
    func getRecordingInfo(for url: URL, title: String? = nil) -> RecordingInfo? {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: url.path) {
            print("ファイルが存在しません: \(url.path)")
            return nil
        }
        
        do {
            // オーディオファイルからメタデータを取得
            let asset = AVAsset(url: url)
            let duration = CMTimeGetSeconds(asset.duration)
            
            // 入力ソースの情報
            let inputSourceName = inputManager?.selectedInput?.portName
            
            // RecordingInfoオブジェクトを作成
            let recordingInfo = RecordingInfo(
                title: title ?? url.deletingPathExtension().lastPathComponent,
                recordedAt: Date(),
                duration: duration,
                filePath: url.path,
                inputSource: inputSourceName,
                fileFormat: fileFormat,
                sampleRate: sampleRate,
                bitRate: bitRate
            )
            
            return recordingInfo
        } catch {
            print("録音情報の取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async {
            if !flag {
                self.state = .error("録音の完了に失敗しました")
            } else if case .recording = self.state {
                // 正常に完了した場合のみ状態を更新（手動でstopを呼んだ場合は既に .stopped に設定されている）
                self.state = .stopped
            }
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.state = .error("録音エンコードエラー: \(error.localizedDescription)")
            } else {
                self.state = .error("不明な録音エラーが発生しました")
            }
        }
    }
}

// MARK: - DateFormatter Extension

fileprivate extension DateFormatter {
    static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
} 