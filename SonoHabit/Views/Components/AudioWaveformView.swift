import SwiftUI

/// 音声レベルに応じた波形を表示するビュー
struct AudioWaveformView: View {
    var level: Float // 0.0-1.0の範囲
    var color: Color = .blue
    var barCount: Int = 20
    var minBarHeight: CGFloat = 3
    var spacing: CGFloat = 2
    var direction: Direction = .up
    
    enum Direction {
        case up     // 下から上へ
        case center // 中央から上下に
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    // ランダムな高さの変動を追加してより自然な波形に
                    let randomFactor = Double.random(in: 0.85...1.15)
                    let heightPercentage = getHeightPercentage(for: index, of: barCount) * randomFactor
                    let displayLevel = CGFloat(level) * heightPercentage
                    
                    switch direction {
                    case .up:
                        Rectangle()
                            .fill(color.opacity(heightPercentage * 0.8 + 0.2))
                            .frame(
                                width: (geometry.size.width - CGFloat(barCount - 1) * spacing) / CGFloat(barCount),
                                height: max(minBarHeight, displayLevel * geometry.size.height)
                            )
                            .cornerRadius(2)
                    case .center:
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(color.opacity(heightPercentage * 0.8 + 0.2))
                                .frame(
                                    width: (geometry.size.width - CGFloat(barCount - 1) * spacing) / CGFloat(barCount),
                                    height: max(minBarHeight, displayLevel * geometry.size.height / 2)
                                )
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(color.opacity(heightPercentage * 0.8 + 0.2))
                                .frame(
                                    width: (geometry.size.width - CGFloat(barCount - 1) * spacing) / CGFloat(barCount),
                                    height: max(minBarHeight, displayLevel * geometry.size.height / 2)
                                )
                                .cornerRadius(2)
                        }
                    }
                }
            }
        }
    }
    
    /// 各バーの高さ比率を計算する（中央が高くなるベル曲線状）
    private func getHeightPercentage(for index: Int, of total: Int) -> Double {
        let normalizedPosition = Double(index) / Double(total - 1) // 0から1の範囲
        let centerPosition = 0.5
        
        // 中央からの距離に基づいてガウス関数で高さを計算
        let distance = abs(normalizedPosition - centerPosition)
        let variance = 0.15 // 曲線の広がり具合
        let height = exp(-distance * distance / (2 * variance * variance))
        
        return height
    }
}

/// レベルメーターを表示するビュー
struct LevelMeterView: View {
    var level: Float // 0.0-1.0の範囲
    var width: CGFloat = 200
    var height: CGFloat = 20
    var backgroundColor: Color = Color.gray.opacity(0.3)
    var foregroundColor: Color = .blue
    var warningLevel: Float = 0.8
    var peakLevel: Float = 0.95
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 背景
            RoundedRectangle(cornerRadius: height / 4)
                .fill(backgroundColor)
                .frame(width: width, height: height)
            
            // レベル表示
            RoundedRectangle(cornerRadius: height / 4)
                .fill(levelColor)
                .frame(width: width * CGFloat(level), height: height)
        }
    }
    
    /// レベルに応じた色を返す
    private var levelColor: Color {
        if level >= peakLevel {
            return .red
        } else if level >= warningLevel {
            return .orange
        } else {
            return foregroundColor
        }
    }
}

/// 録音の経過時間を表示するビュー
struct RecordingTimerView: View {
    var elapsedTime: TimeInterval
    var textColor: Color = .primary
    
    var body: some View {
        Text(formattedTime)
            .font(.system(.title2, design: .monospaced))
            .foregroundColor(textColor)
    }
    
    private var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioWaveformView(level: 0.7)
            .frame(height: 60)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        
        LevelMeterView(level: 0.7)
            .padding()
        
        RecordingTimerView(elapsedTime: 125)
            .padding()
    }
    .padding()
    .previewLayout(.sizeThatFits)
} 