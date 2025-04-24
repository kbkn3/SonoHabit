import SwiftUI
import SwiftData

struct MenuListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var menus: [PracticeMenu]
    
    @State private var isShowingAddMenu = false
    @State private var isShowingTemplates = false
    
    var body: some View {
        List {
            ForEach(menus) { menu in
                NavigationLink {
                    MenuDetailView(menu: menu)
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
                Menu {
                    Button {
                        isShowingAddMenu = true
                    } label: {
                        Label("新規作成", systemImage: "plus")
                    }
                    
                    Button {
                        isShowingTemplates = true
                    } label: {
                        Label("テンプレートから作成", systemImage: "doc.badge.plus")
                    }
                } label: {
                    Label("追加", systemImage: "plus")
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isShowingAddMenu = true
                    } label: {
                        Label("新規作成", systemImage: "plus")
                    }
                    
                    Button {
                        isShowingTemplates = true
                    } label: {
                        Label("テンプレートから作成", systemImage: "doc.badge.plus")
                    }
                } label: {
                    Label("追加", systemImage: "plus")
                }
            }
            #endif
        }
        .sheet(isPresented: $isShowingAddMenu) {
            MenuEditView(mode: .create)
        }
        .sheet(isPresented: $isShowingTemplates) {
            MenuTemplatesView()
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

#Preview {
    MenuListView()
        .modelContainer(for: PracticeMenu.self, inMemory: true)
} 