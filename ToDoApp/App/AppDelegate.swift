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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureNavigationBarAppearance()
        
        let networkService = TaskNetworkService()
        let store = TaskStore()
        let provider = TaskProvider(store: store)
        let interactor = TaskListInteractor(taskService: networkService, taskProvider: provider)
        let presenter = TaskListPresenter(interactor: interactor)
        let viewController = TaskListViewController(presenter: presenter)
        
        interactor.output = presenter
        presenter.view = viewController
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
        
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

