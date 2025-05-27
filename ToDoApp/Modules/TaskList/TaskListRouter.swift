//
//  TaskListRouter.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import UIKit

protocol TaskListRouterProtocol {
    func showTaskEditor(task: Task?)
}

final class TaskListRouter: TaskListRouterProtocol {

    private weak var viewController: UIViewController?
    private let moduleFactory: ModuleFactoryProtocol

    init(viewController: UIViewController, moduleFactory: ModuleFactoryProtocol) {
        self.viewController = viewController
        self.moduleFactory = moduleFactory
    }
    
    func showTaskEditor(task: Task?) {
        let taskEditorViewController = moduleFactory.makeTaskEditorModule(task: task)
        viewController?.navigationController?.pushViewController(taskEditorViewController, animated: true)
    }
    
}
