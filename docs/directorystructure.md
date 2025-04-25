# ディレクトリ構造

```
SonoHabit/
├── App/
│   ├── SonoHabitApp.swift          # アプリケーションのエントリーポイント
│   ├── AppDelegate.swift           # 必要に応じてアプリケーションの設定と初期化
│   └── Info.plist                  # アプリケーション設定ファイル
│
├── Models/                         # SwiftDataモデル
│   ├── PracticeMenu.swift          # 練習メニューモデル
│   ├── PracticeItem.swift          # 練習項目モデル
│   ├── RecordingInfo.swift         # 録音情報モデル
│   ├── AudioSourceInfo.swift       # 音源ファイル情報モデル
│   ├── SelfEvaluation.swift        # 自己評価モデル
│   ├── MenuTemplate.swift          # メニューテンプレートモデル
│   ├── MetronomeSettings.swift     # メトロノーム設定モデル
│   └── UserSettings.swift          # ユーザー設定モデル
│
├── Views/
│   ├── Menu/                       # メニュー関連画面
│   │   ├── MenuListView.swift      # 練習メニュー一覧画面
│   │   ├── MenuDetailView.swift    # 練習メニュー詳細画面
│   │   ├── MenuEditView.swift      # 練習メニュー編集画面
│   │   └── MenuTemplatesView.swift # メニューテンプレート画面
│   │
│   ├── PracticeItem/               # 練習項目関連画面
│   │   ├── ItemListView.swift      # 練習項目一覧画面
│   │   ├── ItemDetailView.swift    # 練習項目詳細画面
│   │   └── ItemEditView.swift      # 練習項目編集画面
│   │
│   ├── Practice/                   # 練習実行関連画面
│   │   ├── PracticeView.swift      # 練習実行メイン画面
│   │   ├── MetronomeView.swift     # メトロノーム表示・操作コンポーネント
│   │   ├── RecordingView.swift     # 録音表示・操作コンポーネント
│   │   └── AudioPlayerView.swift   # 音源再生表示・操作コンポーネント
│   │
│   ├── Settings/                   # 設定関連画面
│   │   ├── SettingsView.swift      # 設定メイン画面
│   │   ├── AudioSettingsView.swift # オーディオ設定画面
│   │   └── AboutView.swift         # アプリ情報画面
│   │
│   └── Components/                 # 共通コンポーネント
│       ├── SelfEvaluationView.swift     # 自己評価入力コンポーネント
│       ├── AudioWaveformView.swift      # 音声波形表示コンポーネント
│       ├── ABLoopControlView.swift      # A-Bループコントロールコンポーネント
│       ├── TempoControlView.swift       # テンポ変更コントロール
│       ├── PitchControlView.swift       # ピッチ変更コントロール
│       └── CommonButtons.swift          # 共通ボタン定義
│
├── Services/                       # ビジネスロジック層
│   ├── MetronomeEngine.swift       # メトロノームエンジン
│   ├── MetronomeAccentService.swift # メトロノームアクセント機能
│   ├── BpmProgressionService.swift  # BPM自動段階上昇機能
│   ├── AudioRecorder.swift         # 録音機能
│   ├── AudioInputManager.swift     # 入力ソース管理
│   ├── AudioPlayer.swift           # 音源再生機能
│   ├── AudioEffectProcessor.swift  # テンポ・ピッチ変更処理
│   ├── DataManager.swift           # データ管理・永続化処理
│   ├── CloudSyncManager.swift      # iCloud同期管理
│   ├── TemplateManager.swift       # テンプレート管理
│   └── FileManager.swift           # ファイル操作ユーティリティ
│
├── Extensions/                     # 拡張機能
│   ├── Date+Extensions.swift       # 日付操作拡張
│   ├── View+Extensions.swift       # SwiftUI View拡張
│   ├── AVFoundation+Extensions.swift # AVFoundation関連拡張
│   └── Color+Extensions.swift      # カラー定義拡張
│
├── Utilities/                      # ユーティリティ
│   ├── AudioConverter.swift        # オーディオ形式変換
│   ├── SecurityScopeManager.swift  # セキュリティスコープ管理
│   ├── Constants.swift             # 定数定義
│   └── Logger.swift                # ロギングユーティリティ
│
├── Resources/                      # リソースファイル
│   ├── Sounds/                     # 音声ファイル
│   │   ├── Metronome/              # メトロノーム音
│   │   └── UI/                     # UI効果音
│   │
│   ├── Assets.xcassets/            # 画像リソース
│   └── Localizable.strings         # 多言語対応用文字列
│
└── Tests/                          # テスト
    ├── ModelTests/                 # モデルテスト
    ├── ServiceTests/               # サービステスト
    └── UITests/                    # UIテスト
```

## 注意点

1. **プラットフォーム固有のコード**:
   - ディレクトリ構造は基本的に共通だが、macOSとiOSで異なる実装が必要な場合は、該当ファイル内で条件分岐を行う
   - 例: `#if os(macOS)` / `#if os(iOS)` などの条件コンパイル文を使用

2. **SwiftData関連**:
   - モデル定義はModelsディレクトリに配置
   - 永続化ロジックはDataManagerサービスに集約
   - CloudKit同期のための設定はモデルに直接記述（@Model属性のパラメータとして）

3. **ファイル命名規則**:
   - キャメルケース（先頭大文字）
   - 役割が明確になる命名
   - View関連は末尾に「View」を付加
   - Service関連は機能を表す名前に「Service」または「Engine」「Manager」を付加

4. **ディレクトリ拡張**:
   - 機能追加に伴い、適宜ディレクトリを追加・整理する
   - 同種の機能は同じディレクトリにまとめる

5. **外部ファイル操作**:
   - インポートした外部ファイルへのアクセスはSecurityScopeManagerで管理
   - ファイルブックマーク情報はAudioSourceInfoモデルに保存
