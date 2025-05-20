import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: "open", screen: "Main")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.shared.report(event: "close", screen: "Main")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackGroundColor")
        
        // Настраиваем внешний вид TabBar
        setupTabBar()
        
        // Создаем и настраиваем контроллеры для вкладок
        setupViewControllers()
    }
    
    private func setupTabBar() {
        // Настраиваем внешний вид TabBar
        tabBar.tintColor = UIColor(named: "YP Blue")
        tabBar.backgroundColor = UIColor(named: "BackGroundColor")
        tabBar.layer.borderWidth = 0.5
        
        // Устанавливаем цвет границы в зависимости от текущей темы
        updateTabBarBorderColor()
    }
    
    // Метод для обновления цвета границы TabBar в зависимости от темы
    private func updateTabBarBorderColor() {
        if traitCollection.userInterfaceStyle == .dark {
            // Черная полоска для темной темы
            tabBar.layer.borderColor = UIColor.black.cgColor
        } else {
            // Светло-серая полоска для светлой темы
            tabBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        }
    }
    
    // Этот метод вызывается при изменении свойств окружения,
    // включая переключение между светлой и темной темами
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Проверяем, изменилась ли тема
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            // Обновляем цвет границы
            updateTabBarBorderColor()
        }
    }
    
    private func setupViewControllers() {
        // Создаем контроллер для вкладки "Трекеры"
        let trackersVC = TrackersViewController()
        let trackerStore = TrackerStore(delegate: trackersVC)
        let trackerRecordStore = TrackerRecordStore(delegate: trackersVC)
        trackersVC.delegateCoreData = trackerStore
        trackersVC.delegateCellCoreData = trackerRecordStore
        
        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        trackersNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers.header", comment: ""),
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        // Создаем контроллер для вкладки "Статистика"
        let statisticsVC = StatisticsViewController()
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)
        statisticsNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistic.button.title", comment: ""),
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        
        // Устанавливаем созданные контроллеры в качестве вкладок
        viewControllers = [trackersNavController, statisticsNavController]
    }
}
