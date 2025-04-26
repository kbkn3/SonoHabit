import Foundation
import Combine

/// メトロノームのBPM自動段階上昇機能を管理するサービス
class BpmProgressionService {
    // プログレッションの状態を管理するプロパティ
    private var timer: Timer?
    private var currentBpm: Int
    private var targetBpm: Int
    private var stepValue: Int
    private var stepDuration: TimeInterval
    private var isActive = false
    
    // BPM変更通知用のパブリッシャー
    var bpmPublisher = PassthroughSubject<Int, Never>()
    
    // 進行状況を％で表すパブリッシャー（0-100）
    var progressPublisher = PassthroughSubject<Double, Never>()
    
    // 初期化
    init(startBpm: Int = 60, targetBpm: Int = 120, stepValue: Int = 5, stepDuration: TimeInterval = 30.0) {
        self.currentBpm = startBpm
        self.targetBpm = targetBpm
        self.stepValue = stepValue
        self.stepDuration = stepDuration
    }
    
    /// BPMプログレッションの設定を構成する
    /// - Parameters:
    ///   - startBpm: 開始BPM
    ///   - targetBpm: 目標BPM
    ///   - stepValue: 1ステップあたりのBPM増加量
    ///   - stepDuration: 1ステップあたりの時間（秒）
    func configure(startBpm: Int, targetBpm: Int, stepValue: Int, stepDuration: TimeInterval) {
        stop() // 既存のプログレッションがあれば停止
        
        self.currentBpm = startBpm
        self.targetBpm = targetBpm
        self.stepValue = stepValue
        self.stepDuration = stepDuration
    }
    
    /// BPMプログレッションを開始する
    func start() {
        guard !isActive else { return }
        guard currentBpm != targetBpm else { return }
        
        isActive = true
        
        // 現在のBPMを発行
        bpmPublisher.send(currentBpm)
        
        // 現在の進行状況を発行
        updateProgress()
        
        // BPMの方向（増加または減少）を決定
        let isIncreasing = targetBpm > currentBpm
        
        // タイマーを設定
        timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 次のBPM値を計算
            if isIncreasing {
                self.currentBpm += self.stepValue
                
                // 目標BPMを超えないようにする
                if self.currentBpm >= self.targetBpm {
                    self.currentBpm = self.targetBpm
                    self.stop()
                }
            } else {
                self.currentBpm -= self.stepValue
                
                // 目標BPMを下回らないようにする
                if self.currentBpm <= self.targetBpm {
                    self.currentBpm = self.targetBpm
                    self.stop()
                }
            }
            
            // 新しいBPMを発行
            self.bpmPublisher.send(self.currentBpm)
            
            // 進行状況を更新
            self.updateProgress()
        }
    }
    
    /// BPMプログレッションを停止する
    func stop() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
    
    /// 現在のBPMを取得する
    func getCurrentBpm() -> Int {
        return currentBpm
    }
    
    /// プログレッションがアクティブかどうかを確認する
    func isProgressing() -> Bool {
        return isActive
    }
    
    /// 進行状況を更新して発行する
    private func updateProgress() {
        let totalChange = abs(targetBpm - currentBpm)
        let initialChange = abs(targetBpm - currentBpm)
        
        if initialChange == 0 {
            progressPublisher.send(100.0)
            return
        }
        
        let progressPercentage = Double(initialChange - totalChange) / Double(initialChange) * 100.0
        progressPublisher.send(progressPercentage)
    }
    
    /// プログレッションの残り時間を計算する（秒）
    func getRemainingTime() -> TimeInterval {
        guard isActive else { return 0 }
        
        let remainingSteps = ceil(Double(abs(targetBpm - currentBpm)) / Double(stepValue))
        return remainingSteps * stepDuration
    }
    
    /// プログレッションの合計時間を計算する（秒）
    func getTotalTime() -> TimeInterval {
        let totalSteps = ceil(Double(abs(targetBpm - currentBpm)) / Double(stepValue))
        return totalSteps * stepDuration
    }
    
    /// プログレッション設定の文字列表現を取得する
    func getDescription() -> String {
        let direction = targetBpm > currentBpm ? "上昇" : "下降"
        let totalTime = Int(getTotalTime())
        return "\(currentBpm)から\(targetBpm)まで\(direction)（\(stepValue)BPM/\(Int(stepDuration))秒、合計約\(totalTime)秒）"
    }
} 