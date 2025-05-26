//
//  TaskListPresenter.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import Foundation

protocol TaskListPresenterProtocol: AnyObject {
    var numberOfTasks: Int { get }
    func task(at index: Int) -> TaskCellViewModel?
    func viewDidLoad()
    func didTapAddTask()
    func didTapEditTask(at index: Int)
}

final class TaskListPresenter: TaskListPresenterProtocol {
    
    weak var view: TaskListViewProtocol?
    private let interactor: TaskListInteractorProtocol
    var router: TaskListRouterProtocol?
    
    init(interactor: TaskListInteractorProtocol) {
        self.interactor = interactor
    }
    
    var numberOfTasks: Int { interactor.numberOfTasks }
    
    func task(at index: Int) -> TaskCellViewModel? {
        guard let task = interactor.task(at: index) else { return nil }
        return TaskCellViewModel(task)
    }
    
    func viewDidLoad() {
        interactor.loadTasks()
    }
    
    func didTapAddTask() {
        router?.showTaskEditor(task: nil)
    }

    func didTapEditTask(at index: Int) {
        guard let task = interactor.task(at: index) else { return }
        router?.showTaskEditor(task: task)
    }
    
}

// MARK: - TaskListInteractorOutput

extension TaskListPresenter: TaskListInteractorOutput {
    
    func didReceiveUpdate(_ update: TaskStoreUpdate) {
        view?.applyUpdate(update)
    }
    
    func didFailToLoadTasks(_ error: any Error) {
        // TODO: show error
    }
    
}
