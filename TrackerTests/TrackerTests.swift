
import XCTest
import SnapshotTesting
@testable import Tracker

final class MainTabBarControllerSnapshotTests: XCTestCase {
    
    private var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func test_mainTabBarController_defaultState_light() {
        window.overrideUserInterfaceStyle = .light
        
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        assertSnapshot(
            of: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "light_default",
            record: false
        )
    }
    
    func test_mainTabBarController_defaultState_dark() {
        window.overrideUserInterfaceStyle = .dark
        
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.5))
        
        assertSnapshot(
            of: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "dark_default",
            record: false
        )
    }
}
