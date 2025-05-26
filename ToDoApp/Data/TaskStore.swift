//
//  TaskStore.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import CoreData

protocol TaskStoreProtocol {
    func save(_ tasks: [Task]) throws
}

final class TaskStore: TaskStoreProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func save(_ tasks: [Task]) throws {
        for task in tasks {
            let entity = TaskEntity(context: context)
            entity.id = task.id
            entity.title = task.title
            entity.descriptionText = task.description
            entity.createdAt = task.createdAt
            entity.isCompleted = task.isCompleted
        }

        if context.hasChanges {
            try context.save()
        }
    }
    
}
