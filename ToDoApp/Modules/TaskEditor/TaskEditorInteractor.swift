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
    
    weak var output: TaskEditorInteractorOutput?
    
    private let provider: TaskEditorDataProviderProtocol
    
    init(provider: TaskEditorDataProviderProtocol) {
        self.provider = provider
    }
    
    func addTask(title: String?, description: String?) {
        guard let title,
              !title.isEmpty
        else {
            let error = NSError(
                domain: "TaskEditor",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Название задачи не может быть пустым"]
            )
            output?.didFailToSaveTask(with: error)
            return
        }
        
        let task = Task(
            id: UUID(),
            title: title,
            description: description,
            createdAt: Date(),
            isCompleted: false
        )
        
        do {
            try provider.add(task)
        } catch {
            output?.didFailToSaveTask(with: error)
        }
    }
    
    func edit(_ task: Task, newTitle: String?, newDescription: String?) {
        guard
            let newTitle,
            !newTitle.isEmpty
        else {
            let error = NSError(
                domain: "TaskEditor",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Название задачи не может быть пустым"]
            )
            output?.didFailToSaveTask(with: error)
            output?.didSaveTaskSuccessfully()
            return
        }
        
        let newTask = Task(
            id: task.id,
            title: newTitle,
            description: newDescription,
            createdAt: Date(),
            isCompleted: task.isCompleted
        )
        
        do {
            try provider.edit(task, with: newTask)
            output?.didSaveTaskSuccessfully()
        } catch {
            output?.didFailToSaveTask(with: error)
        }
    }
    
}
