import Foundation
import AVFoundation

/// メトロノームエンジン - 正確なタイミングでクリック音を再生する
class MetronomeEngine: ObservableObject {
    // MARK: - プロパティ
    @Published var isPlaying = false
    @Published var currentBpm: Int = 120
    @Published var currentTimeSignature: MetronomeSettings.TimeSignature = .fourFour
    @Published var currentBeat: Int = 0
    @Published var currentMeasure: Int = 0
    @Published var isAccentEnabled: Bool = true
    @Published var clickSound: MetronomeSettings.ClickSound = .click
    
    // メトロノーム設定
    private var measuresCount: Int = 4
    private var repetitionCount: Int = 0  // 0は無限繰り返し
    private var completedRepetitions: Int = 0
    
    // BPM自動段階上昇設定
    private var isProgressionEnabled: Bool = false
    private var startBpm: Int = 120
    private var targetBpm: Int? = nil
    private var bpmIncrement: Int = 5
    private var incrementMeasures: Int = 4
    private var measuresPlayedAtCurrentBpm: Int = 0
    
    // オーディオ関連
    private var audioEngine: AVAudioEngine?
    private var clickPlayer: AVAudioPlayer?
    private var accentPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var lastBeatTime: TimeInterval = 0
    
    // MARK: - 初期化
    init() {
        setupAudio()
    }
    
    // MARK: - メトロノーム制御メソッド
    
    /// メトロノームを開始
    func start() {
        guard !isPlaying else { return }
        
        setupAudio()
        resetCounters()
        
        // BPM自動上昇の初期化
        if isProgressionEnabled {
            currentBpm = startBpm
        }
        
        isPlaying = true
        lastBeatTime = Date().timeIntervalSince1970
        scheduleNextBeat()
    }
    
    /// メトロノームを停止
    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    /// メトロノーム設定を適用
    func applySettings(from settings: MetronomeSettings) {
        currentBpm = settings.bpm
        currentTimeSignature = settings.timeSignature
        measuresCount = settings.measuresCount
        repetitionCount = settings.repetitionCount
        isAccentEnabled = settings.isAccentEnabled
        clickSound = settings.clickSound
        
        // BPM自動段階上昇設定
        isProgressionEnabled = settings.isProgressionEnabled
        if isProgressionEnabled {
            startBpm = settings.bpm
            targetBpm = settings.targetBpm
            bpmIncrement = settings.bpmIncrement
            incrementMeasures = settings.incrementMeasures
        }
        
        // 再生中なら設定を反映
        if isPlaying {
            stop()
            start()
        }
    }
    
    // MARK: - プライベートメソッド
    
    /// オーディオエンジンのセットアップ
    private func setupAudio() {
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("オーディオセッションの設定エラー: \(error.localizedDescription)")
        }
        
        // リソースがない場合は音声ファイルが追加されていないと想定
        guard let clickURL = Bundle.main.url(forResource: clickSound.filename, withExtension: "wav"),
              let accentURL = Bundle.main.url(forResource: clickSound.accentFilename, withExtension: "wav") else {
            print("メトロノーム音ファイルが見つかりません")
            return
        }
        
        do {
            clickPlayer = try AVAudioPlayer(contentsOf: clickURL)
            clickPlayer?.prepareToPlay()
            
            accentPlayer = try AVAudioPlayer(contentsOf: accentURL)
            accentPlayer?.prepareToPlay()
        } catch {
            print("メトロノーム音声プレーヤーの初期化エラー: \(error.localizedDescription)")
        }
    }
    
    /// カウンターをリセット
    private func resetCounters() {
        currentBeat = 0
        currentMeasure = 0
        completedRepetitions = 0
        measuresPlayedAtCurrentBpm = 0
    }
    
    /// 次のビートをスケジュール
    private func scheduleNextBeat() {
        // BPMから拍間の間隔（秒）を計算
        let beatInterval = 60.0 / Double(currentBpm)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: false) { [weak self] _ in
            self?.playBeat()
            self?.scheduleNextBeat()
        }
    }
    
    /// ビート音の再生
    private func playBeat() {
        let beatsPerMeasure = currentTimeSignature.beatsPerMeasure
        
        // 拍子の1拍目かどうか
        let isFirstBeat = currentBeat == 0
        
        // アクセント音か通常音かを選択
        if isFirstBeat && isAccentEnabled {
            accentPlayer?.play()
            accentPlayer?.currentTime = 0
        } else {
            clickPlayer?.play()
            clickPlayer?.currentTime = 0
        }
        
        // ビートと小節のカウントを更新
        currentBeat = (currentBeat + 1) % beatsPerMeasure
        
        // 小節の最後の拍で、次が1拍目なら小節カウントを進める
        if currentBeat == 0 {
            currentMeasure = (currentMeasure + 1) % measuresCount
            measuresPlayedAtCurrentBpm += 1
            
            // 小節の区切りでのBPM自動上昇チェック
            checkAndIncreaseBpm()
            
            // 小節が一周したら繰り返し回数をカウント
            if currentMeasure == 0 {
                if repetitionCount > 0 {
                    completedRepetitions += 1
                    if completedRepetitions >= repetitionCount {
                        stop()
                    }
                }
            }
        }
    }
    
    /// BPMの自動上昇をチェックし実行
    private func checkAndIncreaseBpm() {
        guard isProgressionEnabled, let targetBpm = targetBpm else { return }
        
        // 指定された小節数を超えたらBPMを上げる
        if measuresPlayedAtCurrentBpm >= incrementMeasures && currentBpm < targetBpm {
            currentBpm += bpmIncrement
            
            // 目標BPMを超えないようにする
            if currentBpm > targetBpm {
                currentBpm = targetBpm
            }
            
            // 測定リセット
            measuresPlayedAtCurrentBpm = 0
        }
    }
} 