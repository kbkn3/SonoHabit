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

## 2024-05-11

### フェーズ2: メトロノーム機能実装と連携

#### 実装済み機能:

1. **メトロノーム関連データモデル**
   - `MetronomeSettings`: メトロノーム設定のデータモデル（BPM、拍子、小節数、アクセント、自動BPM上昇など）
   - `PracticeItem`モデルとの関連付け

2. **メトロノームエンジン**
   - `MetronomeEngine`: AVFoundationを使用したメトロノーム基本機能
   - 正確なタイミングでのビート生成
   - アクセント機能
   - BPM自動段階上昇機能

3. **UI実装**
   - `CommonButtons`: 再生/停止ボタン、数値調整ボタン、トグルスイッチなどの共通コンポーネント
   - `MetronomeVisualizer`: 拍子に合わせた視覚的フィードバック
   - `MetronomeView`: メトロノーム操作UI
   - `ItemDetailView`の更新: メトロノーム設定の表示と編集
   - `ItemEditView`の更新: メトロノーム設定の有効化/無効化処理

#### 残課題:

1. **メトロノーム音声ファイル**
   - サンプルのクリック音を追加する必要あり -＞ 手動で追加した
     - `SonoHabit/Resources/Sounds/Metronome/bongo.wav`
     - `SonoHabit/Resources/Sounds/Metronome/bongo_accent.wav`
     - `SonoHabit/Resources/Sounds/Metronome/click.wav`
     - `SonoHabit/Resources/Sounds/Metronome/click_accent.wav`
     - `SonoHabit/Resources/Sounds/Metronome/woodblock.wav`
     - `SonoHabit/Resources/Sounds/Metronome/woodblock_accent.wav`

#### 次のステップ:

1. **フェーズ3: メトロノーム機能拡張**
   - `MetronomeAccentService`: アクセントパターンのカスタマイズ
   - `BpmProgressionService`: より高度なBPM変化パターン

2. **フェーズ4: 録音機能実装**
   - `RecordingInfo`: 録音情報モデル
   - `AudioRecorder`: 録音機能
   - 録音管理UI
