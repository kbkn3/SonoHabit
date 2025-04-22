import SwiftUI

struct AudioPlayerView: View {
    @StateObject private var player = AudioPlayer()
    
    let url: URL
    let title: String
    
    init(url: URL, title: String) {
        self.url = url
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // タイトルと時間表示
            HStack {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(timeString(from: player.currentTime))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium) +
                Text(" / ") +
                Text(timeString(from: player.duration))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // シークバー
            Slider(
                value: Binding(
                    get: { player.currentTime },
                    set: { player.seek(to: $0) }
                ),
                in: 0...max(0.1, player.duration)
            )
            .accentColor(.blue)
            
            // 再生コントロール
            HStack {
                // 10秒戻る
                Button {
                    player.seek(to: max(0, player.currentTime - 10))
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                // 再生/一時停止
                Button {
                    if player.isPlaying {
                        player.pause()
                    } else {
                        if player.audioFileURL != nil {
                            player.resume()
                        } else {
                            player.play(url: url)
                        }
                    }
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                // 10秒進む
                Button {
                    player.seek(to: min(player.duration, player.currentTime + 10))
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            
            // エラー表示
            if let errorMessage = player.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
        .onAppear {
            player.play(url: url)
        }
        .onDisappear {
            player.stop()
        }
    }
    
    // 時間表示を整形
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    // プレビュー用の一時的なURLを作成（実際には存在しないため実行時エラーとなる）
    let previewURL = URL(string: "file:///tmp/preview.m4a")!
    
    return AudioPlayerView(url: previewURL, title: "テスト録音")
        .padding()
} 