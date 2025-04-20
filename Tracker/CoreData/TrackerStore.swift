import UIKit
import CoreData

struct TrackerUpdate {
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(category: TrackerUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func sectionTitle(for section: Int) -> String?
}

class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var insertedSections: IndexSet = IndexSet()
    private var deletedSections: IndexSet = IndexSet()
    private weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    convenience init(delegate: TrackerStoreDelegate) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackerStoreDelegate?) {
        self.context = context
        self.delegate = delegate
        super.init()
    }
    
    // MARK: - Fetched Results Controller
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "categoryLink.title", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "categoryLink.title",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Core Data Utilities
    
    func deleteAllData() {
        let entities = context.persistentStoreCoordinator?.managedObjectModel.entities
        
        entities?.forEach { entity in
            if let entityName = entity.name {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(batchDeleteRequest)
                    try context.save()
                    print("Успешно удалены все данные из \(entityName)")
                } catch {
                    print("Ошибка при удалении данных из \(entityName): \(error)")
                }
            }
        }
    }
}

// MARK: - HabitCreationViewControllerDelegate

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
                trackerCD.categoryLink = categoryCD
                
                // 3. Добавляем трекер в категорию
                categoryCD.addToTrackers(trackerCD)
                
                // 4. Сохраняем контекст
                try context.save()
                print("Трекер успешно сохранен и привязан к категории")
            } else {
                print("Категория не найдена: \(category)")
                
                // Создаем новую категорию
                let newCategoryCD = TrackerCategoryCoreData(context: context)
                newCategoryCD.title = category
                
                // Создаем объект TrackerCoreData
                let trackerCD = TrackerCoreData(context: context)
                trackerCD.id = tracker.id
                trackerCD.name = tracker.name
                trackerCD.color = colorToHexString(color: tracker.color)
                trackerCD.emojii = tracker.emoji
                trackerCD.schedule = convertScheduleToCoreData(schedule: tracker.schedule)
                trackerCD.categoryLink = newCategoryCD
                
                // Добавляем трекер в категорию
                newCategoryCD.addToTrackers(trackerCD)
                
                // Сохраняем контекст
                try context.save()
                print("Создана новая категория и добавлен трекер")
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

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionTitle(for section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let tracker = fetchedResultsController.object(at: indexPath)
        
        if let color = tracker.color, let schedule = tracker.schedule {
            let convertedColor = hexStringToColor(hex: color)
            let convertedSchedule = convertCoreDataToSchedule(stringSchedule: schedule)
            
            return Tracker(
                id: tracker.id ?? UUID(),
                name: tracker.name ?? "",
                color: convertedColor ?? .ypBackground,
                emoji: tracker.emojii ?? "",
                schedule: convertedSchedule,
                type: .habit
            )
        }
        return nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(category: TrackerUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths
        ))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexPaths.append(newIndexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                deletedIndexPaths.append(indexPath)
                insertedIndexPaths.append(newIndexPath)
            }
        case .update:
            // Для обновлений обычно используется перезагрузка элемента
            if let indexPath = indexPath {
                // Мы можем добавить indexPath в список для перезагрузки, если нужно
            }
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        default:
            break
        }
    }
}
