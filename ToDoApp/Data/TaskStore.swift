//
//  TaskStore.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import CoreData

enum TaskError: Error {
    case taskNotFound
    case operationFailed(Error)
}

protocol TaskStoreProtocol {
    func save(_ tasks: [Task], completion: @escaping (Result<Void, TaskError>) -> Void)
    func add(_ task: Task, completion: @escaping (Result<Void, TaskError>) -> Void)
    func edit(_ task: Task, with newTask: Task, completion: @escaping (Result<Void, TaskError>) -> Void)
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleCompletion(for task: Task, completion: @escaping (Result<Void, TaskError>) -> Void)
}

final class TaskStore: TaskStoreProtocol {
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let operationQueue: DispatchQueue
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.backgroundContext,
         queue: DispatchQueue = DispatchQueue(label: "com.ToDoApp.TaskStore.queue", qos: .userInitiated)) {
        self.context = context
        self.operationQueue = queue
    }

}

// MARK: - Public Methods

extension TaskStore {
    
    func save(_ tasks: [Task], completion: @escaping (Result<Void, TaskError>) -> Void) {
        executeOperation { [weak self] in
            guard let self = self else { return }
            
            do {
                for task in tasks {
                    let entity = TaskEntity(context: self.context)
                    entity.id = task.id
                    entity.title = task.title
                    entity.descriptionText = task.description
                    entity.createdAt = task.createdAt
                    entity.isCompleted = task.isCompleted
                }
                
                if self.context.hasChanges {
                    try self.context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(.operationFailed(error)))
            }
        }
    }
    
    func add(_ task: Task, completion: @escaping (Result<Void, TaskError>) -> Void) {
        executeOperation { [weak self] in
            guard let self = self else { return }
            
            do {
                let entity = TaskEntity(context: self.context)
                entity.id = task.id
                entity.title = task.title
                entity.descriptionText = task.description
                entity.createdAt = task.createdAt
                entity.isCompleted = task.isCompleted
                
                if self.context.hasChanges {
                    try self.context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(.operationFailed(error)))
            }
        }
    }
    
    func edit(_ task: Task, with newTask: Task, completion: @escaping (Result<Void, TaskError>) -> Void) {
        executeOperation { [weak self] in
            guard let self = self else { return }
            
            do {
                guard let entity = try self.findEntity(by: task.id) else {
                    throw TaskError.taskNotFound
                }
                
                entity.title = newTask.title
                entity.descriptionText = newTask.description
                entity.createdAt = newTask.createdAt
                entity.isCompleted = newTask.isCompleted
                
                if self.context.hasChanges {
                    try self.context.save()
                }
                completion(.success(()))
            } catch let error as TaskError {
                completion(.failure(error))
            } catch {
                completion(.failure(.operationFailed(error)))
            }
        }
    }
    
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        executeOperation { [weak self] in
            guard let self = self else { return }
            
            do {
                guard let entity = try self.findEntity(by: task.id) else {
                    throw TaskError.taskNotFound
                }
                
                self.context.delete(entity)
                
                if self.context.hasChanges {
                    try self.context.save()
                }
                completion(.success(()))
            } catch let error as TaskError {
                completion(.failure(error))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func toggleCompletion(for task: Task, completion: @escaping (Result<Void, TaskError>) -> Void) {
        executeOperation { [weak self] in
            guard let self = self else { return }
            
            do {
                guard let entity = try self.findEntity(by: task.id) else {
                    throw TaskError.taskNotFound
                }
                
                entity.isCompleted.toggle()
                
                if self.context.hasChanges {
                    try self.context.save()
                }
                completion(.success(()))
            } catch let error as TaskError {
                completion(.failure(error))
            } catch {
                completion(.failure(.operationFailed(error)))
            }
        }
    }
    
}

// MARK: - Private Methods

private extension TaskStore {
    
    func executeOperation(operation: @escaping () -> Void) {
        operationQueue.async {
            self.context.performAndWait {
                operation()
            }
        }
    }
    
    func findEntity(by id: UUID) throws -> TaskEntity? {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
}
