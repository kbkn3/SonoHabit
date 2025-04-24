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
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                PracticeMenu.self,
                PracticeItem.self,
                RecordingInfo.self,
                AudioSourceInfoModel.self,
                UserSettings.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
} 