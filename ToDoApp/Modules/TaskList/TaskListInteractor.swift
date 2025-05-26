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
    func toggleCompletionForTask(at index: Int)
    func deleteTask(at index: Int)
}

protocol TaskListInteractorOutput: AnyObject {
    func didReceiveUpdate(_ update: TaskStoreUpdate)
    func didFail(_ error: Error)
}

final class TaskListInteractor: TaskListInteractorProtocol {
    
    // MARK: - Enums
    
    private enum UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }
    
    // MARK: - Internal Properties
    
    weak var output: TaskListInteractorOutput?
    
    // MARK: - Private Properties
    
    private let networkService: TaskNetworkServiceProtocol
    private var provider: TaskListDataProviderProtocol
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization

    init(networkService: TaskNetworkServiceProtocol,
        provider: TaskListDataProviderProtocol,
        userDefaults: UserDefaults = .standard) {
        self.networkService = networkService
        self.provider = provider
        self.userDefaults = userDefaults
        
        self.provider.delegate = self
    }
    
}

// MARK: - Internal Methods

extension TaskListInteractor {
    
    var numberOfTasks: Int { provider.numberOfRows }
    
    func task(at index: Int) -> Task? {
        provider.task(at: IndexPath(row: index, section: 0))
    }

    func loadTasks() {
        if userDefaults.bool(forKey: UserDefaultsKeys.hasLaunchedBefore) {
            provider.fetchTasks()
        } else {
            loadInitialTasks()
        }
    }
    
    func toggleCompletionForTask(at index: Int) {
        guard let task = task(at: index) else { return }
        
        provider.toggleCompletion(for: task) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.output?.didFail(error)
            }
        }
    }
    
    func deleteTask(at index: Int) {
        guard let task = task(at: index) else { return }
        
        provider.delete(task) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.output?.didFail(error)
            }
        }
    }
    
}

// MARK: - Private Properties

private extension TaskListInteractor {
    
    func loadInitialTasks() {
        networkService.fetchTasks { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let remoteTasks):
                    let tasks = remoteTasks.reversed().map(Task.init)
                    self.provider.save(tasks) { result in
                        switch result {
                        case .success:
                            self.userDefaults.set(true, forKey: UserDefaultsKeys.hasLaunchedBefore)
                        case .failure(let error):
                            self.output?.didFail(error)
                        }
                    }
                    
                case .failure(let error):
                    self.output?.didFail(error)
                }
            }
        }
    }
    
}

// MARK: - TaskProviderDelegate

extension TaskListInteractor: TaskListDataProviderDelegate {
    
    func didUpdate(_ update: TaskStoreUpdate) {
        output?.didReceiveUpdate(update)
    }
    
    func didFail(with error: any Error) {
        output?.didFail(error)
    }
    
}
