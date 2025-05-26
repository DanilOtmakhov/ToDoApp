//
//  TaskStore.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import CoreData

protocol TaskStoreProtocol {
    func save(_ tasks: [Task]) throws
    func add(_ task: Task) throws
    func edit(_ task: Task, with newTask: Task) throws
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
    
    func add(_ task: Task) throws {
        let entity = TaskEntity(context: context)
        entity.id = task.id
        entity.title = task.title
        entity.descriptionText = task.description
        entity.createdAt = task.createdAt
        entity.isCompleted = task.isCompleted
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    func edit(_ task: Task, with newTask: Task) throws {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let entityToUpdate = results.first else {
                throw NSError(
                    domain: "TaskStore",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Task not found"]
                )
            }
            
            entityToUpdate.title = newTask.title
            entityToUpdate.descriptionText = newTask.description
            entityToUpdate.createdAt = newTask.createdAt
            entityToUpdate.isCompleted = newTask.isCompleted
            
            if context.hasChanges {
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
}
