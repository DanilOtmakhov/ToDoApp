//
//  TaskEditorRouter.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 27.05.2025.
//

import UIKit

protocol TaskEditorRouterProtocol {
    func dismissEditor()
}

final class TaskEditorRouter: TaskEditorRouterProtocol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func dismissEditor() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: true)
        }
    }
}
