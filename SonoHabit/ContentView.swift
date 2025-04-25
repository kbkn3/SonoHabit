//
//  ContentView.swift
//  SonoHabit
//
//  Created by 小林建太 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        MenuListView()
            .onAppear {
                setupInitialData()
            }
    }
    
    private func setupInitialData() {
        // ユーザー設定の初期化
        _ = DataManager.shared.getUserSettings(context: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PracticeMenu.self, PracticeItem.self, UserSettings.self], inMemory: true)
}
