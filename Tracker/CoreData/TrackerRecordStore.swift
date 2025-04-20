import UIKit
import CoreData

class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    private let convertedSchedule: String = ""
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerRecordStore: HabitCreationViewControllerDelegate {
    func didCreateTracker(tracker: Tracker, category: String) {
        print("============================", tracker, category)
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
}
