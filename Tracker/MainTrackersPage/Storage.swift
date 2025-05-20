import Foundation

public protocol StorageProtocol: AnyObject {
    var chosenFilter: String? { get set }
    func clear()
}

final class Storage: StorageProtocol {
    
    static let shared = Storage()
    private init(){}
    
    enum Keys: String {
        case chosenFilter = "chosenFilter"
    }
    
    var chosenFilter: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.chosenFilter.rawValue)
        }
        set {
            guard let newValue = newValue else {
                clear()
                return
            }
            // UserDefaults.set не возвращает Bool, просто сохраняем значение
            UserDefaults.standard.set(newValue, forKey: Keys.chosenFilter.rawValue)
            // Для надежности можно добавить синхронизацию
            UserDefaults.standard.synchronize()
        }
    }
    
    func store(with chosenFilter: String?) {
        self.chosenFilter = chosenFilter
    }
    
    func clear() {
        // Если мы используем UserDefaults, то и удалять нужно из UserDefaults
        UserDefaults.standard.removeObject(forKey: Keys.chosenFilter.rawValue)
        // Для надежности можно добавить синхронизацию
        UserDefaults.standard.synchronize()
    }
}
