import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: PracticeItem
    @State private var isShowingEditItem = false
    @State private var isShowingPracticeView = false
    @State private var isShowingSelfEvaluation = false

    var body: some View {
        List {
            Section {
                if !item.itemDescription.isEmpty {
                    Text(item.itemDescription)
                        .font(.subheadline)
                }

                Text("作成日: \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("メトロノーム設定")) {
                LabeledContent("BPM", value: "\(item.bpm)")

                LabeledContent("拍子", value: "\(item.timeSignatureNumerator)/\(item.timeSignatureDenominator)")

                LabeledContent("小節数", value: "\(item.totalBars)")

                LabeledContent("繰り返し回数", value: "\(item.repeatCount)")

                if item.autoIncreaseBPM {
                    LabeledContent("BPM自動増加", value: "有効")

                    if let maxBPM = item.maxBPM, let bpmIncrement = item.bpmIncrement {
                        LabeledContent("最大BPM", value: "\(maxBPM)")
                        LabeledContent("増加量", value: "\(bpmIncrement)BPM")
                    }
                } else {
                    LabeledContent("BPM自動増加", value: "無効")
                }
            }

            Section(header: Text("録音")) {
                if item.recordings.isEmpty {
                    Text("録音がありません。練習ビューで録音を行なってください。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(item.recordings.sorted(by: { $0.recordedAt > $1.recordedAt })) { recording in
                        NavigationLink {
                            Text("録音詳細（後で実装）: \(recording.displayName)")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(recording.displayName)
                                    .font(.headline)

                                HStack {
                                    Label(
                                        recording.recordedAt.formatted(date: .abbreviated, time: .shortened),
                                        systemImage: "calendar"
                                    )
                                    .font(.caption)

                                    Spacer()

                                    Label(
                                        formatDuration(recording.duration),
                                        systemImage: "clock"
                                    )
                                    .font(.caption)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteRecordings)
                }
            }

            Section(header: Text("音源")) {
                if item.audioSources.isEmpty {
                    Text("音源がありません。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(item.audioSources) { source in
                        NavigationLink {
                            Text("音源詳細（後で実装）: \(source.displayName)")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(source.displayName)
                                    .font(.headline)

                                HStack {
                                    Label(
                                        formatDuration(source.duration),
                                        systemImage: "clock"
                                    )
                                    .font(.caption)

                                    Spacer()
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteAudioSources)
                }
            }

            Section(header: Text("自己評価")) {
                Button("自己評価を入力する") {
                    isShowingSelfEvaluation = true
                }
            }
        }
        .navigationTitle(item.name)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingEditItem = true
                } label: {
                    Label("編集", systemImage: "pencil")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingPracticeView = true
                } label: {
                    Label("練習開始", systemImage: "play.fill")
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingEditItem = true
                } label: {
                    Label("編集", systemImage: "pencil")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingPracticeView = true
                } label: {
                    Label("練習開始", systemImage: "play.fill")
                }
            }
            #endif
        }
        .sheet(isPresented: $isShowingEditItem) {
            ItemEditView(mode: .edit, item: item)
        }
        .sheet(isPresented: $isShowingPracticeView) {
            PracticeView(item: item)
        }
        .sheet(isPresented: $isShowingSelfEvaluation) {
            SelfEvaluationView(item: item)
        }
    }

    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            let sortedRecordings = item.recordings.sorted(by: { $0.recordedAt > $1.recordedAt })
            for index in offsets {
                modelContext.delete(sortedRecordings[index])
            }
        }
    }

    private func deleteAudioSources(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(item.audioSources[index])
            }
        }
    }

    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PracticeItem.self, configurations: config)

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
            ItemDetailView(item: item)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
