//
//  AppCoordinator.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 27.05.2025.
//

import UIKit

final class AppCoordinator {
    
    private let window: UIWindow
    private let moduleFactory: ModuleFactory
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.moduleFactory = ModuleFactory()
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let taskListViewController = moduleFactory.makeTaskListModule()
        navigationController.setViewControllers([taskListViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}
