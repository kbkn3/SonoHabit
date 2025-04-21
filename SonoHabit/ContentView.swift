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
                Text("録音リスト（後で実装）")
                    .navigationTitle("録音")
            }
            .tabItem {
                Label("録音", systemImage: "mic")
            }
            .tag(1)
            
            NavigationStack {
                Text("設定（後で実装）")
                    .navigationTitle("設定")
            }
            .tabItem {
                Label("設定", systemImage: "gear")
            }
            .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PracticeMenu.self, PracticeItem.self], inMemory: true)
}
