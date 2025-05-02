import UIKit
import CoreData

struct TrackerCategoryUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(update: TrackerCategoryUpdate)
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> TrackerCategory?
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - NSFetchedResultsController
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    internal var insertedIndexes2 = IndexSet()
    private var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении fetchRequest: \(error)")
        }
        return fetchedResultsController
    }()
    
    convenience init(delegate: TrackerCategoryStoreDelegate) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("App delegate not found or not of type AppDelegate")
         }
         
         let context = appDelegate.persistentContainer.viewContext
         self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackerCategoryStoreDelegate?) {
        self.context = context
        self.delegate = delegate
    }
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let categoryCD = fetchedResultsController.object(at: indexPath)
        guard let title = categoryCD.title else { return nil }
        
        // Преобразуем TrackerCategoryCoreData в TrackerCategory
        return TrackerCategory(title: title, trackers: [])
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    private func resetIndexSets() {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        resetIndexSets()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       guard let inserted = insertedIndexes, let deleted = deletedIndexes else {
           assertionFailure("❌ insertedIndexes или deletedIndexes не инициализированы")
           return
       }
       
       delegate?.didUpdate(update: TrackerCategoryUpdate(
           insertedIndexes: inserted,
           deletedIndexes: deleted
       ))

       insertedIndexes = nil
       deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

extension TrackerCategoryStore: CategoriesViewControllerDelegate {
    func addCategory(with category: TrackerCategory) {
        print("Добавление категории: \(category)")
        
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        
        do {
            try context.save()
            print("Категория успешно сохранена")
        } catch {
            print("Ошибка при сохранении категории: \(error)")
            context.rollback()
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            return categoriesCoreData.compactMap { categoryCD in
                guard let title = categoryCD.title else { return nil }
                return TrackerCategory(title: title, trackers: []) // Предполагаем, что трекеры нужно загружать отдельно
            }
        } catch {
            print("Ошибка при получении категорий: \(error)")
            return []
        }
    }
    
    
}
