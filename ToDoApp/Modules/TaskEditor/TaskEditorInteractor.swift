//
//  TaskEditorInteractor.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 27.05.2025.
//

import Foundation

protocol TaskEditorInteractorInput {
    var output: TaskEditorInteractorOutput? { get set }
    func addTask(title: String?, description: String?)
    func edit(_ task: Task, newTitle: String?, newDescription: String?)
}

protocol TaskEditorInteractorOutput: AnyObject {
    func didSaveTaskSuccessfully()
    func didFailToSaveTask(with error: Error)
}

final class TaskEditorInteractor: TaskEditorInteractorInput {
    
    // MARK: - Internal Properties
    
    weak var output: TaskEditorInteractorOutput?
    
    // MARK: - Private Properties
    
    private let provider: TaskEditorDataProviderProtocol
    
    // MARK: - Initialization
    
    init(provider: TaskEditorDataProviderProtocol) {
        self.provider = provider
    }
    
}

// MARK: - Internal Methods

extension TaskEditorInteractor {
    
    func addTask(title: String?, description: String?) {
        guard let title,
              !title.isEmpty
        else {
            self.sendError(message: "Название задачи не может быть пустым")
            return
        }
        
        let task = Task(
            id: UUID(),
            title: title,
            description: description,
            createdAt: Date(),
            isCompleted: false
        )
        
        
        provider.add(task) { [weak self] result in
            self?.handleResult(result)
        }
    }
    
    func edit(_ task: Task, newTitle: String?, newDescription: String?) {
        guard
            let newTitle,
            !newTitle.isEmpty
        else {
            self.sendError(message: "Название задачи не может быть пустым")
            return
        }
        
        let newTask = Task(
            id: task.id,
            title: newTitle,
            description: newDescription,
            createdAt: Date(),
            isCompleted: task.isCompleted
        )
        
        provider.edit(task, with: newTask) { [weak self] result in
            self?.handleResult(result)
        }
    }
    
}

// MARK: - Private Methods

private extension TaskEditorInteractor {
    
    private func handleResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            self.output?.didSaveTaskSuccessfully()
        case .failure(let error):
            self.output?.didFailToSaveTask(with: error)
        }
    }
    
    private func sendError(message: String) {
        let error = NSError(
            domain: "TaskEditor",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
            
        self.output?.didFailToSaveTask(with: error)
    }
    
}
