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
 
    var categoryStore: TrackerCategoryStore?
    
    // Массив для хранения видимых категорий (исключая "Закрепленные")
    private var visibleCategories: [TrackerCategory] = []
    
    // Константа для имени закрепленной категории
    private let pinnedCategoryName = "Закрепленные"
    
    init() {
        let trackerCategoryStore = TrackerCategoryStore(delegate: self)
        self.categoryStore = trackerCategoryStore
        updateVisibleCategories()
    }
    
    // Метод для обновления массива видимых категорий
    private func updateVisibleCategories() {
        let allCategories = categoryStore?.fetchCategories() ?? []
        visibleCategories = allCategories.filter { $0.title != pinnedCategoryName }
        
        // Оповещаем о изменении количества строк
        rowsBinding?(onRowsCountUpdate)
    }
    
    // Вычисляемое свойство для количества строк (теперь основано на visibleCategories)
    var onRowsCountUpdate: Int {
        return visibleCategories.count
    }
    
    // Замыкание для оповещения об изменениях количества строк
    var rowsBinding: Binding<Int>? {
        didSet {
            // При установке замыкания сразу отправляем текущее значение
            rowsBinding?(onRowsCountUpdate)
        }
    }
    
    // Метод для получения объекта по индексу (теперь из visibleCategories)
    func getObject(indexPath: IndexPath) -> TrackerCategory? {
        guard indexPath.row < visibleCategories.count else { return nil }
        return visibleCategories[indexPath.row]
    }
    
    var onCategoryUpdate: Binding<TrackerCategoryUpdate>?
    
    func hasCategories() -> Bool {
        return onRowsCountUpdate > 0
    }
    
    func isSameName(with name: String) -> Bool {
        // Проверяем, есть ли категория с таким именем среди всех категорий
        let existingCategories = categoryStore?.fetchCategories() ?? []
        return existingCategories.contains { $0.title == name }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(update: TrackerCategoryUpdate) {
        print("Обновления получены!")
        
        // Обновляем массив видимых категорий
        updateVisibleCategories()
        
        // Создаем новое обновление, которое исключает закрепленные категории
        // Это может потребовать дополнительной логики в зависимости от структуры TrackerCategoryUpdate
        // Например, может потребоваться фильтрация insertedIndexes
        
        // Отправляем информацию о конкретных индексах для batch updates
        onCategoryUpdate?(update)
    }
}

extension CategoriesViewModel {
    func didCreateCategory(_ categoryName: String) {
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        categoryStore?.addCategory(with: newCategory)
        
        // После добавления новой категории обновляем visibleCategories
        updateVisibleCategories()
    }
}
