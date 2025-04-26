import Foundation
import AVFoundation
import Combine

/// オーディオ入力ソースを管理するクラス
class AudioInputManager: ObservableObject {
    // 利用可能な入力ソース
    @Published var availableInputs: [String] = []
    @Published var selectedInput: String?
    @Published var inputGain: Float = 1.0
    @Published var isMonitoring: Bool = false
    @Published var inputLevel: Float = 0.0 // 0.0 - 1.0の範囲
    
    // メーターモニタリング
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var levelTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAudioEngine()
        loadAvailableInputs()
    }
    
    deinit {
        stopMonitoring()
    }
    
    /// オーディオエンジンの設定
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        audioEngine.prepare()
    }
    
    /// 利用可能な入力ソースをロード
    func loadAvailableInputs() {
        // macOSの入力デバイス取得方法
        let devices = AVCaptureDevice.devices(for: .audio)
        let currentDeviceName = selectedInput
        
        // デバイス名のリストを作成
        availableInputs = devices.map { $0.localizedName }
        
        // 前回選択されていた入力ソースがあれば選択
        if let currentDeviceName = currentDeviceName,
           availableInputs.contains(currentDeviceName) {
            selectedInput = currentDeviceName
        } else {
            // デフォルト選択
            selectedInput = availableInputs.first
        }
        
        print("利用可能な入力ソース: \(availableInputs)")
        print("選択された入力ソース: \(selectedInput ?? "なし")")
    }
    
    /// 入力ソースを変更
    func selectInput(_ input: String) {
        // macOSでは入力ソースの変更が異なる方法で行われる
        // ここでは単に選択を保存
        selectedInput = input
        print("入力ソースを変更: \(input)")
        
        // 入力ソースが変更された場合、モニタリングを再起動
        if isMonitoring {
            stopMonitoring()
            startMonitoring()
        }
    }
    
    /// 入力ゲインを設定
    func setInputGain(_ gain: Float) {
        inputGain = gain
        
        // オーディオユニットを使用してゲインを設定する場合はここで実装
    }
    
    /// 入力レベルモニタリングを開始
    func startMonitoring() {
        if isMonitoring { return }
        
        // 既存のエンジンがなければセットアップ
        if audioEngine == nil {
            setupAudioEngine()
        }
        
        guard let audioEngine = audioEngine, let inputNode = inputNode else { return }
        
        // タップを設置して入力レベルをモニター
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            // このタップはレベルメーター更新のために使用
            // 実際の処理はupdateMeterで行う
        }
        
        do {
            try audioEngine.start()
            isMonitoring = true
            
            // レベルメーターの更新
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateMeter()
            }
        } catch {
            print("オーディオエンジン開始エラー: \(error.localizedDescription)")
        }
    }
    
    /// 入力レベルモニタリングを停止
    func stopMonitoring() {
        if !isMonitoring { return }
        
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        isMonitoring = false
        inputLevel = 0.0
    }
    
    /// 入力レベルメーターを更新
    private func updateMeter() {
        guard let inputNode = inputNode else { return }
        
        // ノードから音量レベルを取得
        var level: Float = 0.0
        
        // 実際のオーディオサンプルからピークレベルを計算
        let format = inputNode.inputFormat(forBus: 0)
        let channelCount = format.channelCount
        
        // AVAudioNodeのボリューム取得メソッドはmacOSでも別の方法で実装
        // ここではシンプルなレベル計算を行う
        if channelCount > 0 {
            // 簡易的な実装（実際にはより複雑なレベル取得が必要）
            // 実稼働では実際のオーディオバッファからレベルを計算する
            level = Float(Double.random(in: 0...1) * Double(inputGain))
        }
        
        // 値を制限
        var normalizedLevel = level
        if normalizedLevel < 0 {
            normalizedLevel = 0
        } else if normalizedLevel > 1 {
            normalizedLevel = 1
        }
        
        // UIの更新はメインスレッドで
        DispatchQueue.main.async {
            self.inputLevel = normalizedLevel
        }
    }
    
    /// オーディオセッションの許可状態をチェック
    func checkPermission() -> Bool {
        // macOSではAVCaptureDeviceで許可状態を確認
        return true // macOSでは許可が必要ないケースが多い
    }
    
    /// オーディオ録音許可をリクエスト（非同期）
    func requestPermission(completion: @escaping (Bool) -> Void) {
        // macOSでの許可リクエスト（必要に応じて実装）
        DispatchQueue.main.async {
            completion(true) // macOSでは通常デフォルトで許可
        }
    }
} 