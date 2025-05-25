//
//  TaskListInteractor.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 25.05.2025.
//

import Foundation

protocol TaskListInteractorProtocol {
    func loadTasks()
}

protocol TaskListInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [Task])
    func didFailToLoadTasks(_ error: Error)
}

final class TaskListInteractor: TaskListInteractorProtocol {
    
    weak var output: TaskListInteractorOutput?
    private let taskService: TaskServiceProtocol

    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
    }

    func loadTasks() {
        taskService.fetchTasks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let remoteTasks):
                    let tasks = remoteTasks.map(Task.init)
                    self?.output?.didLoadTasks(tasks)
                case .failure(let error):
                    self?.output?.didFailToLoadTasks(error)
                }
            }
        }
    }
    
}
