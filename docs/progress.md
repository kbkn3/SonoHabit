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
