
import UIKit

// Основная модель Tracker (полностью иммутабельная)
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let type: TrackerType
    
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: [WeekDay], type: TrackerType) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
    }
}
