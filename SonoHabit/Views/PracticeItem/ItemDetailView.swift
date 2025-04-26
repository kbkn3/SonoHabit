import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: PracticeItem
    @State private var showEditItem = false
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    @State private var showMetronomeView = false
    @State private var showMetronomeSettings = false
    
    // メトロノームエンジン
    @StateObject private var metronomeEngine = MetronomeEngine()
    
    var body: some View {
        Form {
            Section("基本情報") {
                VStack(alignment: .leading) {
                    Text("作成日: \(formattedDate(item.createdAt))")
                        .font(.caption)
                    Text("更新日: \(formattedDate(item.updatedAt))")
                        .font(.caption)
                }
                
                if !item.description.isEmpty {
                    Section("説明") {
                        Text(item.description)
                    }
                }
            }
            
            Section("使用ツール") {
                LabeledContent("メトロノーム", value: item.useMetronome ? "使用" : "未使用")
                LabeledContent("録音", value: item.useRecording ? "使用" : "未使用")
                LabeledContent("音源再生", value: item.useAudioSource ? "使用" : "未使用")
            }
            
            if item.useMetronome {
                Section("メトロノーム設定") {
                    if let settings = item.metronomeSettings {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("テンポ: \(settings.bpm) BPM")
                                Spacer()
                                Text("拍子: \(settings.timeSignature.rawValue)")
                            }
                            
                            HStack {
                                Text("小節数: \(settings.measuresCount)")
                                Spacer()
                                Text("アクセント: \(settings.isAccentEnabled ? "あり" : "なし")")
                            }
                            
                            if settings.isProgressionEnabled, let targetBpm = settings.targetBpm {
                                Text("BPM自動上昇: \(settings.bpm) → \(targetBpm) BPM (+\(settings.bpmIncrement), \(settings.incrementMeasures)小節ごと)")
                                    .font(.caption)
                            }
                            
                            Button("設定を編集") {
                                showMetronomeSettings = true
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        Text("メトロノーム設定が未作成です")
                        Button("設定を作成") {
                            createMetronomeSettings()
                            showMetronomeSettings = true
                        }
                    }
                }
            }
            
            Section {
                if item.useMetronome {
                    Button("メトロノームで練習開始") {
                        if item.metronomeSettings == nil {
                            createMetronomeSettings()
                        }
                        showMetronomeView = true
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                } else {
                    Button("練習開始") {
                        // 練習画面へ遷移する処理（後で実装）
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .navigationTitle(item.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editedName = item.name
                    editedDescription = item.description
                    showEditItem = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditItem) {
            NavigationStack {
                ItemEditView(
                    item: item,
                    name: $editedName,
                    description: $editedDescription,
                    useMetronome: item.useMetronome,
                    useRecording: item.useRecording,
                    useAudioSource: item.useAudioSource
                )
                .navigationTitle("項目を編集")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") {
                            showEditItem = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            saveChanges()
                            showEditItem = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
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
        .fullScreenCover(isPresented: $showMetronomeView) {
            NavigationStack {
                if let settings = item.metronomeSettings {
                    ZStack {
                        Color(UIColor.systemBackground).ignoresSafeArea()
                        
                        VStack {
                            Text(item.name)
                                .font(.title)
                                .padding()
                            
                            MetronomeView(settings: settings, engine: metronomeEngine, onSettingsChanged: { updatedSettings in
                                updateMetronomeSettings(updatedSettings)
                            })
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完了") {
                                metronomeEngine.stop()
                                showMetronomeView = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        item.name = editedName
        item.description = editedDescription
        DataManager.shared.updateItem(item, context: modelContext)
    }
    
    private func createMetronomeSettings() {
        let settings = MetronomeSettings()
        item.metronomeSettings = settings
        DataManager.shared.updateItem(item, context: modelContext)
    }
    
    private func updateMetronomeSettings(_ settings: MetronomeSettings) {
        item.metronomeSettings = settings
        DataManager.shared.updateItem(item, context: modelContext)
    }
} 