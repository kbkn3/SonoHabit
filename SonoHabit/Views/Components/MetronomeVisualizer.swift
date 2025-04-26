import SwiftUI

/// メトロノームの視覚的表現
struct MetronomeVisualizer: View {
    var currentBeat: Int
    var beatsPerMeasure: Int
    var isPlaying: Bool
    var isAccentEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<beatsPerMeasure, id: \.self) { beatIndex in
                BeatCircle(
                    isActive: isPlaying && currentBeat == beatIndex,
                    isFirstBeat: beatIndex == 0 && isAccentEnabled
                )
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.1), value: currentBeat)
    }
}

/// 拍を表す円
struct BeatCircle: View {
    var isActive: Bool
    var isFirstBeat: Bool
    var size: CGFloat = 20
    
    var body: some View {
        Circle()
            .fill(beatColor)
            .frame(width: isActive ? size * 1.3 : size, height: isActive ? size * 1.3 : size)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
    }
    
    private var beatColor: Color {
        if isActive {
            return isFirstBeat ? .red : .blue
        } else {
            return isFirstBeat ? .red.opacity(0.3) : .blue.opacity(0.3)
        }
    }
}

/// メトロノームの拍子表示
struct TimeSignatureDisplay: View {
    var timeSignature: MetronomeSettings.TimeSignature
    
    var body: some View {
        Text(timeSignature.rawValue)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
    }
}

/// BPMテンポ表示
struct TempoDisplay: View {
    var bpm: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("\(bpm)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            Text("BPM")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// プレビュー
struct MetronomeVisualizer_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            MetronomeVisualizer(
                currentBeat: 1,
                beatsPerMeasure: 4,
                isPlaying: true,
                isAccentEnabled: true
            )
            
            TimeSignatureDisplay(timeSignature: .fourFour)
            
            TempoDisplay(bpm: 120)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 