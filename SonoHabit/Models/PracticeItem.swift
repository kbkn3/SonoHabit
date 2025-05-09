import Foundation
import SwiftData

@Model
final class PracticeItem {
    var name: String
    var itemDescription: String
    var createdAt: Date
    var updatedAt: Date
    var order: Int
    var isActive: Bool
    
    var useMetronome: Bool
    var useRecording: Bool
    var useAudioSource: Bool
    
    @Relationship(deleteRule: .nullify)
    var menu: PracticeMenu?
    
    // 関連モデルへの参照
    @Relationship(deleteRule: .cascade)
    var metronomeSettings: MetronomeSettings?
    
    @Relationship(deleteRule: .cascade, inverse: \RecordingInfo.practiceItem) 
    var recordings: [RecordingInfo] = []
    
    // @Relationship var audioSourceInfo: AudioSourceInfo?
    // @Relationship var selfEvaluations: [SelfEvaluation] = []
    
    init(name: String, 
         description: String = "", 
         order: Int = 0, 
         isActive: Bool = true,
         useMetronome: Bool = false,
         useRecording: Bool = false,
         useAudioSource: Bool = false) {
        self.name = name
        self.itemDescription = description
        self.createdAt = Date()
        self.updatedAt = Date()
        self.order = order
        self.isActive = isActive
        self.useMetronome = useMetronome
        self.useRecording = useRecording
        self.useAudioSource = useAudioSource
        
        // メトロノームを使用する場合はデフォルト設定で初期化
        if useMetronome {
            self.metronomeSettings = MetronomeSettings()
        }
    }
} 