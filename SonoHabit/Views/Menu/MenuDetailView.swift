import SwiftUI
import SwiftData

struct MenuDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var menu: PracticeMenu
    @State private var showEditMenu = false
    @State private var showAddItem = false
    @State private var newItemName = ""
    
    // 項目を順番で取得
    var sortedItems: [PracticeItem] {
        menu.items.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        List {
            Section("メニュー情報") {
                VStack(alignment: .leading) {
                    Text("作成日: \(formattedDate(menu.createdAt))")
                        .font(.caption)
                    Text("更新日: \(formattedDate(menu.updatedAt))")
                        .font(.caption)
                }
            }
            
            Section("練習項目") {
                if sortedItems.isEmpty {
                    Text("練習項目がまだありません")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(sortedItems) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                if !item.description.isEmpty {
                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
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
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Menu {
                    Button(action: {
                        showEditMenu = true
                    }) {
                        Label("メニューを編集", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showAddItem = true
                    }) {
                        Label("練習項目を追加", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("メニュー名を編集", isPresented: $showEditMenu) {
            TextField("メニュー名", text: $menu.name)
            
            Button("キャンセル", role: .cancel) { }
            
            Button("保存") {
                DataManager.shared.updateMenu(menu, context: modelContext)
            }
        }
        .alert("新しい練習項目", isPresented: $showAddItem) {
            TextField("項目名", text: $newItemName)
            
            Button("キャンセル", role: .cancel) {
                newItemName = ""
            }
            
            Button("追加") {
                addItem()
                newItemName = ""
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func addItem() {
        guard !newItemName.isEmpty else { return }
        _ = DataManager.shared.addItem(name: newItemName, menu: menu, context: modelContext)
    }
    
    private func deleteItems(offsets: IndexSet) {
        let items = sortedItems
        for index in offsets {
            DataManager.shared.deleteItem(items[index], context: modelContext)
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var orderedItems = sortedItems
        orderedItems.move(fromOffsets: source, toOffset: destination)
        DataManager.shared.reorderItems(orderedItems, context: modelContext)
    }
} 