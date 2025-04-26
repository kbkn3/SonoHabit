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

## 2024-05-12

### フェーズ3: メトロノーム機能拡張

#### 実装済み機能:

1. **アクセントパターン機能の強化**
   - `MetronomeAccentService`: アクセントパターンの生成と管理
   - アクセントパターンのタイプ（標準、裏拍、カスタム）の追加
   - 拍子に応じた適切なアクセントパターンの自動生成
   - カスタムアクセントパターンの編集UI

2. **BPMプログレッション機能の強化**
   - `BpmProgressionService`: BPM変化の詳細制御
   - 小節数ベースと時間ベースの2種類の変化タイプ
   - 上昇・下降両方向のBPM変化対応
   - 進行状況の視覚的表示

3. **データモデルとUI更新**
   - `MetronomeSettings`: モデルを拡張してアクセントパターンとBPMプログレッション設定を追加
   - `MetronomeEngine`: 新機能に対応するようにエンジンを更新
   - `MetronomeView`: 新しい設定のUIコントロールを追加
   - `ItemEditView`: メトロノーム設定の表示を拡張

### フェーズ4: 録音機能実装

#### 実装済み機能:

1. **録音関連データモデル**
   - `RecordingInfo`: 録音情報のデータモデル（メタデータ、ファイルパス、設定、自己評価など）
   - `PracticeItem`モデルとの関連付け

2. **録音エンジンと入力管理**
   - `AudioInputManager`: 入力ソース（マイク）の管理と選択UI
   - `AudioRecorder`: AVFoundationを使用した録音機能
   - 録音ファイルの保存と管理
   - 入力レベルのモニタリング

3. **UI実装**
   - `AudioWaveformView`: 音声レベルに応じた波形表示
   - `LevelMeterView`: 入力レベルのメーター表示
   - `RecordingTimerView`: 録音経過時間の表示
   - `RecordingView`: 録音操作UI
   - `RecordingListView`: 録音ファイル一覧と再生機能
   - `ItemDetailView`の更新: 録音機能との連携

#### 次のステップ:

1. **フェーズ5: データ同期 (CloudKit)**
   - iCloud環境設定とデータ同期機能の実装
   - SwiftDataとCloudKitの連携
   - デバイス間でのメタデータ同期

2. **フェーズ6: 音源再生機能**
   - 外部音源ファイルのインポートと管理
   - A-Bループ再生や再生速度変更などの機能
   - 録音と音源の同時再生
