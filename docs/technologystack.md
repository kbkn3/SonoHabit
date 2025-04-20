# 技術スタック

## プラットフォーム

- macOS / iOS (ユニバーサルアプリ)
- 最小要件: iOS 17 / macOS 14 以降（SwiftData の要件による）

## 開発環境

- 言語: Swift
- IDE: Xcode (最新バージョン推奨)
- バージョン管理: Git (GitHub 等)

## UI フレームワーク

- SwiftUI

## データ管理

- ローカルデータ: SwiftData
- クラウド同期: CloudKit (Apple Developer Program アカウント必須)
- 録音ファイル: ローカルストレージに保存（同期対象外）

## オーディオ処理

- AVFoundation
  - AVAudioEngine: オーディオ処理パイプライン
  - AVAudioRecorder: 録音機能
  - AVAudioPlayer: 音声ファイル再生
  - AVPlayer: メディア再生
  - AVAudioSession: オーディオ入出力管理
- オプション: MP3 エンコード用ライブラリ (初期実装では m4a 形式も検討)

## ファイル操作

- FileManager: ローカルファイル管理
- Document Picker: ファイルインポート (iCloud Drive, Dropbox 等からのアクセス)

## サードパーティライブラリ

- 初期開発では極力使用を避け、Apple 標準フレームワークで実装
- 必要に応じて検討：
  - MP3 エンコード用ライブラリ（必要な場合）

## デバイス要件

- 内蔵マイク、または外部オーディオインターフェース対応
- iCloud 連携機能は Apple アカウントが必要

## 将来的な技術拡張可能性

- 収益化: StoreKit (App 内課金)
- クラウドストレージ: CloudKit 拡張 or サードパーティ API との連携
- AI フィードバック: Core ML / CreateML
