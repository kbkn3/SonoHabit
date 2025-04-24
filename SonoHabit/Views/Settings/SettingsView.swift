import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userSettings: [UserSettings]

    @State private var defaultBPM: Int = 120
    @State private var defaultTimeSignatureNumerator: Int = 4
    @State private var defaultTimeSignatureDenominator: Int = 4
    @State private var metronomeSound: String = "click"
    @State private var accentSound: String = "accent"
    @State private var audioFormat: AudioFormat = .m4a
    @State private var audioBitRate: Int = 128000
    @State private var automaticNaming: Bool = true
    @State private var darkModeEnabled: Bool = false
    @State private var showingAboutView = false

    var settings: UserSettings? {
        userSettings.first
    }

    var body: some View {
        Form {
            Section(header: Text("メトロノーム設定")) {
                Stepper("デフォルトBPM: \(defaultBPM)", value: $defaultBPM, in: 40...240)

                Picker("デフォルト拍子", selection: $defaultTimeSignatureNumerator) {
                    ForEach(2..<9) { num in
                        Text("\(num)/\(defaultTimeSignatureDenominator)")
                            .tag(num)
                    }
                }

                Picker("拍子単位", selection: $defaultTimeSignatureDenominator) {
                    Text("2").tag(2)
                    Text("4").tag(4)
                    Text("8").tag(8)
                }

                Picker("メトロノーム音", selection: $metronomeSound) {
                    Text("クリック").tag("click")
                    Text("ウッドブロック").tag("woodblock")
                    Text("ボンゴ").tag("bongo")
                }

                Picker("アクセント音", selection: $accentSound) {
                    Text("クリック").tag("click_accent")
                    Text("ウッドブロック").tag("woodblock_accent")
                    Text("ボンゴ").tag("bongo_accent")
                }
            }

            Section(header: Text("録音設定")) {
                Picker("音声フォーマット", selection: $audioFormat) {
                    Text("M4A").tag(AudioFormat.m4a)
                    Text("MP3").tag(AudioFormat.mp3)
                    Text("WAV").tag(AudioFormat.wav)
                }

                Picker("ビットレート", selection: $audioBitRate) {
                    Text("96 kbps").tag(96000)
                    Text("128 kbps").tag(128000)
                    Text("192 kbps").tag(192000)
                    Text("256 kbps").tag(256000)
                }

                Toggle("自動ファイル名生成", isOn: $automaticNaming)
            }

            Section(header: Text("アプリケーション")) {
                Toggle("ダークモード", isOn: $darkModeEnabled)
                    .onChange(of: darkModeEnabled) { _, newValue in
                        updateAppearance(darkMode: newValue)
                    }

                NavigationLink(destination: AboutView()) {
                    Text("アプリについて")
                }
            }
        }
        .navigationTitle("設定")
        .onAppear {
            loadSettings()
        }
        .onChange(of: defaultBPM) { _, _ in saveSettings() }
        .onChange(of: defaultTimeSignatureNumerator) { _, _ in saveSettings() }
        .onChange(of: defaultTimeSignatureDenominator) { _, _ in saveSettings() }
        .onChange(of: metronomeSound) { _, _ in saveSettings() }
        .onChange(of: accentSound) { _, _ in saveSettings() }
        .onChange(of: audioFormat) { _, _ in saveSettings() }
        .onChange(of: audioBitRate) { _, _ in saveSettings() }
        .onChange(of: automaticNaming) { _, _ in saveSettings() }
    }

    private func loadSettings() {
        if let settings = settings {
            defaultBPM = settings.defaultBPM
            defaultTimeSignatureNumerator = settings.defaultTimeSignatureNumerator
            defaultTimeSignatureDenominator = settings.defaultTimeSignatureDenominator
            metronomeSound = settings.metronomeSound
            accentSound = settings.accentSound
            audioFormat = settings.audioFormat
            audioBitRate = settings.audioBitRate
            automaticNaming = settings.automaticNaming
            darkModeEnabled = settings.darkModeEnabled ?? false
        } else {
            // 初期設定がない場合は作成
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }

    private func saveSettings() {
        if let settings = settings {
            settings.defaultBPM = defaultBPM
            settings.defaultTimeSignatureNumerator = defaultTimeSignatureNumerator
            settings.defaultTimeSignatureDenominator = defaultTimeSignatureDenominator
            settings.metronomeSound = metronomeSound
            settings.accentSound = accentSound
            settings.audioFormat = audioFormat
            settings.audioBitRate = audioBitRate
            settings.automaticNaming = automaticNaming
            settings.darkModeEnabled = darkModeEnabled

            try? modelContext.save()
        }
    }

    private func updateAppearance(darkMode: Bool) {
        #if os(iOS)
        // iOSの場合、ユーザー設定に応じて切り替えるコードをここに実装
        // これは単なるプレースホルダーであり、実際にはシステム設定を変更できない
        #endif
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(for: [UserSettings.self], inMemory: true)
    }
}
