import SwiftUI
import SwiftData
import AVFoundation

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: PracticeItem
    @State private var showEditItem = false
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    @State private var showMetronomeView = false
    @State private var showMetronomeSettings = false
    @State private var showRecordingView = false
    @State private var showRecordings = false
    @State private var selectedRecording: RecordingInfo?
    
    // メトロノームエンジン
    @StateObject private var metronomeEngine = MetronomeEngine()
    
    // 録音関連
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var inputManager = AudioInputManager()
    @Query private var recordings: [RecordingInfo] = []
    
    // 録音一覧クエリ用の初期化
    init(item: PracticeItem) {
        self.item = item
        
        // 録音リストのクエリを設定
        let descriptor = FetchDescriptor<RecordingInfo>(
            predicate: #Predicate { recording in
                recording.practiceItem?.id == item.id
            },
            sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
        )
        self._recordings = Query(descriptor)
    }
    
    var body: some View {
        Form {
            Section("基本情報") {
                VStack(alignment: .leading) {
                    Text("作成日: \(formattedDate(item.createdAt))")
                        .font(.caption)
                    Text("更新日: \(formattedDate(item.updatedAt))")
                        .font(.caption)
                }
                
                if !item.itemDescription.isEmpty {
                    Section("説明") {
                        Text(item.itemDescription)
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
                                let intervalText = settings.incrementInterval == .measures ? 
                                    "\(settings.incrementIntervalValue)小節" : 
                                    "\(settings.incrementIntervalValue)秒"
                                
                                Text("BPM自動変化: \(settings.bpm) → \(targetBpm) BPM (+\(settings.bpmIncrement), \(intervalText)ごと)")
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
            
            if item.useRecording {
                Section("録音") {
                    HStack {
                        Text("\(recordings.count)件の録音")
                        
                        Spacer()
                        
                        Button("一覧表示") {
                            showRecordings = true
                        }
                        .disabled(recordings.isEmpty)
                    }
                    
                    Button(action: {
                        showRecordingView = true
                    }) {
                        Label("新規録音", systemImage: "mic")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
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
                    editedDescription = item.itemDescription
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
        .sheet(isPresented: $showRecordingView) {
            NavigationStack {
                RecordingView(
                    practiceItem: item,
                    audioRecorder: audioRecorder,
                    inputManager: inputManager
                )
                .navigationTitle("録音")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完了") {
                            showRecordingView = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showRecordings) {
            NavigationStack {
                RecordingListView(recordings: recordings, item: item)
                    .navigationTitle("録音一覧")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完了") {
                                showRecordings = false
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
                        Color(.background).ignoresSafeArea()
                        
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
        item.itemDescription = editedDescription
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

/// 録音一覧表示ビュー
struct RecordingListView: View {
    @Environment(\.modelContext) private var modelContext
    let recordings: [RecordingInfo]
    let item: PracticeItem
    @State private var selectedRecording: RecordingInfo?
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        List {
            if recordings.isEmpty {
                Text("録音がありません")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(recordings) { recording in
                    RecordingRow(recording: recording, isSelected: selectedRecording?.id == recording.id, isPlaying: isPlaying && selectedRecording?.id == recording.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleRecordingSelection(recording)
                        }
                }
                .onDelete(perform: deleteRecordings)
            }
        }
    }
    
    private func handleRecordingSelection(_ recording: RecordingInfo) {
        if selectedRecording?.id == recording.id {
            // 同じ録音が選択された場合は再生/停止を切り替え
            if isPlaying {
                stopPlayback()
            } else {
                playRecording(recording)
            }
        } else {
            // 別の録音が選択された場合は前の再生を停止して新しい録音を選択
            stopPlayback()
            selectedRecording = recording
            playRecording(recording)
        }
    }
    
    private func playRecording(_ recording: RecordingInfo) {
        guard let url = URL(string: "file://\(recording.filePath)") else {
            print("録音ファイルのURLの作成に失敗しました: \(recording.filePath)")
            return
        }
        
        do {
            // macOSではAVAudioSessionは使用しない
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            
            // 再生終了時の処理
            audioPlayer?.delegate = PlaybackDelegate {
                isPlaying = false
            }
        } catch {
            print("録音の再生エラー: \(error.localizedDescription)")
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    private func deleteRecordings(at offsets: IndexSet) {
        // 選択中の録音が削除対象に含まれていたら再生停止
        for index in offsets {
            let recording = recordings[index]
            if selectedRecording?.id == recording.id {
                stopPlayback()
                selectedRecording = nil
            }
            
            // ファイルを削除
            deleteRecordingFile(recording)
            
            // データベースから削除
            modelContext.delete(recording)
        }
    }
    
    private func deleteRecordingFile(_ recording: RecordingInfo) {
        // ファイルを削除
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: recording.filePath) {
            do {
                try fileManager.removeItem(atPath: recording.filePath)
            } catch {
                print("録音ファイルの削除エラー: \(error.localizedDescription)")
            }
        }
    }
}

/// 録音一覧の行表示
struct RecordingRow: View {
    let recording: RecordingInfo
    let isSelected: Bool
    let isPlaying: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.title)
                    .font(.headline)
                
                HStack {
                    Text(recording.formattedDateTime)
                    Text("・")
                    Text(recording.formattedDuration)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
            } else if isSelected {
                Image(systemName: "play.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

/// 再生完了を通知するデリゲート
class PlaybackDelegate: NSObject, AVAudioPlayerDelegate {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        completion()
    }
} 