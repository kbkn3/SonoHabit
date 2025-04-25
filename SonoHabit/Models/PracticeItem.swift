import Foundation
import SwiftData

// 自己評価用の埋め込みモデル
struct SelfEvaluation: Codable, Hashable {
    var date: Date
    var rating: Rating
    var notes: String?

    enum Rating: Int, Codable, Hashable {
        case good = 3
        case ok = 2
        case needsWork = 1

        var emoji: String {
            switch self {
            case .good: return "🙂"
            case .ok: return "😐"
            case .needsWork: return "😕"
            }
        }
    }
}

@Model
final class PracticeItem {
    var name: String
    var itemDescription: String
    var order: Int
    var createdAt: Date

    // メトロノーム設定
    var bpm: Int
    var timeSignatureNumerator: Int
    var timeSignatureDenominator: Int
    var totalBars: Int
    var repeatCount: Int
    var autoIncreaseBPM: Bool
    var maxBPM: Int?
    var bpmIncrement: Int?

    // 関連
    // 注：循環参照を避けるため、一時的にコメントアウト
    // @Relationship(deleteRule: .noAction)
    // var menu: PracticeMenu?

    @Relationship(deleteRule: .cascade, inverse: \RecordingInfo.practiceItem)
    var recordings: [RecordingInfo] = []

    @Relationship(deleteRule: .cascade, inverse: \AudioSourceInfoModel.practiceItem)
    var audioSources: [AudioSourceInfoModel] = []

    // 評価履歴
    @Transient
    var selfEvaluations: [SelfEvaluation] = []

    init(
        name: String,
        itemDescription: String = "",
        order: Int = 0,
        bpm: Int = 120,
        timeSignatureNumerator: Int = 4,
        timeSignatureDenominator: Int = 4,
        totalBars: Int = 4,
        repeatCount: Int = 1,
        autoIncreaseBPM: Bool = false,
        maxBPM: Int? = nil,
        bpmIncrement: Int? = nil
    ) {
        self.name = name
        self.itemDescription = itemDescription
        self.order = order
        self.createdAt = Date()
        self.bpm = bpm
        self.timeSignatureNumerator = timeSignatureNumerator
        self.timeSignatureDenominator = timeSignatureDenominator
        self.totalBars = totalBars
        self.repeatCount = repeatCount
        self.autoIncreaseBPM = autoIncreaseBPM
        self.maxBPM = maxBPM
        self.bpmIncrement = bpmIncrement
    }
}
