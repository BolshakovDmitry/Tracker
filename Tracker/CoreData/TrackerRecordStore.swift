import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerRecordStoreProtocol {
    func isDoneTapped(tracker: TrackerRecord, trackerType: TrackerType)
    func unDoneTapped(tracker: TrackerRecord, trackerType: TrackerType)
    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool
    func countCompletedDays(id: UUID) -> Int
}

class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Initialization
    
    convenience init(delegate: TrackerRecordStoreDelegate) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackerRecordStoreDelegate?) {
        self.context = context
        self.delegate = delegate
        super.init()
    }
    
    // MARK: - Fetched Results Controller
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - TrackerRecordStoreProtocol
    
    func isDoneTapped(tracker: TrackerRecord, trackerType: TrackerType) {
        
        
        if trackerType == .habit {
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.id = tracker.id
            trackerRecordCoreData.date = tracker.date
            
            do {
                try context.save()
                print("Трекер успешно отмечен как выполненный")
                delegate?.didUpdate()
            } catch {
                print("Ошибка при сохранении трекера: \(error)")
                context.rollback()
            }
        } else {
            
            // Для нерегулярных событий
                    do {
                        // 1. Создаем запись в TrackerRecordCoreData для текущего дня
                        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                        trackerRecordCoreData.id = tracker.id
                        trackerRecordCoreData.date = tracker.date
                        
                        // 2. Находим сам трекер в TrackerCoreData
                        let fetchTrackerRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
                        fetchTrackerRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
                        
                        let trackers = try context.fetch(fetchTrackerRequest)
                        if let trackerCD = trackers.first {
                            

                            // 3. Определяем текущий день недели
                            let calendar = Calendar.current
                            let weekdayComponent = calendar.component(.weekday, from: tracker.date)
                            
                            // 4. Преобразуем в формат WeekDay (учитывая разницу в нумерации)
                            let weekDay = WeekDay.from(weekdayComponent)
                            
                            // 5. Обновляем расписание, оставляя только текущий день
                            trackerCD.schedule = convertScheduleToCoreData(schedule: [weekDay])
                            
                            // 6. Сохраняем изменения
                            try context.save()
                            print("Нерегулярное событие обновлено: расписание изменено на день \(weekDay)")
                            
                            delegate?.didUpdate()
                        } else {
                            print("Трекер не найден")
                        }
                    } catch {
                        print("Ошибка при обработке нерегулярного события: \(error)")
                        context.rollback()
                    }
                }
    }
    
    
    func unDoneTapped(tracker: TrackerRecord, trackerType: TrackerType) {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let calendar = Calendar.current
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date <= %@",
                                           tracker.id as CVarArg,
                                           calendar.startOfDay(for: tracker.date) as NSDate,
                                           calendar.endOfDay(for: tracker.date) as NSDate)
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
            print("Запись о выполнении трекера удалена")
            delegate?.didUpdate()
        } catch {
            print("Ошибка при удалении записи трекера: \(error)")
            context.rollback()
        }
    }
    
    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        // Получаем все записи для данного трекера
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            
            // Проверяем, есть ли запись с той же датой (только день)
            for record in records {
                if let recordDate = record.date {
                    if calendar.isDate(recordDate, inSameDayAs: date) {
                        return true
                    }
                }
            }
            return false
        } catch {
            print("Ошибка при проверке статуса трекера: \(error)")
            return false
        }
    }
    
    func countCompletedDays(id: UUID) -> Int {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Ошибка при подсчете дней: \(error)")
            return 0
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Подготовка к изменениям
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомление об изменениях
        delegate?.didUpdate()
    }
    
    func convertScheduleToCoreData(schedule: [WeekDay]) -> String {
        let convertedString = schedule.map { String($0.rawValue) }.joined(separator: ",")
        return convertedString
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(for: date))!
    }
}
