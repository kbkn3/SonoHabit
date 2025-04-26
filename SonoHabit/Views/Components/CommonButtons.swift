import SwiftUI

/// 再生・停止ボタン
struct PlayStopButton: View {
    var isPlaying: Bool
    var action: () -> Void
    var size: CGFloat = 60
    var color: Color = .blue
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: size, height: size)
                
                if isPlaying {
                    // 停止アイコン
                    Rectangle()
                        .fill(color)
                        .frame(width: size * 0.3, height: size * 0.3)
                } else {
                    // 再生アイコン
                    Image(systemName: "play.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundColor(color)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 数値調整ボタン
struct NumberAdjustButton: View {
    var value: Int
    var range: ClosedRange<Int>
    var step: Int = 1
    var onChange: (Int) -> Void
    var label: String
    var unit: String = ""
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    let newValue = max(range.lowerBound, value - step)
                    if newValue != value {
                        onChange(newValue)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Text("\(value)\(unit)")
                    .font(.title2)
                    .frame(minWidth: 60)
                    .monospacedDigit()
                
                Button(action: {
                    let newValue = min(range.upperBound, value + step)
                    if newValue != value {
                        onChange(newValue)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// トグルスイッチ
struct CustomToggle: View {
    var isOn: Bool
    var action: (Bool) -> Void
    var label: String
    var icon: String? = nil
    
    var body: some View {
        HStack {
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.headline)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { action($0) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

/// プレビュー
struct CommonButtons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PlayStopButton(isPlaying: false, action: {})
            PlayStopButton(isPlaying: true, action: {})
            
            NumberAdjustButton(
                value: 120,
                range: 40...240,
                onChange: { _ in },
                label: "BPM",
                unit: " bpm"
            )
            
            CustomToggle(
                isOn: true,
                action: { _ in },
                label: "アクセント",
                icon: "speaker.wave.2"
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 