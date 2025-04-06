import Foundation
import UIKit

import UIKit
import Foundation

// Перечисление для определения типа трекера
enum TrackerType {
    case habit            // Привычка (регулярная)
    case irregularEvent   // Нерегулярное событие
}

// Структура для хранения дней недели
enum WeekDay: Int, CaseIterable, Hashable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    var localizedName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    static var allDays: [WeekDay] {
        return WeekDay.allCases.sorted { $0.rawValue < $1.rawValue }
    }
    
    
    var numberValue: Int {
        switch self {
        case .monday: return 2    // В Calendar.current понедельник = 2
        case .tuesday: return 3   // В Calendar.current вторник = 3
        case .wednesday: return 4 // И т.д.
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1    // В Calendar.current воскресенье = 1
        }
    }
}

// Основная модель Tracker (полностью иммутабельная)
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
    let type: TrackerType
    
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: Set<WeekDay>, type: TrackerType) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
    }
}
// Модель для хранения категорий трекеров (полностью иммутабельная)
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

// Модель для хранения завершенных трекеров (полностью иммутабельная)
struct TrackerRecord: Hashable {
    let id: UUID  // ID трекера
    let date: Date // Дата выполнения
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}

