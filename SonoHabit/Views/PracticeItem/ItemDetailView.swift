import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var item: PracticeItem
    @State private var isShowingEditItem = false
    @State private var isShowingPracticeView = false
    
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
                    ForEach(item.recordings.sorted(by: { $0.createdAt > $1.createdAt })) { recording in
                        NavigationLink {
                            Text("録音詳細（後で実装）: \(recording.displayName)")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(recording.displayName)
                                    .font(.headline)
                                
                                HStack {
                                    Label(
                                        recording.createdAt.formatted(date: .abbreviated, time: .shortened),
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
            EditItemView(item: item)
        }
        .sheet(isPresented: $isShowingPracticeView) {
            PracticeView(item: item)
        }
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            let sortedRecordings = item.recordings.sorted(by: { $0.createdAt > $1.createdAt })
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

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var item: PracticeItem
    
    @State private var name: String
    @State private var description: String
    @State private var bpm: Int
    @State private var timeSignatureNumerator: Int
    @State private var timeSignatureDenominator: Int
    @State private var totalBars: Int
    @State private var repeatCount: Int
    @State private var autoIncreaseBPM: Bool
    @State private var maxBPM: Int?
    @State private var bpmIncrement: Int?
    
    init(item: PracticeItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.itemDescription)
        _bpm = State(initialValue: item.bpm)
        _timeSignatureNumerator = State(initialValue: item.timeSignatureNumerator)
        _timeSignatureDenominator = State(initialValue: item.timeSignatureDenominator)
        _totalBars = State(initialValue: item.totalBars)
        _repeatCount = State(initialValue: item.repeatCount)
        _autoIncreaseBPM = State(initialValue: item.autoIncreaseBPM)
        _maxBPM = State(initialValue: item.maxBPM)
        _bpmIncrement = State(initialValue: item.bpmIncrement)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("項目情報")) {
                    TextField("名前", text: $name)
                    TextField("説明", text: $description)
                }
                
                Section(header: Text("メトロノーム設定")) {
                    Stepper("BPM: \(bpm)", value: $bpm, in: 40...240)
                    
                    Picker("拍子", selection: $timeSignatureNumerator) {
                        ForEach(2..<9) { num in
                            Text("\(num)/\(timeSignatureDenominator)")
                                .tag(num)
                        }
                    }
                    
                    Picker("拍子単位", selection: $timeSignatureDenominator) {
                        Text("2").tag(2)
                        Text("4").tag(4)
                        Text("8").tag(8)
                    }
                    
                    Stepper("小節数: \(totalBars)", value: $totalBars, in: 1...64)
                    
                    Stepper("繰り返し回数: \(repeatCount)", value: $repeatCount, in: 1...20)
                    
                    Toggle("BPM自動増加", isOn: $autoIncreaseBPM)
                    
                    if autoIncreaseBPM {
                        let binding = Binding<Int>(
                            get: { maxBPM ?? bpm + 20 },
                            set: { maxBPM = $0 }
                        )
                        Stepper("最大BPM: \(binding.wrappedValue)", value: binding, in: bpm...240)
                        
                        let incrementBinding = Binding<Int>(
                            get: { bpmIncrement ?? 5 },
                            set: { bpmIncrement = $0 }
                        )
                        Stepper("増加量: \(incrementBinding.wrappedValue)BPM", value: incrementBinding, in: 1...20)
                    }
                }
            }
            .navigationTitle("項目編集")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        updateItem()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func updateItem() {
        withAnimation {
            item.name = name
            item.itemDescription = description
            item.bpm = bpm
            item.timeSignatureNumerator = timeSignatureNumerator
            item.timeSignatureDenominator = timeSignatureDenominator
            item.totalBars = totalBars
            item.repeatCount = repeatCount
            item.autoIncreaseBPM = autoIncreaseBPM
            item.maxBPM = autoIncreaseBPM ? maxBPM : nil
            item.bpmIncrement = autoIncreaseBPM ? bpmIncrement : nil
        }
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