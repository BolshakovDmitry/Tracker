import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем внешний вид TabBar
        setupTabBar()
        
        // Создаем и настраиваем контроллеры для вкладок
        setupViewControllers()
    }
    
    private func setupTabBar() {
        // Настраиваем внешний вид TabBar
        tabBar.tintColor = UIColor(named: "YP Blue") // Используем цвет из ассетов или указываем другой
        tabBar.backgroundColor = .white
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
    }
    
    private func setupViewControllers() {
        // Создаем контроллер для вкладки "Трекеры"
        let trackersVC = TrackersViewController()
        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        trackersNavController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        // Создаем контроллер для вкладки "Статистика"
        let statisticsVC = StatisticsViewController()
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)
        statisticsNavController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        
        // Устанавливаем созданные контроллеры в качестве вкладок
        viewControllers = [trackersNavController, statisticsNavController]
    }
}
