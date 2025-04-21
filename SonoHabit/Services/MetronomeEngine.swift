import Foundation
import AVFoundation

class MetronomeEngine: ObservableObject {
    // MARK: - 公開プロパティ
    @Published var bpm: Int = 120 {
        didSet {
            if isPlaying {
                restart()
            }
        }
    }
    
    @Published var isPlaying: Bool = false
    @Published var currentBeat: Int = 0
    @Published var currentBar: Int = 0
    
    var timeSignatureNumerator: Int = 4 {
        didSet {
            if isPlaying {
                restart()
            }
        }
    }
    
    var timeSignatureDenominator: Int = 4 {
        didSet {
            if isPlaying {
                restart()
            }
        }
    }
    
    var totalBars: Int = 4
    var repeatCount: Int = 1
    var autoIncreaseBPM: Bool = false
    var maxBPM: Int?
    var bpmIncrement: Int?
    
    // アクセント設定
    var accentBeats: [Int] = [1] // デフォルトで1拍目にアクセント
    
    // サウンド設定
    var clickSoundName: String = "click"
    var accentSoundName: String = "accent"
    
    // MARK: - 内部プロパティ
    private var audioEngine: AVAudioEngine?
    private var clickPlayer: AVAudioPlayer?
    private var accentPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private var currentRepeat: Int = 0
    private var beatDuration: Double {
        60.0 / Double(bpm)
    }
    
    // MARK: - 初期化
    init() {
        setupAudio()
    }
    
    // MARK: - パブリックメソッド
    func start() {
        if isPlaying {
            return
        }
        
        currentBeat = 0
        currentBar = 0
        currentRepeat = 0
        isPlaying = true
        
        startTimer()
    }
    
    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    func restart() {
        stop()
        start()
    }
    
    // MARK: - プライベートメソッド
    private func setupAudio() {
        // AVAudioSessionの設定
        #if os(iOS) || os(tvOS) || os(watchOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("AVAudioSession設定エラー: \(error.localizedDescription)")
        }
        #endif
        
        // サウンドファイルの読み込み（後で実装）
        // 現在はシステムサウンドを使用
        loadSounds()
    }
    
    private func loadSounds() {
        // 現在はシステムサウンドを使用
        guard let clickUrl = Bundle.main.url(forResource: "click", withExtension: "wav"),
              let accentUrl = Bundle.main.url(forResource: "accent", withExtension: "wav") else {
            print("サウンドファイルが見つかりません。後で追加してください。")
            return
        }
        
        do {
            clickPlayer = try AVAudioPlayer(contentsOf: clickUrl)
            clickPlayer?.prepareToPlay()
            
            accentPlayer = try AVAudioPlayer(contentsOf: accentUrl)
            accentPlayer?.prepareToPlay()
        } catch {
            print("AVAudioPlayer初期化エラー: \(error.localizedDescription)")
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        // 最初のビートを即座に再生
        DispatchQueue.main.async { [weak self] in
            self?.tick()
        }
    }
    
    private func tick() {
        // アクセントかどうかを判定
        let isAccent = accentBeats.contains(currentBeat + 1)
        
        // サウンド再生（後で実装）
        if isAccent {
            accentPlayer?.play()
        } else {
            clickPlayer?.play()
        }
        
        // 現在のビート位置を更新
        currentBeat = (currentBeat + 1) % timeSignatureNumerator
        
        // ビートが一周したら小節をカウントアップ
        if currentBeat == 0 {
            currentBar = (currentBar + 1) % totalBars
            
            // 小節が一周したら繰り返し回数をカウントアップ
            if currentBar == 0 {
                currentRepeat += 1
                
                // 自動BPM増加が有効で、設定された繰り返し回数に達した場合
                if autoIncreaseBPM && currentRepeat % repeatCount == 0 {
                    increaseBPM()
                }
                
                // 設定された繰り返し回数に達したら停止
                if currentRepeat >= repeatCount && !autoIncreaseBPM {
                    stop()
                }
            }
        }
    }
    
    private func increaseBPM() {
        guard let increment = bpmIncrement, let max = maxBPM else {
            return
        }
        
        let newBPM = bpm + increment
        
        if newBPM <= max {
            // BPMを更新
            bpm = newBPM
            // タイマーを再スタート
            timer?.invalidate()
            startTimer()
        } else {
            // 最大BPMに達したら停止
            stop()
        }
    }
} 