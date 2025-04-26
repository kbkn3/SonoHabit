import SwiftUI
import SwiftData

struct MenuListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeMenu.order) private var menus: [PracticeMenu]
    @State private var showAddMenu = false
    @State private var newMenuName = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(menus) { menu in
                    NavigationLink(destination: MenuDetailView(menu: menu)) {
                        VStack(alignment: .leading) {
                            Text(menu.name)
                                .font(.headline)
                            
                            Text("練習項目: \(menu.items.count)個")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: isEditing ? deleteMenus : nil)
                .onMove(perform: isEditing ? moveMenus : nil)
            }
            .navigationTitle("練習メニュー")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "完了" : "編集")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        showAddMenu = true
                    }) {
                        Label("追加", systemImage: "plus")
                    }
                }
            }
            .alert("新しいメニューを追加", isPresented: $showAddMenu) {
                TextField("メニュー名", text: $newMenuName)
                
                Button("キャンセル", role: .cancel) {
                    newMenuName = ""
                }
                
                Button("追加") {
                    addMenu()
                    newMenuName = ""
                }
            }
        }
    }
    
    private func addMenu() {
        guard !newMenuName.isEmpty else { return }
        _ = DataManager.shared.addMenu(name: newMenuName, context: modelContext)
    }
    
    private func deleteMenus(offsets: IndexSet) {
        for index in offsets {
            DataManager.shared.deleteMenu(menus[index], context: modelContext)
        }
    }
    
    private func moveMenus(from source: IndexSet, to destination: Int) {
        var orderedMenus = menus
        orderedMenus.move(fromOffsets: source, toOffset: destination)
        DataManager.shared.reorderMenus(orderedMenus, context: modelContext)
    }
} 