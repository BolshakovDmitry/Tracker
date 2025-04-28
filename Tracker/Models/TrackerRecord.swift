
import Foundation

// Модель для хранения завершенных трекеров (полностью иммутабельная)
struct TrackerRecord: Hashable {
    let id: UUID  // ID трекера
    let date: Date // Дата выполнения
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
