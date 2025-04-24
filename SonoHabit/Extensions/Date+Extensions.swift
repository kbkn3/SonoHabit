import Foundation

extension Date {
    /// 日付をyyyy/MM/dd形式の文字列で返す
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }
    
    /// 日付をyyyy/MM/dd HH:mm形式の文字列で返す
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: self)
    }
    
    /// 今日の日付かどうかを判定
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// 昨日の日付かどうかを判定
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// 過去1週間以内かどうかを判定
    var isWithinLastWeek: Bool {
        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return self >= oneWeekAgo
    }
} 