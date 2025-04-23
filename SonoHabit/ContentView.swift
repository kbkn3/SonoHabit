//
//  ContentView.swift
//  SonoHabit
//
//  Created by 小林建太 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MenuListView()
            }
            .tabItem {
                Label("メニュー", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationStack {
                RecordingListView()
            }
            .tabItem {
                Label("録音", systemImage: "mic")
            }
            .tag(1)
            
            NavigationStack {
                SettingsTabView()
            }
            .tabItem {
                Label("設定", systemImage: "gear")
            }
            .tag(2)
        }
    }
}

// 設定画面への中間層
struct SettingsTabView: View {
    @State private var navigateToSettings = false
    @State private var navigateToAbout = false
    
    var body: some View {
        VStack {
            Text("設定")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Form {
                Section {
                    Button("設定を開く") {
                        navigateToSettings = true
                    }
                    
                    Button("アプリについて") {
                        navigateToAbout = true
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $navigateToSettings) {
                NavigationView {
                    SettingsViewPlaceholder()
                }
            }
            .sheet(isPresented: $navigateToAbout) {
                NavigationView {
                    AboutViewPlaceholder()
                }
            }
        }
    }
}

// プレースホルダービュー
struct SettingsViewPlaceholder: View {
    var body: some View {
        Text("設定画面（開発中）")
            .navigationTitle("設定")
    }
}

// プレースホルダービュー
struct AboutViewPlaceholder: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("SonoHabit")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("バージョン 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Section(header: Text("アプリについて")) {
                Text("SonoHabitは楽器演奏練習をサポートするためのアプリです。メトロノーム機能、録音機能、練習メニュー管理機能を提供し、効率的な練習をサポートします。")
                    .font(.body)
            }
            
            Section(header: Text("機能")) {
                Label("練習メニュー管理", systemImage: "list.bullet")
                Label("メトロノーム", systemImage: "metronome")
                Label("録音と再生", systemImage: "mic")
                Label("自己評価", systemImage: "star")
            }
        }
        .navigationTitle("アプリについて")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PracticeMenu.self, PracticeItem.self, UserSettings.self], inMemory: true)
}
