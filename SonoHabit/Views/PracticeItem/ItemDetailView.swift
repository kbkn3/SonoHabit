import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: PracticeItem
    @State private var showEditItem = false
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    
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
            
            Section {
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
} 