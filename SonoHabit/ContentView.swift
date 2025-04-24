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
                    SettingsView()
                }
            }
            .sheet(isPresented: $navigateToAbout) {
                NavigationView {
                    AboutView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PracticeMenu.self, PracticeItem.self, UserSettings.self], inMemory: true)
}
