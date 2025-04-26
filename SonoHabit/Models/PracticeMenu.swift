import Foundation
import SwiftData

@Model
final class PracticeMenu {
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var order: Int
    var isActive: Bool
    
    @Relationship(deleteRule: .cascade)
    var items: [PracticeItem]
    
    init(name: String, order: Int = 0, isActive: Bool = true) {
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.order = order
        self.isActive = isActive
        self.items = []
    }
} 