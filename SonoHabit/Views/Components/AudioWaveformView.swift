import SwiftUI

struct AudioWaveformView: View {
    var levels: [Float]
    var activeColor: Color = .blue
    var inactiveColor: Color = Color.blue.opacity(0.2)
    var backgroundColor: Color = Color.clear
    var isRecording: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 2) {
                // バーを描画
                ForEach(0..<levels.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isRecording ? activeColor : inactiveColor)
                        .frame(width: barWidth(for: geometry.size.width), height: barHeight(for: levels[index], height: geometry.size.height))
                        .animation(.easeInOut(duration: 0.1), value: levels[index])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
        }
    }
    
    // バーの幅を計算
    private func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let spacingTotal = CGFloat(levels.count - 1) * 2
        return max(2, (totalWidth - spacingTotal) / CGFloat(levels.count))
    }
    
    // バーの高さを計算
    private func barHeight(for level: Float, height: CGFloat) -> CGFloat {
        let minHeight: CGFloat = 3
        return max(minHeight, CGFloat(level) * height)
    }
}

struct AudioWaveformView_Previews: PreviewProvider {
    static var previews: some View {
        AudioWaveformView(
            levels: [0.1, 0.3, 0.5, 0.7, 0.6, 0.3, 0.2, 0.8, 0.4, 0.5, 0.3, 0.9, 0.5, 0.2],
            isRecording: true
        )
        .frame(height: 50)
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 