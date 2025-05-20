import UIKit
import CoreData

struct TrackerUpdate {
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func deleteTracker(at indexPath: IndexPath) -> Bool
    func pinTracker(tracker: Tracker, isPinned: Bool) -> Bool
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func getCategory(at indexPath: IndexPath) -> String
    func sectionTitle(for section: Int) -> String?
    func filterCategories(by weekday: Int, searchText: String?, filterQuery: FilterType)
    func filterVisibleCategories()
    
    func loadAllCategories()
    func getCompletedDaysCount(for trackerId: UUID) -> Int
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
    private var currentFilterQuery: FilterType?
    
    // MARK: - Initialization
    
    convenience init(delegate: TrackerStoreDelegate) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("App delegate not found or not of type AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext
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
    
    func loadAllCategories() {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            var allCategories = convertCDToCategories(categoriesCoreData)
            
            // Сортируем категории, но выносим "Закрепленные" наверх
            allCategories.sort { (category1, category2) -> Bool in
                if category1.title == NSLocalizedString("pinned", comment: "") {
                    return true // "Закрепленные" всегда в начале
                } else if category2.title == NSLocalizedString("pinned", comment: "") {
                    return false // Другая категория после "Закрепленные"
                } else {
                    return category1.title < category2.title // Обычная алфавитная сортировка
                }
            }
            
            categories = allCategories
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
    
    func filterCategories(by weekday: Int, searchText: String? = nil, filterQuery: FilterType) {
        currentWeekday = weekday
        currentSearchText = searchText
        currentFilterQuery = filterQuery
        filterVisibleCategories()
        
        // Уведомляем делегат о необходимости обновить UI

        delegate?.didUpdate()
    }
    
    func filterVisibleCategories() {
        if currentFilterQuery == .all {
            if currentSearchText == nil || currentSearchText?.isEmpty == true {
                // Фильтрация с учетом нерегулярных событий
                visibleCategories = categories.map { category in
                    TrackerCategory(
                        title: category.title,
                        trackers: category.trackers.filter { tracker in
                            // Нерегулярные события показываем только если день соответствует текущему ( при первом добавлении нерегулярного события - у него отмечены все дни,  соответственно до нажатия на кнопку выполнено у ячейки, трекер будет виден каждый день - после нажатия у него создается запись в trackerRecord  на выполненный день,  а все остальные дни удаляются
                            
                            if category.title == NSLocalizedString("pinned", comment: "") { return true }
                            
                            if tracker.type == .irregularEvent && tracker.schedule.contains(where: { weekDay in
                                weekDay.numberValue == currentWeekday
                            }) { return true }
                            
                            
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
        }
        
        if currentFilterQuery == .today {
            
            let calendar = Calendar.current
            let chosenDay = calendar.component(.weekday, from:  Date())
            currentWeekday = chosenDay
            
            if currentSearchText == nil || currentSearchText?.isEmpty == true {
                // Фильтрация с учетом нерегулярных событий
                visibleCategories = categories.map { category in
                    TrackerCategory(
                        title: category.title,
                        trackers: category.trackers.filter { tracker in
                            // Нерегулярные события показываем только если день соответствует текущему ( при первом добавлении нерегулярного события - у него отмечены все дни,  соответственно до нажатия на кнопку выполнено у ячейки, трекер будет виден каждый день - после нажатия у него создается запись в trackerRecord  на выполненный день,  а все остальные дни удаляются
                            
                            if category.title == NSLocalizedString("pinned", comment: "") { return true }
                            
                            if tracker.type == .irregularEvent && tracker.schedule.contains(where: { weekDay in
                                weekDay.numberValue == currentWeekday
                            }) { return true }
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
        }
        if currentFilterQuery == .completed {
            print("in the .completed")
            if currentSearchText == nil || currentSearchText?.isEmpty == true {
                // Фильтрация с учетом нерегулярных событий
                visibleCategories = categories.map { category in
                    TrackerCategory(
                        title: category.title,
                        trackers: category.trackers.filter { tracker in
                            // Нерегулярные события показываем только если день соответствует текущему ( при первом добавлении нерегулярного события - у него отмечены все дни,  соответственно до нажатия на кнопку выполнено у ячейки, трекер будет виден каждый день - после нажатия у него создается запись в trackerRecord  на выполненный день,  а все остальные дни удаляются
                            
                            if category.title == NSLocalizedString("pinned", comment: "") { return true }
                            
                            if tracker.type == .irregularEvent && tracker.schedule.contains(where: { weekDay in
                                weekDay.numberValue == currentWeekday
                            }) { return true }
                            
                            let isDoneToday = isTrackerCompletedToday(id: tracker.id)
                            // Регулярные события фильтруем по дню недели
                            return tracker.schedule.contains { weekDay in
                                weekDay.numberValue == currentWeekday
                            } && isDoneToday
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
                            
                            let isDoneToday = isTrackerCompletedToday(id: tracker.id)
                            
                            let matchesSearchText = tracker.name.lowercased().contains(currentSearchText!.lowercased())
                            return matchesWeekday && matchesSearchText && isDoneToday
                        }
                    )
                }.filter { !$0.trackers.isEmpty }
            }
        }
        
        if currentFilterQuery == .uncompleted {
            print("in the .completed")
            if currentSearchText == nil || currentSearchText?.isEmpty == true {
                // Фильтрация с учетом нерегулярных событий
                visibleCategories = categories.map { category in
                    TrackerCategory(
                        title: category.title,
                        trackers: category.trackers.filter { tracker in
                            // Нерегулярные события показываем только если день соответствует текущему ( при первом добавлении нерегулярного события - у него отмечены все дни,  соответственно до нажатия на кнопку выполнено у ячейки, трекер будет виден каждый день - после нажатия у него создается запись в trackerRecord  на выполненный день,  а все остальные дни удаляются
                            
                            if category.title == NSLocalizedString("pinned", comment: "") { return true }
                            
                            if tracker.type == .irregularEvent && tracker.schedule.contains(where: { weekDay in
                                weekDay.numberValue == currentWeekday
                            }) { return true }
                            
                            let isDoneToday = isTrackerCompletedToday(id: tracker.id)
                            // Регулярные события фильтруем по дню недели
                            return tracker.schedule.contains { weekDay in
                                weekDay.numberValue == currentWeekday
                            } && !isDoneToday
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
        }

        
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        let date = Date()
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

// MARK: - TrackerCreationViewControllerDelegate

extension TrackerStore: TrackerCreationViewControllerDelegate {
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
            
            delegate?.didUpdate()
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
            context.rollback()
        }
    }
    
    // MARK: -  Update
    
    func updateTracker(tracker: Tracker, category: String) -> Bool {
        
        print("in the update section")
        
        // 1. Находим трекер по ID
        let trackerFetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        // 2. Находим категорию по имени
        let categoryFetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        categoryFetchRequest.predicate = NSPredicate(format: "title == %@", category)
        
        do {
            // Получаем трекер для обновления
            let trackerResults = try context.fetch(trackerFetchRequest)
            
            guard let trackerToUpdate = trackerResults.first else {
                print("Трекер с ID \(tracker.id) не найден для обновления")
                return false
            }
            
            // Получаем категорию
            let categoryResults = try context.fetch(categoryFetchRequest)
            
            let categoryCD: TrackerCategoryCoreData
            
            if let existingCategory = categoryResults.first {
                categoryCD = existingCategory
            } else {
                // Создаем новую категорию, если не нашли существующую
                categoryCD = TrackerCategoryCoreData(context: context)
                categoryCD.title = category
            }
            
            // Обновляем свойства трекера
            trackerToUpdate.name = tracker.name
            trackerToUpdate.color = colorToHexString(color: tracker.color)
            trackerToUpdate.emojii = tracker.emoji
            trackerToUpdate.schedule = convertScheduleToCoreData(schedule: tracker.schedule)
            trackerToUpdate.type = tracker.type == .irregularEvent ? "irregularEvent" : "habit"
            
            // Если категория изменилась, обновляем отношение
            if trackerToUpdate.categoryLink != categoryCD {
                // Удаляем из старой категории
                if let oldCategory = trackerToUpdate.categoryLink {
                    oldCategory.removeFromTrackers(trackerToUpdate)
                }
                
                // Добавляем в новую категорию
                categoryCD.addToTrackers(trackerToUpdate)
                trackerToUpdate.categoryLink = categoryCD
            }
            
            // Сохраняем изменения
            try context.save()
            
//            // После успешного сохранения обновляем наши локальные категории
//            loadAllCategories()
//            filterVisibleCategories() // надо бы вынести это все таки сюда из трекерsVC
            
            // Уведомляем делегат об изменениях
            delegate?.didUpdate()
            
            return true
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
            context.rollback()
            return false
        }
    }
    
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
 
    func getCompletedDaysCount(for trackerId: UUID) -> Int {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.count
        } catch {
            print("Ошибка при получении количества выполненных дней: \(error)")
            return 0
        }
    }
    
    
    // MARK: -  Pin/InPin
    
    func pinTracker(tracker: Tracker, isPinned: Bool) -> Bool {
        // Название категории для закрепленных трекеров
        let pinnedCategoryName = NSLocalizedString("pinned", comment: "")
        
        // 1. Находим трекер по ID
        let trackerFetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        // 2. Подготавливаем запрос для категории "Закрепленные"
        let pinnedCategoryFetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        pinnedCategoryFetchRequest.predicate = NSPredicate(format: "title == %@", pinnedCategoryName)
        
        do {
            // Получаем трекер для обновления
            let trackerResults = try context.fetch(trackerFetchRequest)
            
            guard let trackerToUpdate = trackerResults.first else {
                print("Трекер с ID \(tracker.id) не найден для закрепления/открепления")
                return false
            }
            
            if isPinned {
                // Закрепляем трекер - перемещаем в категорию "Закрепленные"
                
                // Ищем категорию "Закрепленные" или создаем ее, если не существует
                let pinnedCategoryResults = try context.fetch(pinnedCategoryFetchRequest)
                
                let pinnedCategoryCD: TrackerCategoryCoreData
                
                if let existingPinnedCategory = pinnedCategoryResults.first {
                    pinnedCategoryCD = existingPinnedCategory
                } else {
                    // Создаем новую категорию для закрепленных трекеров
                    pinnedCategoryCD = TrackerCategoryCoreData(context: context)
                    pinnedCategoryCD.title = pinnedCategoryName
                }
                
                // Запоминаем текущую категорию в дополнительном свойстве
                // в модели CoreData
                if trackerToUpdate.originalCategory == nil {
                    trackerToUpdate.originalCategory = trackerToUpdate.categoryLink?.title
                }
                
                // Удаляем из текущей категории
                if let oldCategory = trackerToUpdate.categoryLink {
                    oldCategory.removeFromTrackers(trackerToUpdate)
                }
                
                // Добавляем в категорию "Закрепленные"
                pinnedCategoryCD.addToTrackers(trackerToUpdate)
                trackerToUpdate.categoryLink = pinnedCategoryCD
                
            } else {
                // Открепляем трекер - возвращаем в исходную категорию
                
                // Если у трекера есть сохраненная исходная категория
                if let originalCategoryName = trackerToUpdate.originalCategory {
                    // Находим исходную категорию
                    let originalCategoryFetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
                    originalCategoryFetchRequest.predicate = NSPredicate(format: "title == %@", originalCategoryName)
                    
                    let originalCategoryResults = try context.fetch(originalCategoryFetchRequest)
                    
                    if let originalCategory = originalCategoryResults.first {
                        // Удаляем из "Закрепленные"
                        if let pinnedCategory = trackerToUpdate.categoryLink {
                            pinnedCategory.removeFromTrackers(trackerToUpdate)
                        }
                        
                        // Добавляем обратно в исходную категорию
                        originalCategory.addToTrackers(trackerToUpdate)
                        trackerToUpdate.categoryLink = originalCategory
                        
                        // Очищаем свойство с исходной категорией
                        trackerToUpdate.originalCategory = nil
                    }
                }
            }
            
            // Сохраняем изменения
            try context.save()
            
            // Обновляем локальные данные
            loadAllCategories()
            filterVisibleCategories()
            
            // Уведомляем делегат об изменениях
            delegate?.didUpdate()
            
            return true
        } catch {
            print("Ошибка при \(isPinned ? "закреплении" : "откреплении") трекера: \(error)")
            context.rollback()
            return false
        }
    }
    
    
    // MARK: -  Deletion
    
    func deleteTracker(at indexPath: IndexPath) -> Bool {
        guard indexPath.section < visibleCategories.count,
              indexPath.row < visibleCategories[indexPath.section].trackers.count else {
            return false
        }
        
        // Получаем трекер, который нужно удалить
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        print(indexPath, "founded tracker - ", tracker.id)
        
        // Создаем запрос для поиска трекера в Core Data
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            // Выполняем запрос
            let results = try context.fetch(fetchRequest)
            
            // Если трекер найден, удаляем его
            if let trackerToDelete = results.first {
                
                // Проверяем, есть ли связанные записи завершения (TrackerRecord)
                let recordFetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
                recordFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
                
                let records = try context.fetch(recordFetchRequest)
                
                // Удаляем все связанные записи завершения
                for record in records {
                    context.delete(record)
                }
                
                // Удаляем сам трекер
                context.delete(trackerToDelete)
                
                // Сохраняем изменения
                try context.save()
                
                // Перезагружаем данные после удаления
//                loadAllCategories()
//                filterVisibleCategories()
                delegate?.didUpdate()
                
                return true
            } else {
                print("Трекер не найден для удаления")
                return false
            }
        } catch {
            print("Ошибка при удалении трекера: \(error)")
            context.rollback()
            return false
        }
    }
    
    var numberOfSections: Int {
        
        loadAllCategories()
        filterVisibleCategories()
        
        
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
    
    func getCategory(at indexPath: IndexPath) -> String {
        return visibleCategories[indexPath.section].title
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
        
        // Уведомляем делегат о изменениях
        delegate?.didUpdate()
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
