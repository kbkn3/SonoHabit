import SwiftUI
import SwiftData

/// 練習メニューの編集画面
struct MenuEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    /// 編集中のメニュー
    @Bindable var menu: PracticeMenu
    
    /// 新規作成モードかどうか
    var isNewMenu: Bool
    
    /// 編集中のメニュー名
    @State private var name: String
    
    /// 編集中のメニュー説明
    @State private var description: String
    
    /// エラーメッセージ
    @State private var errorMessage: String?
    
    /// エラーメッセージの表示状態
    @State private var showingError = false
    
    /// 初期化 (既存メニュー編集)
    init(menu: PracticeMenu, isNewMenu: Bool = false) {
        self.menu = menu
        self.isNewMenu = isNewMenu
        self._name = State(initialValue: menu.name)
        self._description = State(initialValue: menu.description ?? "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("メニュー名", text: $name)
                TextField("説明", text: $description)
            }
            
            if !isNewMenu {
                Section(header: Text("練習項目")) {
                    if let items = menu.items, !items.isEmpty {
                        ForEach(items) { item in
                            Text(item.name)
                        }
                        .onDelete(perform: deleteItems)
                    } else {
                        Text("練習項目がありません")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: addNewItem) {
                        Label("練習項目を追加", systemImage: "plus")
                    }
                }
            }
            
            Section {
                Button(action: saveMenu) {
                    Text(isNewMenu ? "メニューを作成" : "変更を保存")
                }
                .disabled(name.isEmpty)
                
                if !isNewMenu {
                    Button(role: .destructive, action: confirmDelete) {
                        Text("メニューを削除")
                    }
                }
            }
        }
        .navigationTitle(isNewMenu ? "新規メニュー" : "メニュー編集")
        .alert("エラー", isPresented: $showingError, presenting: errorMessage) { _ in
            Button("OK") {}
        } message: { errorMessage in
            Text(errorMessage)
        }
    }
    
    /// メニューを保存する
    private func saveMenu() {
        guard !name.isEmpty else {
            errorMessage = "メニュー名を入力してください"
            showingError = true
            return
        }
        
        menu.name = name
        menu.description = description.isEmpty ? nil : description
        
        if isNewMenu {
            modelContext.insert(menu)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "保存できませんでした: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    /// 練習項目を追加する
    private func addNewItem() {
        let newItem = PracticeItem(name: "新しい練習項目", order: (menu.items?.count ?? 0) + 1)
        menu.addToItems(newItem)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "項目を追加できませんでした: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    /// 練習項目を削除する
    private func deleteItems(at offsets: IndexSet) {
        guard let items = menu.items else { return }
        
        // スワイプで削除する項目
        let itemsToDelete = offsets.map { items[$0] }
        
        // 各項目を削除
        for item in itemsToDelete {
            modelContext.delete(item)
        }
        
        // 残った項目の順序を更新
        if let updatedItems = menu.items {
            for (index, item) in updatedItems.enumerated() {
                item.order = index + 1
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "項目を削除できませんでした: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    /// メニュー削除確認
    private func confirmDelete() {
        errorMessage = "この操作は取り消せません。メニューと全ての練習項目が削除されます。"
        showingError = true
        
        // 実際の削除処理は未実装
        // TODO: 確認ダイアログを実装する
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PracticeMenu.self, PracticeItem.self, configurations: [config])
        
        let sampleMenu = PracticeMenu(name: "サンプルメニュー")
        sampleMenu.description = "サンプル説明文"
        
        return NavigationStack {
            MenuEditView(menu: sampleMenu)
        }
        .modelContainer(container)
    } catch {
        return Text("プレビュー読み込みエラー")
    }
} 