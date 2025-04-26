import Foundation
import AVFoundation
import Combine

/// オーディオ入力ソースを管理するクラス
class AudioInputManager: ObservableObject {
    // 利用可能な入力ソース
    @Published var availableInputs: [AVAudioSessionPortDescription] = []
    @Published var selectedInput: AVAudioSessionPortDescription?
    @Published var inputGain: Float = 1.0
    @Published var isMonitoring: Bool = false
    @Published var inputLevel: Float = 0.0 // 0.0 - 1.0の範囲
    
    // メーターモニタリング
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var levelTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAudioSession()
        loadAvailableInputs()
        
        // 入力変更の通知を購読
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadAvailableInputs()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stopMonitoring()
    }
    
    /// オーディオセッションの設定
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("オーディオセッション設定エラー: \(error.localizedDescription)")
        }
    }
    
    /// 利用可能な入力ソースをロード
    func loadAvailableInputs() {
        let session = AVAudioSession.sharedInstance()
        
        // 現在の入力ルートを保存
        let currentPortName = selectedInput?.uid
        
        // 利用可能な入力ソースを取得
        availableInputs = session.availableInputs ?? []
        
        // 選択されている入力ソースを更新
        if let currentPortName = currentPortName, 
           let matchingInput = availableInputs.first(where: { $0.uid == currentPortName }) {
            selectedInput = matchingInput
        } else {
            // 現在の入力ルートを取得
            let currentRoute = session.currentRoute
            selectedInput = currentRoute.inputs.first
        }
        
        print("利用可能な入力ソース: \(availableInputs.map { $0.portName })")
        print("選択された入力ソース: \(selectedInput?.portName ?? "なし")")
    }
    
    /// 入力ソースを変更
    func selectInput(_ input: AVAudioSessionPortDescription) {
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(input)
            selectedInput = input
            print("入力ソースを変更: \(input.portName)")
            
            // 入力ソースが変更された場合、モニタリングを再起動
            if isMonitoring {
                stopMonitoring()
                startMonitoring()
            }
        } catch {
            print("入力ソース変更エラー: \(error.localizedDescription)")
        }
    }
    
    /// 入力ゲインを設定
    func setInputGain(_ gain: Float) {
        inputGain = gain
        
        // オーディオユニットを使用してゲインを設定する場合はここで実装
        // 現在はAVAudioRecorderで録音時に適用する想定
    }
    
    /// 入力レベルモニタリングを開始
    func startMonitoring() {
        if isMonitoring { return }
        
        setupAudioEngine()
        
        do {
            try audioEngine?.start()
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
        
        audioEngine?.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        isMonitoring = false
        inputLevel = 0.0
    }
    
    /// オーディオエンジンのセットアップ
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        
        // タップを設置して入力レベルをモニター（エフェクトは適用しない）
        let format = inputNode?.inputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            // このタップはレベルメーター更新のために使用
            // 実際の処理はupdateMeterで行う
        }
        
        audioEngine.prepare()
    }
    
    /// 入力レベルメーターを更新
    private func updateMeter() {
        guard let inputNode = inputNode else { return }
        
        // ノードから音量レベルを取得
        var level: Float = 0.0
        
        // 実際のオーディオサンプルからピークレベルを計算
        let format = inputNode.inputFormat(forBus: 0)
        if let channelCount = format.channelCount {
            for i in 0..<channelCount {
                var peakValue: Float = 0.0
                inputNode.volume(atTime: nil, forBus: 0, channel: i, peakValue: &peakValue)
                level = max(level, peakValue)
            }
        }
        
        // デシベルから0-1の範囲に変換（-60dBから0dBを0-1にマッピング）
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
    func checkPermission() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
    
    /// オーディオ録音許可をリクエスト（非同期）
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
} 