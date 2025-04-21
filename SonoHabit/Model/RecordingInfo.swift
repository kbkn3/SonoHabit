import Foundation
import SwiftData

@Model
final class RecordingInfo {
    var fileName: String
    var displayName: String
    var createdAt: Date
    var filePath: String
    var duration: Double
    var fileSize: Int64
    var notes: String?
    var selfEvaluation: SelfEvaluation?
    
    @Relationship(deleteRule: .noAction)
    var practiceItem: PracticeItem?
    
    init(
        fileName: String,
        displayName: String,
        filePath: String,
        duration: Double = 0,
        fileSize: Int64 = 0,
        notes: String? = nil
    ) {
        self.fileName = fileName
        self.displayName = displayName
        self.createdAt = Date()
        self.filePath = filePath
        self.duration = duration
        self.fileSize = fileSize
        self.notes = notes
    }
} 