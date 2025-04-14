//
//  AppDelegate.swift
//  Tracker
//
//  Created by Home on 27.03.2025.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Создаем UIWindow вручную
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Устанавливаем корневой контроллер
        window?.rootViewController = MainTabBarController()
        
        // Делаем окно видимым и ключевым (активным)
        window?.makeKeyAndVisible()
        
        return true
    }
}

