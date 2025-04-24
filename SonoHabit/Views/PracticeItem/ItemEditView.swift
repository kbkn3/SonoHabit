import SwiftUI
import SwiftData

/// 練習項目の編集画面
struct ItemEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    /// 編集中の練習項目
    @Bindable var item: PracticeItem
    
    /// 新規作成モードかどうか
    var isNewItem: Bool
    
    /// 編集中の項目名
    @State private var name: String
    
    /// 編集中の項目説明
    @State private var description: String
    
    /// メトロノーム使用フラグ
    @State private var useMetronome: Bool
    
    /// BPM値
    @State private var bpm: Int
    
    /// 時間設定（分）
    @State private var durationMinutes: Int
    
    /// 録音使用フラグ
    @State private var useRecording: Bool
    
    /// 音源再生使用フラグ
    @State private var useAudioSource: Bool
    
    /// エラーメッセージ
    @State private var errorMessage: String?
    
    /// エラーメッセージの表示状態
    @State private var showingError = false
    
    /// 初期化
    init(item: PracticeItem, isNewItem: Bool = false) {
        self.item = item
        self.isNewItem = isNewItem
        
        self._name = State(initialValue: item.name)
        self._description = State(initialValue: item.description ?? "")
        self._useMetronome = State(initialValue: item.metronomeSettings != nil)
        self._bpm = State(initialValue: item.metronomeSettings?.bpm ?? Constants.Metronome.defaultBPM)
        self._durationMinutes = State(initialValue: Int(item.durationSeconds / 60))
        self._useRecording = State(initialValue: item.useRecording)
        self._useAudioSource = State(initialValue: item.audioSource != nil)
    }
    
    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("項目名", text: $name)
                TextField("説明", text: $description)
                
                Stepper("練習時間: \(durationMinutes)分", value: $durationMinutes, in: 1...60)
            }
            
            Section(header: Text("ツール設定")) {
                Toggle("メトロノームを使用", isOn: $useMetronome)
                
                if useMetronome {
                    HStack {
                        Text("BPM:")
                        Spacer()
                        Stepper("\(bpm)", value: $bpm, in: Constants.Metronome.minBPM...Constants.Metronome.maxBPM)
                    }
                }
                
                Toggle("録音を使用", isOn: $useRecording)
                
                Toggle("音源ファイルを使用", isOn: $useAudioSource)
                
                if useAudioSource && !isNewItem {
                    Button(action: selectAudioSource) {
                        Text(item.audioSource != nil ? "音源ファイルを変更" : "音源ファイルを選択")
                    }
                }
            }
            
            Section {
                Button(action: saveItem) {
                    Text(isNewItem ? "項目を作成" : "変更を保存")
                }
                .disabled(name.isEmpty)
                
                if !isNewItem {
                    Button(role: .destructive, action: confirmDelete) {
                        Text("項目を削除")
                    }
                }
            }
        }
        .navigationTitle(isNewItem ? "新規項目" : "項目編集")
        .alert("エラー", isPresented: $showingError, presenting: errorMessage) { _ in
            Button("OK") {}
        } message: { errorMessage in
            Text(errorMessage)
        }
    }
    
    /// 項目を保存する
    private func saveItem() {
        guard !name.isEmpty else {
            errorMessage = "項目名を入力してください"
            showingError = true
            return
        }
        
        // 基本情報を更新
        item.name = name
        item.description = description.isEmpty ? nil : description
        item.durationSeconds = Double(durationMinutes * 60)
        item.useRecording = useRecording
        
        // メトロノーム設定を更新
        if useMetronome {
            if item.metronomeSettings == nil {
                item.metronomeSettings = MetronomeSettings()
            }
            item.metronomeSettings?.bpm = bpm
        } else {
            item.metronomeSettings = nil
        }
        
        // 音源ファイル設定
        if !useAudioSource {
            item.audioSource = nil
        }
        
        if isNewItem {
            modelContext.insert(item)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "保存できませんでした: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    /// 音源ファイルを選択する
    private func selectAudioSource() {
        // TODO: ファイル選択ダイアログを表示する実装
        // この部分はDocumentPickerを使用する実装が必要
        errorMessage = "音源選択機能は実装中です"
        showingError = true
    }
    
    /// 項目削除確認
    private func confirmDelete() {
        errorMessage = "この操作は取り消せません。練習項目が削除されます。"
        showingError = true
        
        // 実際の削除処理は未実装
        // TODO: 確認ダイアログを実装する
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PracticeItem.self, configurations: [config])
        
        let sampleItem = PracticeItem(name: "サンプル練習項目", order: 1)
        sampleItem.description = "サンプル説明文"
        sampleItem.durationSeconds = 300 // 5分
        sampleItem.useRecording = true
        
        let metronomeSettings = MetronomeSettings()
        metronomeSettings.bpm = 100
        sampleItem.metronomeSettings = metronomeSettings
        
        return NavigationStack {
            ItemEditView(item: sampleItem)
        }
        .modelContainer(container)
    } catch {
        return Text("プレビュー読み込みエラー")
    }
} 