import SwiftUI

extension View {
    /// ビューに丸みを帯びた背景と影を追加する
    func cardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
    }
    
    /// ビューに標準的なボタンスタイルを適用する
    func standardButtonStyle() -> some View {
        self
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    /// ビューをタップ可能なカード形式にする
    func tappableCardStyle(action: @escaping () -> Void) -> some View {
        self
            .cardStyle()
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
    }
    
    /// 条件付きで修飾子を適用する
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
} 