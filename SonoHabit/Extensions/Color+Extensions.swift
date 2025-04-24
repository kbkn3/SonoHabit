import SwiftUI

extension Color {
    // アプリで使用する標準カラー
    static let primaryBackground = Color("PrimaryBackground", bundle: nil)
    static let secondaryBackground = Color("SecondaryBackground", bundle: nil)
    static let primaryText = Color("PrimaryText", bundle: nil)
    static let secondaryText = Color("SecondaryText", bundle: nil)

    // 評価用カラー
    static let goodRating = Color.green
    static let neutralRating = Color.orange
    static let badRating = Color.red

    // ユーティリティメソッド

    /// HEX文字列からColorを生成する
    static func fromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}
