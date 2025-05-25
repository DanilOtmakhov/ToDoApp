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
    
    let tasks = Task.mockData
    
    var numberOfTasks: Int { tasks.count }
    
    func task(at index: Int) -> TaskCellViewModel {
        let task = tasks[index]
        return TaskCellViewModel(task)
    }
    
    func viewDidLoad() {
        view?.reloadData()
    }
    
}
