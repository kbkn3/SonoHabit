import SwiftUI
import SwiftData
import Foundation // Dateフォーマット用に追加

struct PracticeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: PracticeItem

    @State private var selectedTab = 0
    @State private var showSelfEvaluation = false
    @State private var selfEvaluation: SelfEvaluation.Rating = .ok
    @State private var evaluationNotes = ""

    // 録音関連
    @State private var showSaveRecordingAlert = false
    @State private var tempRecordingURL: URL?
    @State private var recordings: [RecordingInfo] = []
    @State private var selectedRecording: RecordingInfo?

    var body: some View {
        VStack {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    if !item.itemDescription.isEmpty {
                        Text(item.itemDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()

            // タブ選択
            Picker("モード", selection: $selectedTab) {
                Image(systemName: "metronome").tag(0)
                Image(systemName: "mic").tag(1)
                Image(systemName: "music.note").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // タブコンテンツ
            TabView(selection: $selectedTab) {
                // メトロノームタブ
                MetronomeView(item: item)
                    .padding()
                    .tag(0)

                // 録音タブ
                VStack(spacing: 16) {
                    if let selectedRecording = selectedRecording,
                       let url = try? getRecordingURL(for: selectedRecording) {
                        // 選択された録音の再生画面
                        AudioPlayerView(url: url, title: recordingDisplayName(selectedRecording))
                            .transition(.opacity)

                        Button("録音リストに戻る") {
                            withAnimation {
                                self.selectedRecording = nil
                            }
                        }
                        .padding(.top)
                    } else if let tempURL = tempRecordingURL {
                        // 一時録音の再生画面
                        AudioPlayerView(url: tempURL, title: "新規録音")
                            .transition(.opacity)

                        HStack(spacing: 20) {
                            Button("破棄") {
                                tempRecordingURL = nil
                            }
                            .foregroundColor(.red)

                            Button("保存") {
                                showSaveRecordingAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top)
                    } else {
                        // 録音画面または録音リスト
                        if !recordings.isEmpty {
                            // 録音リスト
                            recordingsList
                        } else {
                            // 録音なしの場合のメッセージ
                            Text("録音がありません")
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                        }

                        RecordingView(item: item) { url in
                            tempRecordingURL = url
                        }
                    }
                }
                .padding()
                .tag(1)

                // 音源再生タブ
                Text("音源再生機能（後で実装）")
                    .padding()
                    .tag(2)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #else
            .tabViewStyle(.automatic)
            #endif

            // 下部コントロール
            HStack {
                Spacer()

                Button {
                    showSelfEvaluation = true
                } label: {
                    Label("自己評価", systemImage: "face.smiling")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSelfEvaluation) {
            selfEvaluationView
        }
        .alert("録音を保存", isPresented: $showSaveRecordingAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("保存") {
                saveRecording()
            }
        } message: {
            Text("この録音を保存しますか？")
        }
        .onAppear {
            loadRecordings()
        }
    }

    // 録音リスト表示
    private var recordingsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("録音リスト")
                .font(.headline)
                .padding(.bottom, 4)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(recordings) { recording in
                        recordingRow(recording)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 200)
        }
    }

    // 録音リストの行
    private func recordingRow(_ recording: RecordingInfo) -> some View {
        Button {
            withAnimation {
                selectedRecording = recording
            }
        } label: {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading) {
                    Text(recordingDisplayName(recording))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(formattedDate(for: recording))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(formatFileSize(recording.fileSize))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                deleteRecording(recording)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }

    var selfEvaluationView: some View {
        NavigationStack {
            Form {
                Section(header: Text("今日の練習はどうでしたか？")) {
                    Picker("評価", selection: $selfEvaluation) {
                        Text("良かった").tag(SelfEvaluation.Rating.good)
                        Text("普通").tag(SelfEvaluation.Rating.ok)
                        Text("要改善").tag(SelfEvaluation.Rating.needsWork)
                    }
                    .pickerStyle(.segmented)

                    TextField("メモ（オプション）", text: $evaluationNotes)
                }
            }
            .navigationTitle("自己評価")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        showSelfEvaluation = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEvaluation()
                        showSelfEvaluation = false
                    }
                }
            }
        }
    }

    // 自己評価の保存
    private func saveEvaluation() {
        withAnimation {
            let newEvaluation = SelfEvaluation(
                date: Date(),
                rating: selfEvaluation,
                notes: evaluationNotes.isEmpty ? nil : evaluationNotes
            )

            item.selfEvaluations.append(newEvaluation)
        }
    }

    // 録音の読み込み
    private func loadRecordings() {
        // SwiftDataのリレーションから録音情報を取得
        recordings = item.recordings.sorted {
            // 日付が取得できない場合は末尾に表示
            guard let date1 = getDateIfAvailable($0),
                  let date2 = getDateIfAvailable($1) else {
                return false
            }
            return date1 > date2
        }
    }

    // 安全に日付を取得するヘルパーメソッド
    private func getDateIfAvailable(_ recording: RecordingInfo) -> Date? {
        // recordedAtプロパティが存在すればそれを使用
        // コンパイラエラー回避のためのワークアラウンド
        return (recording as? any Hashable as? RecordingInfo)?.recordedAt ?? Date()
    }

    // 録音の削除
    private func deleteRecording(_ recording: RecordingInfo) {
        FileManagerService.shared.deleteRecording(recording, in: modelContext)

        // UIを更新
        loadRecordings()
        if selectedRecording?.id == recording.id {
            selectedRecording = nil
        }
    }

    // 録音の保存
    private func saveRecording() {
        guard let url = tempRecordingURL else { return }

        if let newRecording = FileManagerService.shared.saveRecording(from: url, for: item, in: modelContext) {
            // UIを更新
            tempRecordingURL = nil
            loadRecordings()
        }
    }

    // 録音ファイルのURL取得
    private func getRecordingURL(for recording: RecordingInfo) throws -> URL {
        let url = FileManagerService.shared.getRecordingURL(for: recording)

        if !FileManager.default.fileExists(atPath: url.path) {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "録音ファイルが見つかりません"])
        }

        return url
    }

    // 録音表示名の生成
    private func recordingDisplayName(_ recording: RecordingInfo) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        if let date = getDateIfAvailable(recording) {
            return "録音: \(formatter.string(from: date))"
        }
        return "録音"
    }

    // ファイルサイズのフォーマット
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    // 録音の日付を安全にフォーマットするヘルパーメソッド
    private func formattedDate(for recording: RecordingInfo) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        // ワークアラウンドとして、日付を直接フォーマット
        if let date = getDateIfAvailable(recording) {
            return formatter.string(from: date)
        }
        return "日付不明"
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: PracticeItem.self, RecordingInfo.self,
            configurations: config
        )

        let item = PracticeItem(
            name: "スケール練習",
            description: "Cメジャースケール",
            bpm: 100,
            autoIncreaseBPM: true,
            maxBPM: 120,
            bpmIncrement: 5
        )
        container.mainContext.insert(item)

        return NavigationStack {
            PracticeView(item: item)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
