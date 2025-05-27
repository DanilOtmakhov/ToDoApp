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
    func loadTasks()
    func didTapCompleteButton(at index: Int)
    func didTapAddTask()
    func didTapEditTask(at index: Int)
    func didTapDeleteTask(at index: Int)
    func didTapShareTask(at index: Int)
    func didChangeSearchQuery(_ query: String)
}

final class TaskListPresenter: TaskListPresenterProtocol {
    
    weak var view: TaskListViewProtocol?
    var router: TaskListRouterProtocol?
    
    private let interactor: TaskListInteractorProtocol
    
    init(interactor: TaskListInteractorProtocol) {
        self.interactor = interactor
    }
    
    var numberOfTasks: Int { interactor.numberOfTasks }
    
    func task(at index: Int) -> TaskCellViewModel? {
        guard let task = interactor.task(at: index) else { return nil }
        return TaskCellViewModel(task)
    }
    
    func loadTasks() {
        interactor.loadTasks(with: "")
    }
    
    func didTapCompleteButton(at index: Int) {
        interactor.toggleCompletionForTask(at: index)
    }
    
    func didTapAddTask() {
        router?.showTaskEditor(task: nil)
    }

    func didTapEditTask(at index: Int) {
        guard let task = interactor.task(at: index) else { return }
        router?.showTaskEditor(task: task)
    }
    
    func didTapDeleteTask(at index: Int) {
        interactor.deleteTask(at: index)
    }
    
    func didTapShareTask(at index: Int) {
        
    }
    
    func didChangeSearchQuery(_ query: String) {
        interactor.loadTasks(with: query)
    }
    
}

// MARK: - TaskListInteractorOutput

extension TaskListPresenter: TaskListInteractorOutput {
    
    func didReceiveUpdate(_ update: TaskStoreUpdate) {
        view?.applyUpdate(update)
    }
    
    func didFail(_ error: any Error) {
        // TODO: show error
    }
    
}
