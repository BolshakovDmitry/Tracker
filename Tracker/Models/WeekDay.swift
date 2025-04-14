
import Foundation

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
