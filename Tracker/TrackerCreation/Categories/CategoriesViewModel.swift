import UIKit
typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelProtocol {
    var rowsBinding: Binding<Int>? { get set }
    
    var onCategoryUpdate: Binding<TrackerCategoryUpdate>? { get set }
    func getObject(indexPath: IndexPath) -> TrackerCategory?
    func hasCategories() -> Bool
    func isSameName(with name: String) -> Bool
    func didCreateCategory(_ categoryName: String)
    var onRowsCountUpdate: Int { get }
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
 
    var model: TrackerCategoryStore?
    
    // Вычисляемое свойство, которое всегда возвращает актуальное значение
    var onRowsCountUpdate: Int {
        return model?.numberOfRowsInSection(0) ?? 0
        
    }
    
    // Замыкание для оповещения об изменениях количества строк
    var rowsBinding: Binding<Int>? {
        didSet {
            // При установке замыкания сразу отправляем текущее значение
            rowsBinding?(onRowsCountUpdate)
        }
    }
    
    func getObject(indexPath: IndexPath) -> TrackerCategory? {
        model?.object(at: indexPath)
    }
    
    var onCategoryUpdate: Binding<TrackerCategoryUpdate>?
    
    func hasCategories() -> Bool {
        return onRowsCountUpdate > 0
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
        
        // Сначала обновляем количество строк через замыкание
                rowsBinding?(onRowsCountUpdate)
        
                // Затем отправляем информацию о конкретных индексах для batch updates
                onCategoryUpdate?(update)
    }
}

extension CategoriesViewModel {
    func didCreateCategory(_ categoryName: String) {
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        model?.addCategory(with: newCategory)
    }
}
