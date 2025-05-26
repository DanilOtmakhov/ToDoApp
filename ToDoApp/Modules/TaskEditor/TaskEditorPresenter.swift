//
//  TaskEditorPresenter.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import Foundation

protocol TaskEditorPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapDone(title: String?, description: String?)
}

final class TaskEditorPresenter: TaskEditorPresenterProtocol {
    
    weak var view: TaskEditorViewProtocol?
    
    private var task: Task?
    
    init(task: Task? = nil) {
        self.task = task
    }
    
    func viewDidLoad() {
        view?.reloadData(TaskEditorViewModel(task))
        
        if task == nil {
            view?.focusTitleField()
        }
    }
    
    func didTapDone(title: String?, description: String?) {
        print(title)
        print(description)
    }
    
}
