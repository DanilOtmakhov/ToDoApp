//
//  TaskListPresenter.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import Foundation

protocol TaskListPresenterProtocol: AnyObject {
    var numberOfTasks: Int { get }
    func task(at index: Int) -> TaskCellViewModel
    func viewDidLoad()
}

final class TaskListPresenter: TaskListPresenterProtocol {
    
    weak var view: TaskListViewProtocol?
    private let interactor: TaskListInteractorProtocol
    private var tasks: [Task] = []
    
    init(interactor: TaskListInteractorProtocol) {
        self.interactor = interactor
    }
    
    var numberOfTasks: Int { tasks.count }
    
    func task(at index: Int) -> TaskCellViewModel {
        let task = tasks[index]
        return TaskCellViewModel(task)
    }
    
    func viewDidLoad() {
        interactor.loadTasks()
    }
    
}

// MARK: -

extension TaskListPresenter: TaskListInteractorOutput {
    
    func didLoadTasks(_ tasks: [Task]) {
        self.tasks = tasks
        view?.reloadData()
    }
    
    func didFailToLoadTasks(_ error: any Error) {
        // TODO: show error
    }
    
}
