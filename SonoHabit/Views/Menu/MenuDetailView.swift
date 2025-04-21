import SwiftUI
import SwiftData

struct MenuDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var menu: PracticeMenu
    @State private var isShowingAddItem = false
    @State private var isShowingEditMenu = false
    
    var body: some View {
        List {
            Section {
                if !menu.menuDescription.isEmpty {
                    Text(menu.menuDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("作成日: \(menu.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("練習項目")) {
                if menu.items.isEmpty {
                    Text("練習項目がありません。右上の＋ボタンから追加してください。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(menu.items.sorted(by: { $0.order < $1.order })) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                
                                if !item.itemDescription.isEmpty {
                                    Text(item.itemDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Label("\(item.bpm)BPM", systemImage: "metronome")
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    Label("\(item.recordings.count)", systemImage: "mic")
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
            }
        }
        .navigationTitle(menu.name)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingAddItem = true
                } label: {
                    Label("追加", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingEditMenu = true
                } label: {
                    Label("編集", systemImage: "pencil")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddItem = true
                } label: {
                    Label("追加", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingEditMenu = true
                } label: {
                    Label("編集", systemImage: "pencil")
                }
            }
            #endif
        }
        .sheet(isPresented: $isShowingAddItem) {
            AddPracticeItemView(menu: menu)
        }
        .sheet(isPresented: $isShowingEditMenu) {
            EditMenuView(menu: menu)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = menu.items.sorted(by: { $0.order < $1.order })[index]
                modelContext.delete(item)
            }
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var items = menu.items.sorted(by: { $0.order < $1.order })
        items.move(fromOffsets: source, toOffset: destination)
        
        // 順番を更新
        for (index, item) in items.enumerated() {
            item.order = index
        }
    }
}

struct EditMenuView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var menu: PracticeMenu
    
    @State private var name: String
    @State private var description: String
    
    init(menu: PracticeMenu) {
        self.menu = menu
        _name = State(initialValue: menu.name)
        _description = State(initialValue: menu.menuDescription)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("メニュー情報")) {
                    TextField("名前", text: $name)
                    TextField("説明", text: $description)
                }
            }
            .navigationTitle("メニュー編集")
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
                        updateMenu()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func updateMenu() {
        withAnimation {
            menu.name = name
            menu.menuDescription = description
        }
    }
}

struct AddPracticeItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var menu: PracticeMenu
    
    @State private var name = ""
    @State private var description = ""
    @State private var bpm = 120
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("項目情報")) {
                    TextField("名前", text: $name)
                    TextField("説明", text: $description)
                }
                
                Section(header: Text("メトロノーム設定")) {
                    Stepper("BPM: \(bpm)", value: $bpm, in: 40...240)
                }
            }
            .navigationTitle("新規練習項目")
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
                        addItem()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = PracticeItem(
                name: name,
                description: description,
                order: menu.items.count,
                bpm: bpm
            )
            
            menu.items.append(newItem)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PracticeMenu.self, configurations: config)
        
        let menu = PracticeMenu(name: "サンプルメニュー", description: "これはテスト用のメニューです")
        container.mainContext.insert(menu)
        
        let item1 = PracticeItem(name: "スケール練習", description: "Cメジャースケール", order: 0, bpm: 100)
        let item2 = PracticeItem(name: "コード練習", description: "基本コード", order: 1, bpm: 80)
        
        menu.items.append(item1)
        menu.items.append(item2)
        
        container.mainContext.insert(item1)
        container.mainContext.insert(item2)
        
        return NavigationStack {
            MenuDetailView(menu: menu)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 