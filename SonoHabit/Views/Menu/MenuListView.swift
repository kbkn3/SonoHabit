import SwiftUI
import SwiftData

struct MenuListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var menus: [PracticeMenu]
    
    @State private var isShowingAddMenu = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(menus) { menu in
                    NavigationLink {
                        Text("メニュー詳細（後で実装）: \(menu.name)")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(menu.name)
                                .font(.headline)
                            
                            if !menu.menuDescription.isEmpty {
                                Text(menu.menuDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("練習項目: \(menu.items.count)個")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(menu.createdAt, format: .dateTime.month().day())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteMenus)
            }
            .navigationTitle("練習メニュー")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddMenu = true
                    } label: {
                        Label("追加", systemImage: "plus")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddMenu = true
                    } label: {
                        Label("追加", systemImage: "plus")
                    }
                }
                #endif
            }
            .sheet(isPresented: $isShowingAddMenu) {
                AddMenuView()
            }
        }
    }
    
    private func deleteMenus(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(menus[index])
            }
        }
    }
}

struct AddMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("メニュー情報")) {
                    TextField("名前", text: $name)
                    TextField("説明", text: $description)
                }
            }
            .navigationTitle("新規メニュー")
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
                        addMenu()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addMenu() {
        withAnimation {
            let newMenu = PracticeMenu(name: name, description: description)
            modelContext.insert(newMenu)
        }
    }
}

#Preview {
    MenuListView()
        .modelContainer(for: PracticeMenu.self, inMemory: true)
} 