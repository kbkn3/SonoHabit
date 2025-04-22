import Foundation
import AVFoundation
import SwiftUI

class AudioPlayer: NSObject, ObservableObject {
    // MARK: - 公開プロパティ
    
    // 再生状態
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    // 再生ファイル情報
    @Published var audioFileURL: URL?
    
    // エラー情報
    @Published var errorMessage: String?
    
    // MARK: - 内部プロパティ
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    // MARK: - 初期化
    override init() {
        super.init()
        setupAudioSession()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - 公開メソッド
    
    /// 指定されたURLのオーディオファイルを再生
    func play(url: URL) {
        // 再生中の場合は停止
        stop()
        
        // 再生準備
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // 成功したら更新
            audioFileURL = url
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            errorMessage = nil
            
            // 再生開始
            startPlayback()
        } catch {
            errorMessage = "再生の準備に失敗しました: \(error.localizedDescription)"
        }
    }
    
    /// 再生を停止
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    /// 再生を一時停止
    func pause() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
            timer?.invalidate()
            timer = nil
        }
    }
    
    /// 一時停止中の再生を再開
    func resume() {
        if !isPlaying, let player = audioPlayer {
            player.play()
            isPlaying = true
            startTimer()
        }
    }
    
    /// 再生位置を設定
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = max(0, min(time, duration))
        currentTime = audioPlayer?.currentTime ?? 0
    }
    
    // MARK: - 内部メソッド
    
    private func setupAudioSession() {
        #if os(iOS) || os(tvOS) || os(watchOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("AudioSessionの設定に失敗: \(error)")
        }
        #endif
    }
    
    private func startPlayback() {
        guard let player = audioPlayer else { return }
        
        player.play()
        isPlaying = true
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isPlaying = false
            self.currentTime = 0
            self.timer?.invalidate()
            self.timer = nil
            
            if !flag {
                self.errorMessage = "再生が正常に終了しませんでした"
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "再生中にエラーが発生しました: \(error.localizedDescription)"
            }
            
            self.isPlaying = false
            self.timer?.invalidate()
            self.timer = nil
        }
    }
} 