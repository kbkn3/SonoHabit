import SwiftUI
import SwiftData

struct ItemEditView: View {
    @Bindable var item: PracticeItem
    @Binding var name: String
    @Binding var description: String
    @State var useMetronome: Bool
    @State var useRecording: Bool
    @State var useAudioSource: Bool
    
    var body: some View {
        Form {
            Section("基本情報") {
                TextField("名前", text: $name)
                
                TextField("説明（オプション）", text: $description, axis: .vertical)
                    .lineLimit(5)
            }
            
            Section("使用ツール") {
                Toggle("メトロノームを使用", isOn: $useMetronome)
                Toggle("録音を使用", isOn: $useRecording)
                Toggle("音源再生を使用", isOn: $useAudioSource)
            }
            
            if useMetronome {
                Section("メトロノーム設定") {
                    Text("メトロノーム設定（今後実装）")
                        .foregroundColor(.secondary)
                }
            }
            
            if useRecording {
                Section("録音設定") {
                    Text("録音設定（今後実装）")
                        .foregroundColor(.secondary)
                }
            }
            
            if useAudioSource {
                Section("音源設定") {
                    Text("音源設定（今後実装）")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onChange(of: useMetronome) { _, newValue in
            item.useMetronome = newValue
        }
        .onChange(of: useRecording) { _, newValue in
            item.useRecording = newValue
        }
        .onChange(of: useAudioSource) { _, newValue in
            item.useAudioSource = newValue
        }
    }
} 