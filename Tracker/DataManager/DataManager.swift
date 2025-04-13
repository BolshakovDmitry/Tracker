import UIKit

final class DataManager {
    
    static let shared = DataManager()
    
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    private init(){
        createInitialMockData()
    }
    
    func updateCategories(with updatedCategories: [TrackerCategory]){
        categories = updatedCategories
        visibleCategories = updatedCategories
    }
    
    // Создание начальных моковых данных
    func createInitialMockData() {
        // Создаем две категории с двумя трекерами в каждой
        
        // Первая категория "Спорт"
        let sportCategory = TrackerCategory(
            title: "Спорт",
            trackers: [
                Tracker(
                    name: "Бег по утрам",
                    color: UIColor(red: 0.2, green: 0.81, blue: 0.41, alpha: 1.0),
                    emoji: "🏃‍♂️",
                    schedule: Set([.monday, .wednesday, .friday]),
                    type: .habit
                ),
                Tracker(
                    name: "Отжимания",
                    color: UIColor(red: 0.51, green: 0.17, blue: 0.94, alpha: 1.0),
                    emoji: "💪",
                    schedule: Set([.tuesday, .thursday, .saturday]),
                    type: .habit
                )
            ]
        )
        
        // Вторая категория "Саморазвитие"
        let selfDevelopmentCategory = TrackerCategory(
            title: "Саморазвитие",
            trackers: [
                Tracker(
                    name: "Чтение книг",
                    color: UIColor(red: 0.47, green: 0.58, blue: 0.96, alpha: 1.0),
                    emoji: "📚",
                    schedule: Set(WeekDay.allCases), // Ежедневно
                    type: .habit
                ),
                Tracker(
                    name: "Медитация",
                    color: UIColor(red: 1.00, green: 0.60, blue: 0.80, alpha: 1.0),
                    emoji: "🧘‍♂️",
                    schedule: Set([.monday, .wednesday, .friday, .sunday]),
                    type: .habit
                )
            ]
        )
        
         //Сохраняем моковые категории
        visibleCategories = [sportCategory, selfDevelopmentCategory]
        categories = [sportCategory, selfDevelopmentCategory]
    }
    
    
}
