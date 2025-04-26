import SwiftUI
import AVFoundation
import SwiftData

/// 録音機能のビュー
struct RecordingView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var inputManager: AudioInputManager
    @State private var recordingTitle: String = "録音"
    @State private var showingInputSelector = false
    @State private var showingSettings = false
    @State private var showingSavedMessage = false
    @State private var latestRecording: RecordingInfo?
    
    var practiceItem: PracticeItem?
    var onRecordingInfoCreated: ((RecordingInfo) -> Void)?
    
    init(
        practiceItem: PracticeItem? = nil,
        audioRecorder: AudioRecorder? = nil,
        inputManager: AudioInputManager? = nil,
        onRecordingInfoCreated: ((RecordingInfo) -> Void)? = nil
    ) {
        self.practiceItem = practiceItem
        
        // タイトルの初期化
        if let itemName = practiceItem?.name {
            self._recordingTitle = State(initialValue: itemName)
        }
        
        // サービスの初期化または受け取り
        let inputMgr = inputManager ?? AudioInputManager()
        self.inputManager = inputMgr
        
        let recorder = audioRecorder ?? AudioRecorder(inputManager: inputMgr)
        self.audioRecorder = recorder
        
        self.onRecordingInfoCreated = onRecordingInfoCreated
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 波形表示
            AudioWaveformView(
                level: audioRecorder.peakPower,
                color: .blue,
                direction: .center
            )
            .frame(height: 80)
            .padding(.horizontal)
            .animation(.linear(duration: 0.1), value: audioRecorder.peakPower)
            
            // レベルメーター
            LevelMeterView(
                level: audioRecorder.peakPower,
                width: nil,
                height: 16,
                foregroundColor: .blue
            )
            .padding(.horizontal)
            
            // 録音タイトル
            if case .stopped = audioRecorder.state {
                TextField("録音タイトル", text: $recordingTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isRecordingActive)
                    .padding(.horizontal)
            } else {
                // 録音タイマー
                RecordingTimerView(
                    elapsedTime: audioRecorder.elapsedTime,
                    textColor: recordingStateColor
                )
                .padding(.vertical, 4)
            }
            
            // 録音ステータス表示
            if case .error(let message) = audioRecorder.state {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            // コントロールボタン
            HStack(spacing: 30) {
                // 入力選択ボタン
                Button(action: {
                    if !isRecordingActive {
                        showingInputSelector = true
                    }
                }) {
                    VStack {
                        Image(systemName: "mic")
                            .font(.system(size: 24))
                            .foregroundColor(isRecordingActive ? .gray : .blue)
                        Text("入力")
                            .font(.caption)
                    }
                }
                .disabled(isRecordingActive)
                
                // 録音/一時停止ボタン
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(recordingStateColor)
                            .frame(width: 60, height: 60)
                        
                        Group {
                            if case .recording = audioRecorder.state {
                                // 録音中は一時停止ボタン
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                            } else if case .paused = audioRecorder.state {
                                // 一時停止中は再開ボタン
                                Image(systemName: "play.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            } else {
                                // 停止中は録音ボタン
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
                
                // 停止ボタン（録音中のみ表示）
                if isRecordingActive {
                    Button(action: stopAndSaveRecording) {
                        VStack {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                            Text("停止")
                                .font(.caption)
                        }
                    }
                } else {
                    // 設定ボタン（停止中のみ表示）
                    Button(action: {
                        showingSettings = true
                    }) {
                        VStack {
                            Image(systemName: "gear")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                            Text("設定")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            
            // 保存メッセージ
            if showingSavedMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("録音を保存しました")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding(.bottom, 8)
                .transition(.opacity)
            }
        }
        .padding()
        .onAppear {
            // 入力の監視を開始
            inputManager.startMonitoring()
        }
        .onDisappear {
            // 入力の監視を停止
            inputManager.stopMonitoring()
            
            // 録音中なら停止
            if isRecordingActive {
                stopAndSaveRecording()
            }
        }
        .sheet(isPresented: $showingInputSelector) {
            // 入力選択シート
            InputSelectorView(inputManager: inputManager)
        }
        .sheet(isPresented: $showingSettings) {
            // 録音設定シート
            RecordingSettingsView(audioRecorder: audioRecorder)
        }
    }
    
    /// 録音/一時停止を切り替え
    private func toggleRecording() {
        switch audioRecorder.state {
        case .stopped:
            // 録音開始
            if let fileURL = audioRecorder.startRecording(title: recordingTitle) {
                print("録音開始: \(fileURL.path)")
            }
            
        case .recording:
            // 録音一時停止
            audioRecorder.pauseRecording()
            
        case .paused:
            // 録音再開
            audioRecorder.resumeRecording()
            
        case .error:
            // エラー状態からの回復
            audioRecorder.stopRecording()
        }
    }
    
    /// 録音を停止して保存
    private func stopAndSaveRecording() {
        guard isRecordingActive else { return }
        
        // 録音を停止
        if let fileURL = audioRecorder.stopRecording() {
            // 録音情報を作成
            if let recordingInfo = audioRecorder.getRecordingInfo(for: fileURL, title: recordingTitle) {
                // 練習項目に関連付け
                if let practiceItem = practiceItem {
                    recordingInfo.practiceItem = practiceItem
                }
                
                // SwiftDataに保存
                modelContext.insert(recordingInfo)
                
                // 最新の録音として保存
                latestRecording = recordingInfo
                
                // コールバック呼び出し
                onRecordingInfoCreated?(recordingInfo)
                
                // 保存メッセージを表示
                withAnimation {
                    showingSavedMessage = true
                }
                
                // メッセージを数秒後に消す
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showingSavedMessage = false
                    }
                }
            }
        }
    }
    
    /// 録音中または一時停止中かどうか
    private var isRecordingActive: Bool {
        if case .recording = audioRecorder.state { return true }
        if case .paused = audioRecorder.state { return true }
        return false
    }
    
    /// 録音状態に応じた色
    private var recordingStateColor: Color {
        switch audioRecorder.state {
        case .recording: return .red
        case .paused: return .orange
        case .error: return .gray
        case .stopped: return .blue
        }
    }
}

/// 入力選択ビュー
struct InputSelectorView: View {
    @ObservedObject var inputManager: AudioInputManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(inputManager.availableInputs, id: \.uid) { input in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(input.portName)
                                .font(.headline)
                            Text(input.portType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if inputManager.selectedInput?.uid == input.uid {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        inputManager.selectInput(input)
                        dismiss()
                    }
                }
                
                if inputManager.availableInputs.isEmpty {
                    Text("利用可能な入力がありません")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("入力ソースを選択")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                inputManager.loadAvailableInputs()
            }
        }
    }
}

/// 録音設定ビュー
struct RecordingSettingsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("音声形式") {
                    Picker("ファイル形式", selection: $audioRecorder.fileFormat) {
                        ForEach(RecordingInfo.AudioFileFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("サンプルレート", selection: $audioRecorder.sampleRate) {
                        Text("44.1 kHz").tag(44100)
                        Text("48 kHz").tag(48000)
                        Text("96 kHz").tag(96000)
                    }
                    
                    Picker("ビットレート", selection: $audioRecorder.bitRate) {
                        Text("64 kbps").tag(64000)
                        Text("128 kbps").tag(128000)
                        Text("256 kbps").tag(256000)
                    }
                }
                
                Section("表示") {
                    Toggle("レベルメーター", isOn: $audioRecorder.isPeakMeterEnabled)
                }
            }
            .navigationTitle("録音設定")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecordingView()
        .padding()
        .previewLayout(.sizeThatFits)
} 