
import Foundation

// Модель для хранения категорий трекеров (полностью иммутабельная)
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}
