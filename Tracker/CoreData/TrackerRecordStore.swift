import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerRecordStoreProtocol {
    func isDoneTapped(tracker: TrackerRecord)
    func unDoneTapped(tracker: TrackerRecord)
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
    
    func isDoneTapped(tracker: TrackerRecord) {
        print("Добавление трекера к выполненным: \(tracker)")
        
        // Проверяем, является ли трекер нерегулярным событием
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            if let trackerCD = trackers.first {
                // Сначала записываем отметку о выполнении
                let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                trackerRecordCoreData.id = tracker.id
                trackerRecordCoreData.date = tracker.date
                
                try context.save()
                print("Трекер успешно отмечен как выполненный")
                
                // Если это нерегулярное событие, удаляем его
                if let type = trackerCD.type, type == "irregularEvent" {
                    context.delete(trackerCD)
                    try context.save()
                    print("Нерегулярное событие удалено после отметки")
                }
                
                delegate?.didUpdate()
            }
        } catch {
            print("Ошибка при работе с трекером: \(error)")
            context.rollback()
        }
    }
    
    func unDoneTapped(tracker: TrackerRecord) {
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
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date <= %@",
                                            id as CVarArg,
                                            calendar.startOfDay(for: date) as NSDate,
                                            calendar.endOfDay(for: date) as NSDate)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
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
