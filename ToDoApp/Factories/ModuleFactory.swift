//
//  ModuleFactory.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 27.05.2025.
//

import UIKit

protocol ModuleFactoryProtocol {
    func makeTaskListModule() -> UIViewController
    func makeTaskEditorModule(task: Task?) -> UIViewController
}

final class ModuleFactory: ModuleFactoryProtocol {
    
    func makeTaskListModule() -> UIViewController {
        let networkService = TaskNetworkService()
        let store = TaskStore()
        let provider = TaskDataProvider(store: store)
        let interactor = TaskListInteractor(networkService: networkService, provider: provider)
        let presenter = TaskListPresenter(interactor: interactor)
        let viewController = TaskListViewController(presenter: presenter)
        let router = TaskListRouter(viewController: viewController, moduleFactory: self)
        
        interactor.output = presenter
        presenter.view = viewController
        presenter.router = router
        
        return viewController
    }
    
    func makeTaskEditorModule(task: Task?) -> UIViewController {
        let store = TaskStore()
        let provider = TaskDataProvider(store: store)
        let interactor = TaskEditorInteractor(provider: provider)
        let presenter = TaskEditorPresenter(interactor: interactor, task: task)
        let viewController = TaskEditorViewController(presenter: presenter)
        let router = TaskEditorRouter(viewController: viewController)
        
        presenter.router = router
        
        return viewController
    }
    
}
