import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var item: PracticeItem
    
    @State private var selectedTab = 0
    @State private var showSelfEvaluation = false
    @State private var selfEvaluation: SelfEvaluation.Rating = .ok
    @State private var evaluationNotes = ""
    
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
                Text("録音機能（後で実装）")
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
            PracticeView(item: item)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 