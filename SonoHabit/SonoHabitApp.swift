//
//  SonoHabitApp.swift
//  SonoHabit
//
//  Created by 小林建太 on 2025/04/19.
//

import SwiftUI
import SwiftData

@main
struct SonoHabitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PracticeMenu.self, PracticeItem.self, UserSettings.self])
    }
}
