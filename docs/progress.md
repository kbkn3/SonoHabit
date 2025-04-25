# 進捗状況

## 2024-05-10

### フェーズ1: データモデル定義と練習メニュー基本UI

#### 実装済み機能:

1. **SwiftDataのデータモデル定義**
   - `PracticeMenu`: 練習メニューのデータモデル
   - `PracticeItem`: 練習項目のデータモデル
   - `UserSettings`: ユーザー設定のデータモデル

2. **データ操作機能の実装**
   - `DataManager`: データのCRUD操作などの基本機能
   - モデル間の関連付け設定

3. **UI実装**
   - `MenuListView`: 練習メニュー一覧表示と追加・削除・順序変更機能
   - `MenuDetailView`: メニュー詳細表示と編集、練習項目の追加・削除・順序変更機能
   - `ItemDetailView`: 練習項目の詳細表示
   - `ItemEditView`: 練習項目の編集機能

#### 次のステップ:

1. **フェーズ2: メトロノーム機能実装**
   - `MetronomeSettings`: メトロノーム設定のデータモデル
   - `MetronomeEngine`: AVFoundationを使用したメトロノーム基本機能
   - `MetronomeView`: メトロノーム操作UI
   - `PracticeItem`とメトロノーム設定の連携
