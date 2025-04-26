import SwiftUI
import SwiftData

struct ItemEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: PracticeItem
    @Binding var name: String
    @Binding var description: String
    @State var useMetronome: Bool
    @State var useRecording: Bool
    @State var useAudioSource: Bool
    @State private var showMetronomeSettings = false
    
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
                    if let settings = item.metronomeSettings {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("テンポ: \(settings.bpm) BPM")
                                Spacer()
                                Text("拍子: \(settings.timeSignature.rawValue)")
                            }
                            
                            HStack {
                                if settings.isAccentEnabled {
                                    Label(
                                        "アクセント: \(settings.accentPattern.displayName)",
                                        systemImage: "speaker.wave.2"
                                    )
                                    .font(.caption)
                                } else {
                                    Label(
                                        "アクセント: オフ",
                                        systemImage: "speaker.slash"
                                    )
                                    .font(.caption)
                                }
                                
                                Spacer()
                                
                                Text("小節数: \(settings.measuresCount)")
                                    .font(.caption)
                            }
                            
                            if settings.isProgressionEnabled, let targetBpm = settings.targetBpm {
                                let direction = targetBpm > settings.bpm ? "上昇" : "下降"
                                HStack {
                                    Label(
                                        "BPM変化: \(settings.bpm)→\(targetBpm)",
                                        systemImage: "arrow.up.forward"
                                    )
                                    .font(.caption)
                                    
                                    Spacer()
                                    
                                    Text("\(settings.bpmIncrement)BPM/\(settings.incrementIntervalValue)\(settings.incrementInterval == .measures ? "小節" : "秒")")
                                        .font(.caption)
                                }
                            }
                            
                            Button("設定を編集") {
                                showMetronomeSettings = true
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        HStack {
                            Text("メトロノーム設定がありません")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("作成") {
                                createMetronomeSettings()
                                showMetronomeSettings = true
                            }
                        }
                    }
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
            
            // メトロノーム設定の処理
            if newValue {
                // 有効化時に設定がなければ作成
                if item.metronomeSettings == nil {
                    createMetronomeSettings()
                }
            } else {
                // 無効化時に設定を削除
                item.metronomeSettings = nil
            }
        }
        .onChange(of: useRecording) { _, newValue in
            item.useRecording = newValue
        }
        .onChange(of: useAudioSource) { _, newValue in
            item.useAudioSource = newValue
        }
        .sheet(isPresented: $showMetronomeSettings) {
            NavigationStack {
                if let settings = item.metronomeSettings {
                    MetronomeView(settings: settings, onSettingsChanged: { updatedSettings in
                        updateMetronomeSettings(updatedSettings)
                    })
                    .navigationTitle("メトロノーム設定")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完了") {
                                showMetronomeSettings = false
                            }
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    private func createMetronomeSettings() {
        let settings = MetronomeSettings()
        item.metronomeSettings = settings
    }
    
    private func updateMetronomeSettings(_ settings: MetronomeSettings) {
        item.metronomeSettings = settings
    }
} 