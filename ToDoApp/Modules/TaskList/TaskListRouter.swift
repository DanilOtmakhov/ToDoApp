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
        let store = TaskStore()
        let provider = TaskDataProvider(store: store)
        let interactor = TaskEditorInteractor(provider: provider)
        let presenter = TaskEditorPresenter(interactor: interactor, task: task)
        let viewController = TaskEditorViewController(presenter: presenter)

        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
