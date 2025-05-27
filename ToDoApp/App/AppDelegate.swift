//
//  AppDelegate.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureNavigationBarAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let coordinator = AppCoordinator(window: window!)
        coordinator.start()
        
        return true
    }
    
    private func configureNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .background
        appearance.shadowColor = nil
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.textPrimary
        ]
        
        navigationBarAppearance.standardAppearance = appearance
        navigationBarAppearance.scrollEdgeAppearance = appearance
        navigationBarAppearance.compactAppearance = appearance
    }

}

