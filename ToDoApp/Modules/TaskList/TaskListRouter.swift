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

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showTaskEditor(task: Task?) {
        let presenter = TaskEditorPresenter(task: task)
        let viewController = TaskEditorViewController(presenter: presenter)
        presenter.view = viewController

        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
