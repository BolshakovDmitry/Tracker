import UIKit
import CoreData

class TrackerStore {
    
    private let context: NSManagedObjectContext
    private let convertedSchedule: String = ""
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerStore: HabitCreationViewControllerDelegate {
    func didCreateTracker(tracker: Tracker, category: String) {
        print("============================", tracker, category)
        
        // 1. Находим категорию по имени
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", category)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let categoryCD = categories.first {
                // 2. Создаем объект TrackerCoreData
                let trackerCD = TrackerCoreData(context: context)
                trackerCD.id = tracker.id
                trackerCD.name = tracker.name
                trackerCD.color = colorToHexString(color: tracker.color)
                trackerCD.emojii = tracker.emoji
                trackerCD.schedule = convertScheduleToCoreData(schedule: tracker.schedule)
                
                // 3. Добавляем трекер в категорию
                categoryCD.addToTrackers(trackerCD)
                
                // 4. Сохраняем контекст
                try context.save()
                print("Трекер успешно сохранен и привязан к категории")
            } else {
                print("Категория не найдена: \(category)")
            }
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
            context.rollback()
        }
    }
    
    func convertScheduleToCoreData(schedule: [WeekDay]) -> String {
        let convertedString = schedule.map { String($0.rawValue) }.joined(separator: ",")
        return convertedString
    }
    
    func convertCoreDataToSchedule(stringSchedule: String) -> [WeekDay] {
        guard !stringSchedule.isEmpty else { return [] }
        
        let stringArray = stringSchedule.split(separator: ",")
        var schedule: [WeekDay] = []
        
        for stringValue in stringArray {
            if let intValue = Int(stringValue),
               let weekDay = WeekDay(rawValue: intValue) {
                schedule.append(weekDay)
            }
        }
        
        return schedule
    }
    
    private func colorToHexString(color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
    
    // Метод для преобразования строки HEX в UIColor
    private func hexStringToColor(hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
