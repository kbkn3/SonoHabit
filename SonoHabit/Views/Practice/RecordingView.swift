import SwiftUI

struct RecordingView: View {
    @StateObject private var recorder = AudioRecorder()
    @State private var showDeleteAlert = false

    let item: PracticeItem
    var onRecordingComplete: ((URL) -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            // タイトルと時間表示
            HStack {
                Text("録音")
                    .font(.headline)

                Spacer()

                Text(timeString(from: recorder.recordingTime))
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(recorder.isRecording ? .red : .primary)
            }

            // 波形表示
            AudioWaveformView(
                levels: recorder.recordingLevels,
                activeColor: .red,
                inactiveColor: Color.red.opacity(0.2),
                isRecording: recorder.isRecording
            )
            .frame(height: 60)
            .padding(.vertical, 8)

            // 録音コントロール
            HStack(spacing: 40) {
                if recorder.isDoneRecording {
                    // 録音完了後のコントロール
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }

                    Button {
                        if let url = recorder.recordedFileURL {
                            onRecordingComplete?(url)
                        }
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    }
                } else {
                    // 録音前または録音中のコントロール
                    Button {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else {
                            recorder.startRecording()
                        }
                    } label: {
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.largeTitle)
                            .foregroundColor(recorder.isRecording ? .red : .accentColor)
                    }
                }
            }
            .padding(.vertical, 8)

            // エラーメッセージの表示
            if let errorMessage = recorder.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
        .alert("録音を削除しますか？", isPresented: $showDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                recorder.deleteRecording()
            }
        } message: {
            Text("この操作は元に戻せません。")
        }
    }

    // 時間表示を整形
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

#Preview {
    let item = PracticeItem(
        name: "テスト録音",
        description: "録音テスト用アイテム"
    )

    return RecordingView(item: item)
        .padding()
}
