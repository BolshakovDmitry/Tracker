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
    
    var fullName: String {
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
}

// Основная модель Tracker (полностью иммутабельная)
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: TrackerSchedule
    let type: TrackerType
    
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: TrackerSchedule, type: TrackerType) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
    }
}

// Структура для хранения расписания трекера
struct TrackerSchedule: Hashable {
    let weekDays: Set<WeekDay> // Дни недели, когда трекер активен
    
    // Проверяет, активен ли трекер в определенный день недели
    func isActiveOn(weekDay: Int) -> Bool {
        return weekDays.contains { $0.rawValue == weekDay }
    }
    
    // Возвращает строковое представление расписания
    func getDescription() -> String {
        if weekDays.count == 7 {
            return "Каждый день"
        }
        
        let sortedDays = weekDays.sorted { $0.rawValue < $1.rawValue }
        return sortedDays.map { $0.fullName }.joined(separator: ", ")
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

// Класс TrackersViewController для работы с трекерами
class TrackersViewController1: UIViewController {
    // Категории с трекерами
    var categories: [TrackerCategory] = []
    
    // Выполненные трекеры
    var completedTrackers: [TrackerRecord] = []
    
    // Метод для отметки трекера как выполненного
    func completeTracker(id: UUID, date: Date) {
        let record = TrackerRecord(id: id, date: date)
        
        // Проверяем, не был ли трекер уже отмечен в эту дату
        if !completedTrackers.contains(record) {
            // Создаем новый массив с добавленной записью
            completedTrackers = completedTrackers + [record]
        }
    }
    
    // Метод для отмены отметки трекера как выполненного
    func uncompleteTracker(id: UUID, date: Date) {
        let record = TrackerRecord(id: id, date: date)
        
        // Создаем новый массив без этой записи
        completedTrackers = completedTrackers.filter { $0 != record }
    }
    
    // Метод для добавления трекера в категорию
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        var newCategories = [TrackerCategory]()
        var categoryExists = false
        
        for category in categories {
            if category.title == categoryTitle {
                // Создаем новый массив трекеров с добавленным трекером
                let newTrackers = category.trackers + [tracker]
                // Создаем новую категорию с обновленным массивом
                let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                newCategories.append(newCategory)
                categoryExists = true
            } else {
                // Оставляем категорию без изменений
                newCategories.append(category)
            }
        }
        
        // Если категории не существует, создаем новую
        if !categoryExists {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
        }
        
        // Присваиваем новый массив категорий
        categories = newCategories
    }
}
