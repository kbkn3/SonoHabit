import SwiftUI
import SwiftData

/// 練習メニューテンプレートの一覧・選択画面
struct MenuTemplatesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    /// テンプレート選択完了時のコールバック
    var onTemplateSelected: (PracticeMenu) -> Void

    /// プリセットテンプレート
    private let templates = [
        TemplateDefinition(
            name: "基本練習（ギター）",
            description: "ギター基礎練習のためのテンプレート",
            items: [
                "スケール練習（Cメジャー）",
                "アルペジオ練習（Cメジャー）",
                "クロマチック練習",
                "コード進行練習（Cメジャー）"
            ]
        ),
        TemplateDefinition(
            name: "基本練習（ベース）",
            description: "ベース基礎練習のためのテンプレート",
            items: [
                "指弾き練習",
                "スケール練習（Cメジャー）",
                "アルペジオ練習（Cメジャー）",
                "スラップ練習"
            ]
        ),
        TemplateDefinition(
            name: "テクニック練習",
            description: "様々なテクニックを練習するためのテンプレート",
            items: [
                "チョーキング",
                "ハンマリング・オン",
                "プリング・オフ",
                "スウィープピッキング",
                "トリル"
            ]
        )
    ]

    var body: some View {
        List {
            Section(header: Text("テンプレートを選択")) {
                ForEach(templates) { template in
                    Button(
                        action: {
                            createMenuFromTemplate(template)
                        },
                        label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(template.name)
                                    .font(.headline)

                                if let description = template.description {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Text("項目: \(template.items.count)個")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    )
                }
            }
        }
        .navigationTitle("メニューテンプレート")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
    }

    /// テンプレートから練習メニューを作成する
    private func createMenuFromTemplate(_ template: TemplateDefinition) {
        // 新しいメニューを作成
        let newMenu = PracticeMenu(name: template.name)
        newMenu.description = template.description

        // 項目を追加
        for (index, itemName) in template.items.enumerated() {
            let newItem = PracticeItem(name: itemName, order: index + 1)
            newMenu.addToItems(newItem)
        }

        // モデルにメニューを追加
        modelContext.insert(newMenu)

        // コールバックを呼び出す
        onTemplateSelected(newMenu)

        // ビューを閉じる
        dismiss()
    }
}

/// テンプレート定義
struct TemplateDefinition: Identifiable {
    let id = UUID()
    let name: String
    let description: String?
    let items: [String]

    init(name: String, description: String? = nil, items: [String]) {
        self.name = name
        self.description = description
        self.items = items
    }
}

#Preview {
    NavigationStack {
        MenuTemplatesView { _ in
            // プレビューでは何もしない
        }
    }
}
