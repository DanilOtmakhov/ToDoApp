//
//  TaskEditorPresenter.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import Foundation

protocol TaskEditorPresenterProtocol: AnyObject {
    var view: TaskEditorViewProtocol? { get set }
    func viewDidLoad()
    func didTapDone(title: String?, description: String?)
}

final class TaskEditorPresenter: TaskEditorPresenterProtocol {
    
    weak var view: TaskEditorViewProtocol?
    var router: TaskEditorRouterProtocol?
    
    private var interactor: TaskEditorInteractorInput
    private var task: Task?
    
    init(interactor: TaskEditorInteractorInput, task: Task? = nil) {
        self.interactor = interactor
        self.task = task
        
        self.interactor.output = self
    }
    
    func viewDidLoad() {
        view?.reloadData(TaskEditorViewModel(task))
        
        if task == nil {
            view?.focusTitleField()
        }
    }
    
    func didTapDone(title: String?, description: String?) {
        if let existingTask = task {
            interactor.edit(existingTask, newTitle: title, newDescription: description)
        } else {
            interactor.addTask(title: title, description: description)
        }
        
        router?.dismissEditor()
    }
    
}

// MARK: - TaskEditorInteractorOutput

extension TaskEditorPresenter: TaskEditorInteractorOutput {
    
    func didSaveTaskSuccessfully() {
        
    }
    
    func didFailToSaveTask(with error: any Error) {
        // TODO: show error
    }
    
}


