import UIKit

typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelProtocol {
    var numberOfRowsInSection: Binding<Int>? { get }
    func getObject(indexPath: IndexPath) -> TrackerCategory?
    var onCategoryUpdate: Binding<TrackerCategoryUpdate>? { get set }
    func hasCategories() -> Bool
    func isSameName(with name: String) -> Bool
    func didCreateCategory(_ categoryName: String)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {

    var model: TrackerCategoryStore?
    
    // Замыкание для наблюдения за изменениями количества строк
    var numberOfRowsInSection: Binding<Int>? {
        didSet {
            // При установке замыкания сразу отправляем текущее значение
            numberOfRowsInSection?(model?.numberOfRowsInSection(0) ?? 0)
        }
    }
    func getObject(indexPath: IndexPath) -> TrackerCategory? {
        model?.object(at: indexPath)
    }
    
    var onCategoryUpdate: Binding<TrackerCategoryUpdate>?
    
    func hasCategories() -> Bool {
        let count = model?.numberOfRowsInSection(0) ?? 0
        return count > 0
    }
    
    func isSameName(with name: String) -> Bool {
        
        // Получаем существующие категории из CoreData
        let existingCategories = model?.fetchCategories() ?? []
        
        return existingCategories.contains { $0.title == name }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(update: TrackerCategoryUpdate) {
        print("Обновления получены!")
        
        // Передаем обновление в контроллер через замыкание
                onCategoryUpdate?(update)
    }
}

extension CategoriesViewModel {
    func didCreateCategory(_ categoryName: String) {
        let newCategory = TrackerCategory(title: categoryName, trackers: [])

        model?.addCategory(with: newCategory)
    }
}
