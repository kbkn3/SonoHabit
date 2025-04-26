import SwiftUI

/// メトロノームビュー
struct MetronomeView: View {
    @ObservedObject var metronomeEngine: MetronomeEngine
    @State private var settings: MetronomeSettings
    @State private var showingAdvancedSettings = false
    @State private var showingAccentSettings = false
    @State private var customAccentPositions: [Bool] = []
    
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
        
        // カスタムアクセントポジションの初期化
        let positions = settings.customAccentPositions ?? []
        let beatsPerMeasure = settings.timeSignature.beatsPerMeasure
        var accentBools = Array(repeating: false, count: beatsPerMeasure)
        for pos in positions where pos < beatsPerMeasure {
            accentBools[pos] = true
        }
        self._customAccentPositions = State(initialValue: accentBools)
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
            
            // BPMプログレッション表示
            if settings.isProgressionEnabled, let _ = settings.targetBpm {
                ProgressView(value: metronomeEngine.progressPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.vertical, 4)
                
                Text("\(Int(metronomeEngine.progressPercentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
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
                            // BPMが変わったらターゲットBPMも調整する必要がある場合がある
                            if settings.isProgressionEnabled, let targetBpm = settings.targetBpm {
                                if settings.bpm >= targetBpm {
                                    settings.targetBpm = settings.bpm + 20
                                }
                            }
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
                        .onChange(of: settings.timeSignature) { newValue in
                            // 拍子が変わったらカスタムアクセントも更新
                            resetCustomAccentPositions(beatsPerMeasure: newValue.beatsPerMeasure)
                            settingsChanged()
                        }
                    }
                    
                    // アクセント設定
                    VStack(spacing: 8) {
                        CustomToggle(
                            isOn: settings.isAccentEnabled,
                            action: { newValue in
                                settings.isAccentEnabled = newValue
                                settingsChanged()
                            },
                            label: "アクセント",
                            icon: "speaker.wave.2"
                        )
                        
                        if settings.isAccentEnabled {
                            HStack {
                                Text("パターン")
                                    .font(.subheadline)
                                    .padding(.leading, 24)
                                
                                Spacer()
                                
                                Picker("パターン", selection: $settings.accentPattern) {
                                    ForEach(MetronomeSettings.AccentPatternType.allCases, id: \.self) { pattern in
                                        Text(pattern.displayName).tag(pattern)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: settings.accentPattern) { _ in
                                    settingsChanged()
                                }
                            }
                            
                            if settings.accentPattern == .custom {
                                Button(action: {
                                    withAnimation {
                                        showingAccentSettings.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(showingAccentSettings ? "パターン設定を隠す" : "パターン設定を表示")
                                            .font(.subheadline)
                                        
                                        Image(systemName: showingAccentSettings ? "chevron.up" : "chevron.down")
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.leading, 24)
                                }
                                
                                if showingAccentSettings {
                                    customAccentPatternView
                                        .padding(.top, 8)
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                    
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
                                    if newValue && settings.targetBpm == nil {
                                        settings.targetBpm = settings.bpm + 20
                                    }
                                    settingsChanged()
                                },
                                label: "BPM自動段階変化",
                                icon: "arrow.up.forward"
                            )
                            
                            if settings.isProgressionEnabled {
                                VStack(spacing: 16) {
                                    // 目標BPM設定
                                    NumberAdjustButton(
                                        value: settings.targetBpm ?? (settings.bpm + 20),
                                        range: 40...300,
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
                                        label: "変化量",
                                        unit: " bpm"
                                    )
                                    
                                    // 変化のタイプ選択
                                    HStack {
                                        Text("変化間隔")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Picker("変化間隔", selection: $settings.incrementInterval) {
                                            ForEach(MetronomeSettings.ProgressionIntervalType.allCases, id: \.self) { type in
                                                Text(type.displayName).tag(type)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .onChange(of: settings.incrementInterval) { _ in
                                            settingsChanged()
                                        }
                                    }
                                    
                                    // 増加間隔の値
                                    let intervalUnit = settings.incrementInterval == .measures ? " 小節" : " 秒"
                                    let intervalRange = settings.incrementInterval == .measures ? 1...16 : 5...120
                                    let intervalStep = settings.incrementInterval == .measures ? 1 : 5
                                    
                                    NumberAdjustButton(
                                        value: settings.incrementIntervalValue,
                                        range: intervalRange,
                                        step: intervalStep,
                                        onChange: { newValue in
                                            settings.incrementIntervalValue = newValue
                                            settingsChanged()
                                        },
                                        label: "間隔値",
                                        unit: intervalUnit
                                    )
                                    
                                    // プログレッション情報表示
                                    if let description = settings.getProgressionDescription() {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 4)
                                    }
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
                                        Text(sound.displayName).tag(sound)
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
    
    /// カスタムアクセントパターン設定ビュー
    private var customAccentPatternView: some View {
        VStack(alignment: .leading) {
            Text("カスタムアクセントパターン")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 24)
            
            HStack {
                ForEach(0..<customAccentPositions.count, id: \.self) { index in
                    Button(action: {
                        customAccentPositions[index].toggle()
                        updateCustomAccentPositions()
                    }) {
                        Circle()
                            .fill(customAccentPositions[index] ? Color.blue : Color.secondary.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(customAccentPositions[index] ? .white : .primary)
                            )
                    }
                }
            }
            .padding(.leading, 24)
        }
    }
    
    /// 再生/停止の切り替え
    private func togglePlayback() {
        if metronomeEngine.isPlaying {
            metronomeEngine.stop()
        } else {
            metronomeEngine.start()
        }
    }
    
    /// カスタムアクセントポジションをリセット
    private func resetCustomAccentPositions(beatsPerMeasure: Int) {
        customAccentPositions = Array(repeating: false, count: beatsPerMeasure)
        customAccentPositions[0] = true  // デフォルトで最初の拍にアクセント
        updateCustomAccentPositions()
    }
    
    /// カスタムアクセントポジションを設定に反映
    private func updateCustomAccentPositions() {
        var positions = [Int]()
        for (index, isAccent) in customAccentPositions.enumerated() {
            if isAccent {
                positions.append(index)
            }
        }
        settings.customAccentPositions = positions
        settingsChanged()
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