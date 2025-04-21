import Foundation
import SwiftData

@Model
final class AudioSourceInfo {
    var fileName: String
    var displayName: String
    var createdAt: Date
    var filePath: String
    var bookmarkData: Data?
    var duration: Double
    var notes: String?
    
    // A-Bループ設定
    var loopStart: Double?
    var loopEnd: Double?
    
    // 速度・ピッチ設定
    var playbackRate: Double
    var pitch: Double
    
    @Relationship(deleteRule: .noAction)
    var practiceItem: PracticeItem?
    
    init(
        fileName: String,
        displayName: String,
        filePath: String,
        bookmarkData: Data? = nil,
        duration: Double = 0,
        playbackRate: Double = 1.0,
        pitch: Double = 0.0,
        notes: String? = nil
    ) {
        self.fileName = fileName
        self.displayName = displayName
        self.createdAt = Date()
        self.filePath = filePath
        self.bookmarkData = bookmarkData
        self.duration = duration
        self.playbackRate = playbackRate
        self.pitch = pitch
        self.notes = notes
    }
}