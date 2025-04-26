import SwiftUI

/// メトロノームビュー
struct MetronomeView: View {
    @ObservedObject var metronomeEngine: MetronomeEngine
    @State private var settings: MetronomeSettings
    @State private var showingAdvancedSettings = false
    
    var onSettingsChanged: ((MetronomeSettings) -> Void)?
    
    init(settings: MetronomeSettings, engine: MetronomeEngine? = nil, onSettingsChanged: ((MetronomeSettings) -> Void)? = nil) {
        self._settings = State(initialValue: settings)
        if let engine = engine {
            self.metronomeEngine = engine
        } else {
            self.metronomeEngine = MetronomeEngine()
        }
        self.onSettingsChanged = onSettingsChanged
        
        // 初期設定をエンジンに適用
        self.metronomeEngine.applySettings(from: settings)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // テンポと拍子表示
            HStack {
                TempoDisplay(bpm: metronomeEngine.currentBpm)
                
                Spacer()
                
                TimeSignatureDisplay(timeSignature: metronomeEngine.currentTimeSignature)
            }
            .padding(.bottom, 16)
            
            // ビジュアルコンポーネント
            MetronomeVisualizer(
                currentBeat: metronomeEngine.currentBeat,
                beatsPerMeasure: metronomeEngine.currentTimeSignature.beatsPerMeasure,
                isPlaying: metronomeEngine.isPlaying,
                isAccentEnabled: metronomeEngine.isAccentEnabled
            )
            .frame(height: 80)
            
            // 再生/停止ボタン
            PlayStopButton(
                isPlaying: metronomeEngine.isPlaying,
                action: togglePlayback,
                size: 80,
                color: .blue
            )
            .padding()
            
            Divider()
            
            // 基本設定
            ScrollView {
                VStack(spacing: 20) {
                    // BPM設定
                    NumberAdjustButton(
                        value: settings.bpm,
                        range: 40...240,
                        step: 5,
                        onChange: { newValue in
                            settings.bpm = newValue
                            settingsChanged()
                        },
                        label: "テンポ",
                        unit: " bpm"
                    )
                    
                    // 拍子設定
                    HStack {
                        Text("拍子")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("拍子", selection: $settings.timeSignature) {
                            ForEach(MetronomeSettings.TimeSignature.allCases, id: \.self) { timeSignature in
                                Text(timeSignature.rawValue).tag(timeSignature)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: settings.timeSignature) { _ in
                            settingsChanged()
                        }
                    }
                    
                    // アクセント設定
                    CustomToggle(
                        isOn: settings.isAccentEnabled,
                        action: { newValue in
                            settings.isAccentEnabled = newValue
                            settingsChanged()
                        },
                        label: "アクセント",
                        icon: "speaker.wave.2"
                    )
                    
                    // 小節数設定
                    NumberAdjustButton(
                        value: settings.measuresCount,
                        range: 1...16,
                        onChange: { newValue in
                            settings.measuresCount = newValue
                            settingsChanged()
                        },
                        label: "小節数",
                        unit: " 小節"
                    )
                    
                    // 詳細設定トグル
                    HStack {
                        Text("詳細設定")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showingAdvancedSettings.toggle()
                            }
                        }) {
                            HStack {
                                Text(showingAdvancedSettings ? "隠す" : "表示")
                                
                                Image(systemName: showingAdvancedSettings ? "chevron.up" : "chevron.down")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // 詳細設定セクション
                    if showingAdvancedSettings {
                        VStack(alignment: .leading, spacing: 16) {
                            // BPM自動上昇設定
                            CustomToggle(
                                isOn: settings.isProgressionEnabled,
                                action: { newValue in
                                    settings.isProgressionEnabled = newValue
                                    settingsChanged()
                                },
                                label: "BPM自動段階上昇",
                                icon: "arrow.up.forward"
                            )
                            
                            if settings.isProgressionEnabled {
                                VStack(spacing: 16) {
                                    // 目標BPM設定
                                    NumberAdjustButton(
                                        value: settings.targetBpm ?? (settings.bpm + 20),
                                        range: settings.bpm...300,
                                        step: 5,
                                        onChange: { newValue in
                                            settings.targetBpm = newValue
                                            settingsChanged()
                                        },
                                        label: "目標BPM",
                                        unit: " bpm"
                                    )
                                    
                                    // BPM増加量
                                    NumberAdjustButton(
                                        value: settings.bpmIncrement,
                                        range: 1...20,
                                        onChange: { newValue in
                                            settings.bpmIncrement = newValue
                                            settingsChanged()
                                        },
                                        label: "増加量",
                                        unit: " bpm"
                                    )
                                    
                                    // 増加間隔（小節数）
                                    NumberAdjustButton(
                                        value: settings.incrementMeasures,
                                        range: 1...16,
                                        onChange: { newValue in
                                            settings.incrementMeasures = newValue
                                            settingsChanged()
                                        },
                                        label: "増加間隔",
                                        unit: " 小節"
                                    )
                                }
                                .padding(.leading, 16)
                            }
                            
                            // クリック音選択
                            HStack {
                                Text("クリック音")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Picker("クリック音", selection: $settings.clickSound) {
                                    ForEach(MetronomeSettings.ClickSound.allCases, id: \.self) { sound in
                                        Text(sound.rawValue).tag(sound)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: settings.clickSound) { _ in
                                    settingsChanged()
                                }
                            }
                        }
                        .padding(.leading, 16)
                        .transition(.opacity)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
    
    /// 再生/停止の切り替え
    private func togglePlayback() {
        if metronomeEngine.isPlaying {
            metronomeEngine.stop()
        } else {
            metronomeEngine.start()
        }
    }
    
    /// 設定変更時のハンドリング
    private func settingsChanged() {
        metronomeEngine.applySettings(from: settings)
        onSettingsChanged?(settings)
    }
}

/// プレビュー
struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = MetronomeSettings()
        let engine = MetronomeEngine()
        
        MetronomeView(settings: settings, engine: engine)
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 