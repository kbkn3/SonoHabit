# 進捗状況

## 2024-04-19

- プロジェクト初期設定完了
- SwiftDataモデル（PracticeMenu, PracticeItem, RecordingInfo, AudioSourceInfo, UserSettings）を実装
- 基本的なUI構造（タブビュー、ナビゲーションスタック）を実装
- MenuListView、MenuDetailViewの実装
- PracticeItemの編集機能の実装

## 2024-04-20

- メトロノーム機能の実装
  - MetronomeEngineサービスの作成
  - MetronomeViewの実装
  - BPM設定、拍子設定、自動BPM増加機能などの実装
- PracticeViewの実装と基本的な練習画面の構築
- 自己評価機能の基本実装

## 2024-04-21

- 録音機能の実装
  - AudioRecorderサービスの作成（AVFoundationを使用）
  - AudioPlayerサービスの作成（録音ファイル再生用）
  - FileManagerServiceの実装（録音ファイルの永続化管理）
  - 波形表示コンポーネント（AudioWaveformView）の実装
  - 録音UI（RecordingView）の実装
  - 録音リスト表示画面（RecordingListView）の実装
  - PracticeViewとの統合（タブインターフェースで切り替え可能）
  - 録音の保存、再生、削除機能の実装

## 2024-04-22

- 設定画面の実装
  - SettingsViewの作成（UserSettingsモデルと連携）
  - AboutViewの作成（アプリ情報表示用）
  - メトロノーム設定（デフォルトBPM、拍子、音源）の編集機能
  - 録音設定（音声フォーマット、ビットレート、ファイル名自動生成）の編集機能
  - アプリケーション設定（ダークモード、アプリ情報）の実装
  - ContentViewとの連携（タブインターフェース）

- 今後の実装予定
  - 設定画面とContentViewの連携の改善
  - 音源ファイル（メトロノーム音など）の追加
  - CloudKit連携の実装
  - UIの最適化とユーザーフィードバックの改善

## 2024-04-23

- メトロノーム用音源ファイルの追加
  - Resources/Sounds/Metronomeディレクトリに各種音源を追加
  - 通常のクリック音（click.wav, woodblock.wav, bongo.wav）
  - アクセント音（click_accent.wav, woodblock_accent.wav, bongo_accent.wav）
  - メトロノームエンジンとの連携を確認

## 2024-04-24

- 設定画面とContentViewの連携を改善
  - ContentViewのタブ構造を見直し
  - SettingsTabViewを中間層として実装
  - モーダル表示（sheet）による設定画面とアプリ情報画面の表示
  - プレースホルダー実装（SettingsViewPlaceholder, AboutViewPlaceholder）の追加
  - 実際のSettingsViewやAboutViewとの連携はプロジェクト構造上の問題があるため、プレースホルダーで代替

- 今後の実装予定
  - CloudKit連携の実装
  - UIの最適化とユーザーフィードバックの改善
  - プロジェクト構造の見直しと整理

## 2023/05/20 - プロジェクト構造の見直しと整理

### 実施した作業
1. ディレクトリ構造をプランに合わせて整理
   - `Model` → `Models` へリネーム
   - `App` ディレクトリを追加し、エントリポイントを移動
   - 空の `Extensions` と `Utilities` ディレクトリに実装を追加

2. 未実装だったサービスの追加
   - `DataManager.swift` を実装
   - `CloudSyncManager.swift` を実装

3. ユーティリティとエクステンションの実装
   - `Date+Extensions.swift` の追加
   - `View+Extensions.swift` の追加
   - `Color+Extensions.swift` の追加
   - `Constants.swift` の追加
   - `Logger.swift` の追加 
   - `AudioConverter.swift` の追加

4. 未実装だったビューコンポーネントの追加
   - `SelfEvaluationView.swift` の実装
   - `CommonButtons.swift` の実装

5. 未実装だった画面の追加
   - `MenuEditView.swift` の実装
   - `MenuTemplatesView.swift` の実装
   - `ItemEditView.swift` の実装

### 注意点
- 既存ファイルの参照パスは更新が必要（例：モデルファイルのインポート）
- サービスクラスの実装はスケルトンのみなので、実際の機能は今後実装が必要
- 新しく追加したビューは既存のナビゲーションに組み込む必要あり

## 2023/05/21 - 新しい画面構造の統合

### 実施した作業
1. ContentViewの更新
   - プレースホルダービュー（SettingsViewPlaceholder, AboutViewPlaceholder）を削除
   - 実際の`SettingsView`と`AboutView`をナビゲーションに組み込み

2. MenuListViewの更新
   - NavigationLinkの遷移先を`MenuDetailView`に変更
   - メニュー追加機能を`MenuEditView`に置き換え
   - テンプレート機能への新しいボタンを追加（`MenuTemplatesView`への遷移）

3. MenuDetailViewの更新
   - 内部の`EditMenuView`を`MenuEditView`に置き換え
   - 内部の`AddPracticeItemView`を`ItemEditView`に置き換え

4. ItemDetailViewの更新
   - 内部の`EditItemView`を`ItemEditView`に置き換え
   - 自己評価機能のセクションを追加（`SelfEvaluationView`への遷移）

### 注意点
- 一部のファイルでリンターエラーが発生しているため、別途修正が必要
- モデル変数名（例：`itemDescription`）とビュー名（例：`description`）の不一致を確認する必要がある

# 作業進捗メモ
