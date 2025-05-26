//
//  TaskListInteractor.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 25.05.2025.
//

import Foundation

protocol TaskListInteractorProtocol {
    var numberOfTasks: Int { get }
    func task(at index: Int) -> Task?
    func loadTasks()
}

protocol TaskListInteractorOutput: AnyObject {
    func didReceiveUpdate(_ update: TaskStoreUpdate)
    func didFailToLoadTasks(_ error: Error)
}

final class TaskListInteractor: TaskListInteractorProtocol {
    
    private enum UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }
    
    weak var output: TaskListInteractorOutput?
    
    private let networkService: TaskNetworkServiceProtocol
    private var provider: TaskProviderProtocol
    private let userDefaults: UserDefaults

    init(taskService: TaskNetworkServiceProtocol,
        taskProvider: TaskProviderProtocol,
        userDefaults: UserDefaults = .standard) {
        self.networkService = taskService
        self.provider = taskProvider
        self.userDefaults = userDefaults
        
        self.provider.delegate = self
    }
    
    var numberOfTasks: Int { provider.numberOfRows }
    
    func task(at index: Int) -> Task? {
        provider.task(at: IndexPath(row: index, section: 0))
    }

    func loadTasks() {
        if userDefaults.bool(forKey: UserDefaultsKeys.hasLaunchedBefore) {
            provider.fetchTasks()
        } else {
            networkService.fetchTasks { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(let remoteTasks):
                        let tasks = remoteTasks.map(Task.init)
                        do {
                            try self.provider.save(tasks)
                            self.userDefaults.set(true, forKey: UserDefaultsKeys.hasLaunchedBefore)
                        } catch {
                            self.output?.didFailToLoadTasks(error)
                        }
                        
                    case .failure(let error):
                        self.output?.didFailToLoadTasks(error)
                    }
                }
            }
        }
    }
    
}

// MARK: - TaskProviderDelegate

extension TaskListInteractor: TaskProviderDelegate {
    
    func didUpdate(_ update: TaskStoreUpdate) {
        output?.didReceiveUpdate(update)
    }
    
    func didFail(with error: any Error) {
        output?.didFailToLoadTasks(error)
    }
    
}
