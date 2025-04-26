import Foundation
import AVFoundation
import Combine

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
    @Published var progressPercentage: Double = 0.0
    
    // メトロノーム設定
    private var measuresCount: Int = 4
    private var repetitionCount: Int = 0  // 0は無限繰り返し
    private var completedRepetitions: Int = 0
    
    // アクセント設定
    private var accentPattern: MetronomeSettings.AccentPatternType = .standard
    private var customAccentPositions: [Int]? = nil
    private var activeAccentPattern: [Bool] = []
    
    // BPM自動段階上昇設定
    private var isProgressionEnabled: Bool = false
    private var startBpm: Int = 120
    private var targetBpm: Int? = nil
    private var bpmIncrement: Int = 5
    private var incrementInterval: MetronomeSettings.ProgressionIntervalType = .measures
    private var incrementIntervalValue: Int = 4
    private var measuresPlayedAtCurrentBpm: Int = 0
    private var lastBpmChangeTime: Date?
    
    // サービス
    private let accentService = MetronomeAccentService()
    private let progressionService = BpmProgressionService()
    private var cancellables = Set<AnyCancellable>()
    
    // オーディオ関連
    private var audioEngine: AVAudioEngine?
    private var clickPlayer: AVAudioPlayer?
    private var accentPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var lastBeatTime: TimeInterval = 0
    
    // MARK: - 初期化
    init() {
        setupAudio()
        setupSubscriptions()
    }
    
    // MARK: - メトロノーム制御メソッド
    
    /// メトロノームを開始
    func start() {
        guard !isPlaying else { return }
        
        setupAudio()
        resetCounters()
        
        // アクセントパターンの生成
        updateAccentPattern()
        
        // BPM自動上昇の初期化
        if isProgressionEnabled, let targetBpm = targetBpm {
            if incrementInterval == .seconds {
                // 秒数ベースのBPM変更はBpmProgressionServiceを使用
                progressionService.configure(
                    startBpm: startBpm,
                    targetBpm: targetBpm,
                    stepValue: bpmIncrement,
                    stepDuration: TimeInterval(incrementIntervalValue)
                )
                progressionService.start()
                currentBpm = startBpm
                lastBpmChangeTime = Date()
            } else {
                // 小節ベースのBPM変更は内部で管理
                currentBpm = startBpm
            }
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
        
        if isProgressionEnabled && incrementInterval == .seconds {
            progressionService.stop()
        }
    }
    
    /// メトロノーム設定を適用
    func applySettings(from settings: MetronomeSettings) {
        currentBpm = settings.bpm
        currentTimeSignature = settings.timeSignature
        measuresCount = settings.measuresCount
        repetitionCount = settings.repetitionCount
        isAccentEnabled = settings.isAccentEnabled
        clickSound = settings.clickSound
        
        // アクセント設定
        accentPattern = settings.accentPattern
        customAccentPositions = settings.customAccentPositions
        
        // BPM自動段階上昇設定
        isProgressionEnabled = settings.isProgressionEnabled
        if isProgressionEnabled {
            startBpm = settings.bpm
            targetBpm = settings.targetBpm
            bpmIncrement = settings.bpmIncrement
            incrementInterval = settings.incrementInterval
            incrementIntervalValue = settings.incrementIntervalValue
        }
        
        // アクセントパターン更新
        updateAccentPattern()
        
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
        guard let clickURL = Bundle.main.url(forResource: clickSound.normalFilename, withExtension: "wav"),
              let accentURL = Bundle.main.url(forResource: clickSound.accentFilename, withExtension: "wav") else {
            print("メトロノーム音ファイルが見つかりません: \(clickSound.normalFilename).wav, \(clickSound.accentFilename).wav")
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
    
    /// Combine購読の設定
    private func setupSubscriptions() {
        // BPM変更の購読
        progressionService.bpmPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newBpm in
                self?.currentBpm = newBpm
            }
            .store(in: &cancellables)
        
        // 進行状況の購読
        progressionService.progressPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                self?.progressPercentage = progress
            }
            .store(in: &cancellables)
    }
    
    /// カウンターをリセット
    private func resetCounters() {
        currentBeat = 0
        currentMeasure = 0
        completedRepetitions = 0
        measuresPlayedAtCurrentBpm = 0
        progressPercentage = 0.0
        lastBpmChangeTime = nil
    }
    
    /// アクセントパターンを更新
    private func updateAccentPattern() {
        let beatsPerMeasure = currentTimeSignature.beatsPerMeasure
        
        switch accentPattern {
        case .standard:
            activeAccentPattern = accentService.generateAccentPattern(beatsPerMeasure: beatsPerMeasure, pattern: .standard)
        case .offBeat:
            activeAccentPattern = accentService.generateAccentPattern(beatsPerMeasure: beatsPerMeasure, pattern: .offBeat)
        case .custom:
            activeAccentPattern = accentService.generateAccentPattern(
                beatsPerMeasure: beatsPerMeasure,
                pattern: .custom,
                customPattern: customAccentPositions
            )
        }
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
        
        // アクセントパターンに基づいてアクセント音かどうかを判断
        let shouldPlayAccent = isAccentEnabled && 
            currentBeat < activeAccentPattern.count && 
            activeAccentPattern[currentBeat]
        
        // アクセント音か通常音かを選択
        if shouldPlayAccent {
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
            
            // 小節の区切りでのBPM自動上昇チェック（小節ベースの場合）
            if isProgressionEnabled && incrementInterval == .measures {
                checkAndIncreaseBpm()
            }
            
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
        
        // 秒数ベースのBPM変更の進行状況を更新（独自に計算）
        if isProgressionEnabled && incrementInterval == .seconds && lastBpmChangeTime != nil {
            updateProgressionPercentage()
        }
    }
    
    /// BPMの自動上昇をチェックし実行（小節ベース）
    private func checkAndIncreaseBpm() {
        guard let targetBpm = targetBpm else { return }
        
        // 指定された小節数を超えたらBPMを上げる
        if measuresPlayedAtCurrentBpm >= incrementIntervalValue {
            // 目標BPMに達していない場合のみ変更
            if (targetBpm > startBpm && currentBpm < targetBpm) || 
               (targetBpm < startBpm && currentBpm > targetBpm) {
                
                // 増加または減少
                if targetBpm > startBpm {
                    currentBpm += bpmIncrement
                    // 目標BPMを超えないようにする
                    if currentBpm > targetBpm {
                        currentBpm = targetBpm
                    }
                } else {
                    currentBpm -= bpmIncrement
                    // 目標BPMを下回らないようにする
                    if currentBpm < targetBpm {
                        currentBpm = targetBpm
                    }
                }
                
                // 進行状況の更新
                updateProgressionPercentage()
            }
            
            // 測定リセット
            measuresPlayedAtCurrentBpm = 0
        }
    }
    
    /// BPMプログレッションの進行状況を更新
    private func updateProgressionPercentage() {
        guard let targetBpm = targetBpm else { return }
        
        let totalChange = abs(targetBpm - startBpm)
        let currentChange = abs(targetBpm - currentBpm)
        
        if totalChange == 0 {
            progressPercentage = 100.0
        } else {
            progressPercentage = Double(totalChange - currentChange) / Double(totalChange) * 100.0
        }
    }
} 