# 実装計画案: 楽器演奏練習補助アプリケーション

## 1. 前提条件

開発体制: 個人開発 (ご自身 + Cursor等のAI支援活用)
ターゲットプラットフォーム: macOS / iOS (Universal App)
UIフレームワーク: SwiftUI
データ永続化/同期:
SwiftData を採用 (ローカルデータ管理)
CloudKit を利用 (メタデータのiCloud同期)
注意点: SwiftData は iOS 17 / macOS 14 以降が必要です。これより古いOSバージョンをサポートする必要がある場合は、Core Data を検討する必要があります。SwiftData+CloudKitの情報はCore Dataに比べまだ少ない可能性があります。
デザイン: 標準コンポーネント主体で機能実装を優先。
開発期間: 特に定めず、学習と並行して段階的に進める。

## 2. 開発環境セットアップ

最新の Xcode をインストール。
Git でバージョン管理リポジトリを作成 (例: GitHub)。
Xcode で新規プロジェクトを作成:
Template: macOS / iOS -> App
Interface: SwiftUI
Storage: SwiftData
Include Tests にチェック推奨
必要に応じてCursor等の開発支援ツールを設定。
プロジェクト構成をディレクトリ構造に合わせて整理。

## 3. 実装フェーズ (段階的アプローチ)

### フェーズ 1: データモデル定義と練習メニュー基本UI (MVPコア - Part 1)

目標: 練習メニューと練習項目の基本的な情報を登録・表示・編集・削除できるようにする。

#### タスク

1. SwiftData のデータモデルを定義する:
   - `Models/PracticeMenu.swift`: 名前、作成日など
   - `Models/PracticeItem.swift`: 名前、説明、順番、基本設定など
   - `Models/UserSettings.swift`: アプリ全体の設定

2. 基本UI実装:
   - `Views/Menu/MenuListView.swift`: 練習メニューの一覧表示画面
   - `Views/Menu/MenuDetailView.swift`: メニュー詳細表示
   - `Views/Menu/MenuEditView.swift`: メニュー追加・編集
   - `Views/PracticeItem/ItemListView.swift`: 練習項目一覧
   - `Views/PracticeItem/ItemDetailView.swift`: 項目詳細表示
   - `Views/PracticeItem/ItemEditView.swift`: 項目追加・編集

3. データ操作機能:
   - `Services/DataManager.swift`: データ操作基本機能実装
   - `@Environment(\.modelContext)` を利用したCRUD操作の実装
   - 基本的なエラーハンドリング

4. テスト:
   - 基本的なCRUD操作のユニットテスト
   - SwiftUIのプレビュー機能でUIの基本確認

### フェーズ 2: メトロノーム機能実装と連携 (MVPコア - Part 2)

目標: 独立したメトロノーム機能を実装し、練習項目と連携させる。MVPのコア機能完成。

#### タスク

1. メトロノームモデルとエンジン:
   - `Models/MetronomeSettings.swift`: BPM、拍子、小節数などの設定
   - `Services/MetronomeEngine.swift`: AVFoundationを使用したメトロノーム基本機能
   - `Resources/Sounds/Metronome/`: 基本的なクリック音を用意

2. メトロノームUI:
   - `Views/Practice/MetronomeView.swift`: メトロノーム操作UI
   - `Views/Components/CommonButtons.swift`: 再生/停止など共通ボタン
   - BPM設定のスライダー/入力フィールド実装

3. 練習項目との連携:
   - `PracticeItem` モデルに `metronomeSettings` 関連付け
   - 練習項目からメトロノーム設定を読み込み・保存する機能
   - 練習中にメトロノーム設定を変更した場合の保存確認機能

4. テスト:
   - メトロノームの正確性テスト
   - UIとの連携テスト
   - 異なるデバイス環境での動作確認

### フェーズ 3: メトロノーム機能拡張

目標: メトロノーム機能を要件に合わせて拡張する。

#### タスク

1. アクセント機能:
   - `Services/MetronomeAccentService.swift`: 拍子に応じたアクセント制御
   - アクセント用の音声ファイル追加
   - メトロノーム設定UIにアクセント設定追加

2. BPM自動段階上昇機能:
   - `Services/BpmProgressionService.swift`: 段階的BPM上昇ロジック
   - 開始BPM、目標BPM、増加量、切替タイミングの設定UI
   - 練習項目設定への保存機能

3. クリック音カスタマイズ:
   - 複数の音源ファイル追加と選択UI
   - ユーザー設定への保存機能
   - `Resources/Sounds/Metronome/` に複数の音源ファイル追加

4. UIの改善とテスト:
   - 視覚的フィードバック機能（拍子に合わせたアニメーション）
   - 全機能の統合テスト

### フェーズ 4: 録音機能実装

目標: 基本的な録音機能を追加し、練習項目と紐付ける。

#### タスク

1. 録音基本機能:
   - `Models/RecordingInfo.swift`: 録音情報モデルの作成
   - `Services/AudioRecorder.swift`: AVAudioRecorderを使用した録音制御
   - `Services/AudioInputManager.swift`: 入力ソース選択・管理

2. 録音設定と操作UI:
   - `Views/Practice/RecordingView.swift`: 録音制御UI
   - `Views/Components/AudioWaveformView.swift`: 波形表示コンポーネント
   - 入力レベルメーター実装

3. ファイル処理:
   - `Utilities/AudioConverter.swift`: MP3/AAC変換機能
   - `Services/FileManager.swift`: 録音ファイルの保存・管理
   - ファイル命名規則の実装（日時+項目名など）

4. 練習項目との連携:
   - `PracticeItem` と `RecordingInfo` の関連付け
   - 録音リスト表示と再生機能
   - 録音メタデータ（日時、長さ、評価メモなど）の保存

5. テスト:
   - 録音・再生機能のテスト
   - 長時間録音の安定性テスト
   - 異なる入力ソースでのテスト

### フェーズ 5: データ同期 (CloudKit)

目標: 練習メニューや設定、録音メタデータをiCloudで同期させる。

#### タスク

1. iCloud環境設定:
   - Apple Developer Programへの登録
   - Xcodeプロジェクト設定でiCloud(CloudKit)有効化
   - CloudKitコンテナ設定

2. SwiftDataとCloudKitの連携:
   - `@Model` モデルにcloudKitContainerIdentifier設定追加
   - `Services/CloudSyncManager.swift`: 同期状態管理・監視
   - 非同期データのローカル管理機能

3. 録音ファイル管理:
   - ファイル実体は同期対象外に設定
   - メタデータのみ同期する設計確認
   - デバイス固有ファイルパスの取り扱い

4. テストと検証:
   - 複数デバイス間での同期テスト
   - 同期競合の基本的なハンドリング検証
   - オフライン操作と再接続時の同期確認

### フェーズ 6: 音源再生機能

目標: 外部音源ファイルをインポートし、再生コントロールを可能にする。

#### タスク

1. 音源ファイル管理:
   - `Models/AudioSourceInfo.swift`: 音源ファイル情報モデル
   - `Utilities/SecurityScopeManager.swift`: セキュリティスコープアクセス管理
   - ファイルブックマーク保存・復元機能

2. ファイルインポート:
   - Document Picker実装（iOS/macOS対応）
   - `Extensions/AVFoundation+Extensions.swift`: メディア情報取得拡張
   - インポートファイルの基本情報抽出（長さ、形式など）

3. 再生機能実装:
   - `Services/AudioPlayer.swift`: AVPlayerを使用した再生制御
   - `Views/Practice/AudioPlayerView.swift`: 再生コントロールUI
   - シークバー、再生速度コントロール実装

4. 高度な再生機能:
   - `Views/Components/ABLoopControlView.swift`: A-Bループ設定UI
   - `Views/Components/TempoControlView.swift`: テンポ変更UI
   - `Views/Components/PitchControlView.swift`: ピッチ変更UI
   - `Services/AudioEffectProcessor.swift`: AVAudioEngineによる音声処理

5. 練習項目との連携:
   - `PracticeItem` と `AudioSourceInfo` の関連付け
   - 音源と録音の同時再生機能
   - 音量バランス調整UI

6. テスト:
   - 様々な形式のファイルでのテスト
   - エフェクト処理の音質・パフォーマンステスト
   - UIの使いやすさ検証

### フェーズ 7: 自己評価と練習テンプレート機能

目標: 自己評価機能とテンプレート機能を実装する。

#### タスク

1. 自己評価機能:
   - `Models/SelfEvaluation.swift`: 自己評価モデル
   - `Views/Components/SelfEvaluationView.swift`: 評価入力UI
   - 評価履歴の表示と分析機能

2. テンプレート機能:
   - `Models/MenuTemplate.swift`: テンプレートモデル
   - `Services/TemplateManager.swift`: テンプレート管理
   - `Views/Menu/MenuTemplatesView.swift`: テンプレート一覧・選択UI
   - 事前定義テンプレートの作成とカスタムテンプレート保存機能

3. 機能連携:
   - 練習完了時の自動評価リマインド
   - テンプレートからの新規メニュー作成フロー
   - データモデル間の関連付け最終調整

4. テスト:
   - 一連の使用フローテスト
   - データの整合性検証

### フェーズ 8: UI/UX改善と最終仕上げ

目標: アプリ全体の品質を高め、ユーザビリティを向上させる。

#### タスク

1. 全体的なUI/UX改善:
   - ナビゲーションフローの最適化
   - エラー表示・ユーザーフィードバックの改善
   - アクセシビリティ対応（VoiceOver等）

2. パフォーマンス最適化:
   - SwiftDataクエリの最適化
   - 音声処理の効率化
   - メモリ使用量の確認と最適化

3. エラーハンドリング強化:
   - エッジケースの対応
   - クラッシュ防止策の実装
   - 復旧機能の強化

4. 最終準備:
   - アイコン作成
   - App Store提出準備（スクリーンショット、説明文等）
   - プライバシーポリシー作成

## 4. 開発Tips

1. 小さく始める: 各フェーズの中でも、さらに小さなステップに分割して進める。
   - まず基本機能のみ実装し、動作確認後に拡張機能を追加
   - UIはシンプルに始め、機能が安定したら洗練させる

2. 学習と実践: 初めての技術要素については、公式ドキュメントやチュートリアルで学習しながら進める。
   - Apple Developer Documentation
   - WWDC動画（特にSwiftData, AVFoundation関連）
   - SwiftUI/AVFoundationチュートリアル

3. AI支援の活用: Cursor等のAIツールを積極的に活用する。
   - コード生成
   - デバッグ支援
   - 不明点の質問
   - リファクタリング提案

4. バージョン管理: Gitを効果的に活用する。
   - 機能ごとにブランチを作成
   - こまめなコミット
   - 適切なコミットメッセージ
   - プルリクエストを使った自己レビュー

5. テスト重視: 各機能の実装後、必ず以下のテストを行う。
   - ユニットテスト（コアロジック）
   - UI動作確認
   - エッジケースの検証
   - 異なるデバイスでの確認（iPhone/iPad/Mac）
