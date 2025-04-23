import SwiftUI

struct AboutView: View {
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
            
            Section(header: Text("クレジット")) {
                Text("開発者: 小林建太")
                
                Link("ソースコード", destination: URL(string: "https://github.com/yourusername/SonoHabit")!)
                    .foregroundColor(.accentColor)
            }
        }
        .navigationTitle("アプリについて")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
} 