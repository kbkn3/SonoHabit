import SwiftUI

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeEngine()

    let item: PracticeItem

    init(item: PracticeItem) {
        self.item = item
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("BPM")
                    .font(.headline)

                Spacer()

                Text("\(metronome.bpm)")
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            HStack {
                Button {
                    metronome.bpm = max(40, metronome.bpm - 5)
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title)
                }
                .buttonStyle(.borderless)

                Slider(value: Binding(
                    get: { Double(metronome.bpm) },
                    set: { metronome.bpm = Int($0) }
                ), in: 40...240, step: 1)

                Button {
                    metronome.bpm = min(240, metronome.bpm + 5)
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                }
                .buttonStyle(.borderless)
            }

            HStack {
                Text("\(metronome.timeSignatureNumerator)/\(metronome.timeSignatureDenominator)")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                // メトロノームの現在位置
                HStack(spacing: 4) {
                    ForEach(0..<metronome.timeSignatureNumerator, id: \.self) { beatIndex in
                        Circle()
                            .fill(beatIndex == metronome.currentBeat ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }

                Spacer()

                Text("小節: \(metronome.currentBar + 1)/\(metronome.totalBars)")
                    .font(.subheadline)
            }

            // 制御ボタン
            HStack(spacing: 40) {
                Button {
                    metronome.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .disabled(!metronome.isPlaying)

                Button {
                    if metronome.isPlaying {
                        metronome.stop()
                    } else {
                        metronome.start()
                    }
                } label: {
                    Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                }

                Button {
                    metronome.restart()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                }
                .disabled(!metronome.isPlaying)
            }
            .padding(.vertical)

            if metronome.autoIncreaseBPM, let maxBPM = metronome.maxBPM, let increment = metronome.bpmIncrement {
                VStack(alignment: .leading, spacing: 4) {
                    Text("自動BPM増加: 有効")
                        .font(.subheadline)

                    Text("最大: \(maxBPM)BPM / 増加量: \(increment)BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ProgressView(value: Double(metronome.bpm), total: Double(maxBPM))
                        .progressViewStyle(.linear)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
        .onAppear {
            // 練習項目の設定をメトロノームに反映
            metronome.bpm = item.bpm
            metronome.timeSignatureNumerator = item.timeSignatureNumerator
            metronome.timeSignatureDenominator = item.timeSignatureDenominator
            metronome.totalBars = item.totalBars
            metronome.repeatCount = item.repeatCount
            metronome.autoIncreaseBPM = item.autoIncreaseBPM
            metronome.maxBPM = item.maxBPM
            metronome.bpmIncrement = item.bpmIncrement
        }
    }
}

#Preview {
    let item = PracticeItem(
        name: "スケール練習",
        bpm: 100,
        autoIncreaseBPM: true,
        maxBPM: 120,
        bpmIncrement: 5
    )

    return MetronomeView(item: item)
        .padding()
}
