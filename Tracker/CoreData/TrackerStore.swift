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
    func filterCategories(by weekday: Int, searchText: String?)
}

class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var insertedSections: IndexSet = IndexSet()
    private var deletedSections: IndexSet = IndexSet()
    private weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    
    // Все категории и трекеры
    private(set) var categories: [TrackerCategory] = []
    // Отфильтрованные категории и трекеры (по текущему дню)
    private(set) var visibleCategories: [TrackerCategory] = []
    
    // Текущий день недели для фильтрации
    private var currentWeekday: Int = Calendar.current.component(.weekday, from: Date())
    private var currentSearchText: String?
    
    // MARK: - Initialization
    
    convenience init(delegate: TrackerStoreDelegate) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackerStoreDelegate?) {
        self.context = context
        self.delegate = delegate
        super.init()
        
        // При инициализации загружаем все категории и фильтруем по текущему дню
        loadAllCategories()
        filterVisibleCategories()
    }
    
    // MARK: - Data Loading
    
    private func loadAllCategories() {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            categories = convertCDToCategories(categoriesCoreData)
            for item in categories {
                print("++++++++++++++", item)
            }

        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }
    
    private func convertCDToCategories(_ categoriesCD: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        return categoriesCD.compactMap { categoryCD in
            guard let title = categoryCD.title else { return nil }
            
            // Получаем трекеры из категории
            let trackersCD = categoryCD.trackers?.allObjects as? [TrackerCoreData] ?? []
            let trackers = trackersCD.compactMap { trackerCD -> Tracker? in
                guard let id = trackerCD.id,
                      let name = trackerCD.name,
                      let color = trackerCD.color,
                      let emoji = trackerCD.emojii,
                      let scheduleString = trackerCD.schedule else { return nil }
                
                // Определяем тип трекера
                let trackerType: TrackerType
                if let typeString = trackerCD.type, typeString == "irregularEvent" {
                    trackerType = .irregularEvent
                } else {
                    trackerType = .habit
                }
                
                let schedule = convertCoreDataToSchedule(stringSchedule: scheduleString)
                let trackerColor = hexStringToColor(hex: color) ?? .gray
                
                return Tracker(id: id, name: name, color: trackerColor, emoji: emoji, schedule: schedule, type: trackerType)
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    // MARK: - Filtering
    
    func filterCategories(by weekday: Int, searchText: String? = nil) {
        currentWeekday = weekday
        currentSearchText = searchText
        filterVisibleCategories()
        
        // Уведомляем делегат о необходимости обновить UI
        let update = TrackerUpdate(
            insertedSections: IndexSet(0..<visibleCategories.count),
            deletedSections: IndexSet(),
            insertedIndexPaths: [],
            deletedIndexPaths: []
        )
        delegate?.didUpdate(category: update)
    }
    
    private func filterVisibleCategories() {
        if currentSearchText == nil || currentSearchText?.isEmpty == true {
            // Фильтрация с учетом нерегулярных событий
            visibleCategories = categories.map { category in
                TrackerCategory(
                    title: category.title,
                    trackers: category.trackers.filter { tracker in
                        // Нерегулярные события показываем всегда
                        if tracker.type == .irregularEvent {
                            print("YEHHHHHHHHHHHH!!!!!!!!!!!!!!!!!!!!!!!!!")
                                return true
                            }
                        // Регулярные события фильтруем по дню недели
                       return tracker.schedule.contains { weekDay in
                            weekDay.numberValue == currentWeekday
                        }
                    }
                )
            }.filter { !$0.trackers.isEmpty }
        } else {
            // Фильтрация по дню недели, типу и тексту поиска
            visibleCategories = categories.map { category in
                TrackerCategory(
                    title: category.title,
                    trackers: category.trackers.filter { tracker in
                        let matchesWeekday = tracker.type == .irregularEvent ||
                            tracker.schedule.contains { weekDay in
                                weekDay.numberValue == currentWeekday
                            }
                        let matchesSearchText = tracker.name.lowercased().contains(currentSearchText!.lowercased())
                        return matchesWeekday && matchesSearchText
                    }
                )
            }.filter { !$0.trackers.isEmpty }
        }
        for item in visibleCategories {
            print("visibleCategories at the moment", item)
        }
        
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

    // MARK: - Helper Methods
    
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

// MARK: - HabitCreationViewControllerDelegate

extension TrackerStore: HabitCreationViewControllerDelegate {
    func didCreateTracker(tracker: Tracker, category: String) {
        
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
                trackerCD.type = tracker.type == .irregularEvent ? "irregularEvent" : "habit"
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
                trackerCD.type = tracker.type == .irregularEvent ? "irregularEvent" : "habit"
                newCategoryCD.addToTrackers(trackerCD)
                
                // Сохраняем контекст
                try context.save()
                print("Создана новая категория и добавлен трекер")
            }
            
            // После успешного сохранения обновляем наши локальные категории
            loadAllCategories()
            filterVisibleCategories()
            
            // Уведомляем о изменениях
            let update = TrackerUpdate(
                insertedSections: IndexSet(0..<visibleCategories.count),
                deletedSections: IndexSet(),
                insertedIndexPaths: [],
                deletedIndexPaths: []
            )
            delegate?.didUpdate(category: update)
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
            context.rollback()
        }
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        return visibleCategories.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard section < visibleCategories.count else { return 0 }
        return visibleCategories[section].trackers.count
    }
    
    func sectionTitle(for section: Int) -> String? {
        guard section < visibleCategories.count else { return nil }
        return visibleCategories[section].title
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        guard indexPath.section < visibleCategories.count,
              indexPath.row < visibleCategories[indexPath.section].trackers.count else {
            return nil
        }
        print("В методе object класса TrackerStore", visibleCategories[indexPath.section].trackers[indexPath.row])
        return visibleCategories[indexPath.section].trackers[indexPath.row]
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
        // При любых изменениях в Core Data
        loadAllCategories()      // Обновляем все категории
        filterVisibleCategories() // Перефильтровываем видимые

        // Уведомляем делегат о изменениях
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
            if let _ = indexPath {
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
