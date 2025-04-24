import SwiftUI

/// プライマリーアクションボタン
struct PrimaryButton: View {
    let text: String
    let icon: String?
    let action: () -> Void
    
    /// 標準的なプライマリーボタン
    /// - Parameters:
    ///   - text: ボタンのテキスト
    ///   - icon: システムアイコン名（オプション）
    ///   - action: タップ時のアクション
    init(_ text: String, icon: String? = nil, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(text)
            }
            .frame(minWidth: 100)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

/// セカンダリーアクションボタン
struct SecondaryButton: View {
    let text: String
    let icon: String?
    let action: () -> Void
    
    /// 標準的なセカンダリーボタン
    /// - Parameters:
    ///   - text: ボタンのテキスト
    ///   - icon: システムアイコン名（オプション）
    ///   - action: タップ時のアクション
    init(_ text: String, icon: String? = nil, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(text)
            }
            .frame(minWidth: 100)
            .padding()
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        }
    }
}

/// アイコンのみのボタン
struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    /// アイコンのみのボタン
    /// - Parameters:
    ///   - icon: システムアイコン名
    ///   - color: アイコンの色
    ///   - action: タップ時のアクション
    init(_ icon: String, color: Color = .accentColor, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .frame(width: 44, height: 44)
                .foregroundColor(color)
                .background(Color(.secondarySystemBackground))
                .clipShape(Circle())
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("保存", icon: "checkmark") {}
        SecondaryButton("キャンセル", icon: "xmark") {}
        HStack {
            IconButton("play.fill") {}
            IconButton("stop.fill", color: .red) {}
            IconButton("square.and.arrow.up") {}
        }
    }
    .padding()
} 