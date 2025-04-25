import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - ユーザー設定関連
    
    /// ユーザー設定を取得する（なければ作成する）
    func getUserSettings(context: ModelContext) -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        
        do {
            let settings = try context.fetch(descriptor)
            if let existingSettings = settings.first {
                return existingSettings
            } else {
                // 設定が存在しない場合は新規作成
                let newSettings = UserSettings()
                context.insert(newSettings)
                try context.save()
                return newSettings
            }
        } catch {
            print("Error fetching user settings: \(error)")
            // エラー時は新規作成して返す
            let newSettings = UserSettings()
            context.insert(newSettings)
            try? context.save()
            return newSettings
        }
    }
    
    // MARK: - 練習メニュー関連
    
    /// 全ての練習メニューを取得
    func getAllMenus(context: ModelContext) -> [PracticeMenu] {
        let descriptor = FetchDescriptor<PracticeMenu>(
            sortBy: [SortDescriptor(\.order, order: .forward)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching menus: \(error)")
            return []
        }
    }
    
    /// 練習メニューを追加
    func addMenu(name: String, context: ModelContext) -> PracticeMenu {
        // 現在の最大順番を取得
        let maxOrder = getAllMenus(context: context).map { $0.order }.max() ?? -1
        
        let menu = PracticeMenu(name: name, order: maxOrder + 1)
        context.insert(menu)
        try? context.save()
        return menu
    }
    
    /// 練習メニューを更新
    func updateMenu(_ menu: PracticeMenu, context: ModelContext) {
        menu.updatedAt = Date()
        try? context.save()
    }
    
    /// 練習メニューを削除
    func deleteMenu(_ menu: PracticeMenu, context: ModelContext) {
        context.delete(menu)
        try? context.save()
    }
    
    // MARK: - 練習項目関連
    
    /// 特定のメニューに属する全ての練習項目を取得
    func getItemsForMenu(_ menu: PracticeMenu, context: ModelContext) -> [PracticeItem] {
        let descriptor = FetchDescriptor<PracticeItem>(
            predicate: #Predicate { $0.menu?.id == menu.id },
            sortBy: [SortDescriptor(\.order, order: .forward)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    /// 練習項目を追加
    func addItem(name: String, menu: PracticeMenu, context: ModelContext) -> PracticeItem {
        // 現在のメニュー内の最大順番を取得
        let maxOrder = getItemsForMenu(menu, context: context).map { $0.order }.max() ?? -1
        
        let item = PracticeItem(name: name, order: maxOrder + 1)
        item.menu = menu
        context.insert(item)
        try? context.save()
        return item
    }
    
    /// 練習項目を更新
    func updateItem(_ item: PracticeItem, context: ModelContext) {
        item.updatedAt = Date()
        try? context.save()
    }
    
    /// 練習項目を削除
    func deleteItem(_ item: PracticeItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }
    
    // MARK: - 順序変更関連
    
    /// メニューの順序を変更
    func reorderMenus(_ menus: [PracticeMenu], context: ModelContext) {
        for (index, menu) in menus.enumerated() {
            menu.order = index
            menu.updatedAt = Date()
        }
        try? context.save()
    }
    
    /// 練習項目の順序を変更
    func reorderItems(_ items: [PracticeItem], context: ModelContext) {
        for (index, item) in items.enumerated() {
            item.order = index
            item.updatedAt = Date()
        }
        try? context.save()
    }
} 