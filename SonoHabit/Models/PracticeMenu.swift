import Foundation
import SwiftData

@Model
final class PracticeMenu {
    var name: String
    var menuDescription: String
    var createdAt: Date
    var icon: String?

    @Relationship(deleteRule: .cascade, inverse: \PracticeItem.menu)
    var items: [PracticeItem] = []

    init(name: String, description: String = "", icon: String? = nil) {
        self.name = name
        self.menuDescription = description
        self.createdAt = Date()
        self.icon = icon
    }
}
