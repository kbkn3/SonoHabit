import SwiftUI
import SwiftData

struct RecordingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recordings: [RecordingInfo]

    @State private var selectedRecording: RecordingInfo?
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: RecordingInfo?

    var body: some View {
        Group {
            if recordings.isEmpty {
                ContentUnavailableView(
                    "録音なし",
                    systemImage: "waveform",
                    description: Text("練習中に録音を作成すると、ここに表示されます")
                )
            } else {
                recordingsList
            }
        }
        .navigationTitle("録音")
        .sheet(item: $selectedRecording) { recording in
            recordingDetailView(for: recording)
        }
        .alert("録音を削除", isPresented: $showDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let recording = recordingToDelete {
                    deleteRecording(recording)
                }
            }
        } message: {
            Text("この録音を削除しますか？この操作は元に戻せません。")
        }
    }

    private var recordingsList: some View {
        List {
            ForEach(groupedRecordings.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(formatDate(date))) {
                    ForEach(groupedRecordings[date] ?? []) { recording in
                        recordingRow(recording)
                    }
                }
            }
        }
        .listStyle(.inset)
    }

    private func recordingRow(_ recording: RecordingInfo) -> some View {
        Button {
            selectedRecording = recording
        } label: {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.displayName.isEmpty ? "録音 \(recording.recordedAt.formatted(date: .omitted, time: .shortened))" : recording.displayName)
                        .fontWeight(.medium)

                    HStack {
                        Text(formatDuration(recording.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let practiceItem = recording.practiceItem {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(practiceItem.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Text(formatFileSize(recording.fileSize))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                recordingToDelete = recording
                showDeleteAlert = true
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }

    private func recordingDetailView(for recording: RecordingInfo) -> some View {
        NavigationStack {
            VStack {
                if let url = try? getRecordingURL(for: recording) {
                    AudioPlayerView(
                        url: url,
                        title: recording.displayName.isEmpty ? "録音 \(recording.recordedAt.formatted(date: .abbreviated, time: .shortened))" : recording.displayName
                    )
                    .padding()
                } else {
                    ContentUnavailableView(
                        "ファイルエラー",
                        systemImage: "exclamationmark.triangle",
                        description: Text("録音ファイルが見つかりませんでした")
                    )
                }

                if let practiceItem = recording.practiceItem {
                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("練習項目:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(practiceItem.name)
                                .font(.headline)
                        }

                        Spacer()

                        NavigationLink {
                            // 練習項目詳細画面への遷移
                            if let menu = practiceItem.menu {
                                MenuDetailView(menu: menu)
                            }
                        } label: {
                            Text("詳細")
                                .font(.caption)
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("録音詳細")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        selectedRecording = nil
                    }
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        recordingToDelete = recording
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }

    // MARK: - ヘルパーメソッド

    // 録音を日付でグループ化
    private var groupedRecordings: [Date: [RecordingInfo]] {
        Dictionary(grouping: recordings) { recording in
            Calendar.current.startOfDay(for: recording.recordedAt)
        }
    }

    // 日付のフォーマット
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "今日"
        } else if calendar.isDateInYesterday(date) {
            return "昨日"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

    // 時間のフォーマット
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // ファイルサイズのフォーマット
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    // 録音ファイルのURL取得
    private func getRecordingURL(for recording: RecordingInfo) throws -> URL {
        let url = FileManagerService.shared.getRecordingURL(for: recording)

        if !FileManager.default.fileExists(atPath: url.path) {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "録音ファイルが見つかりません"])
        }

        return url
    }

    // 録音の削除
    private func deleteRecording(_ recording: RecordingInfo) {
        FileManagerService.shared.deleteRecording(recording, in: modelContext)
        recordingToDelete = nil
        selectedRecording = nil
    }
}

#Preview {
    NavigationStack {
        RecordingListView()
    }
    .modelContainer(for: [RecordingInfo.self, PracticeItem.self], inMemory: true)
}
