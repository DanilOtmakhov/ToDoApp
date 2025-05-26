//
//  TaskProvider.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import CoreData

struct TaskStoreUpdate {
    enum ChangeType {
        case insert(IndexPath)
        case delete(IndexPath)
        case move(from: IndexPath, to: IndexPath)
        case update(IndexPath)
    }

    let changes: [ChangeType]
}

protocol TaskProviderProtocol {
    var delegate: TaskProviderDelegate? { get set }
    var numberOfRows: Int { get }
    func task(at indexPath: IndexPath) -> Task?
    func fetchTasks()
    func save(_ tasks: [Task]) throws
}

protocol TaskProviderDelegate: AnyObject {
    func didUpdate(_ update: TaskStoreUpdate)
    func didFail(with error: Error)
}

final class TaskProvider: NSObject, TaskProviderProtocol {
    
    // MARK: - Internal Properties
    
    weak var delegate: TaskProviderDelegate?
    
    // MARK: - Private Properties
    
    private let store: TaskStoreProtocol
    private let context: NSManagedObjectContext
    private var changes: [TaskStoreUpdate.ChangeType] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TaskEntity> = {

        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Initialization
    
    init(store: TaskStoreProtocol, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.store = store
        self.context = context
    }
    
}

// MARK: - TaskProviderProtocol

extension TaskProvider {
    
    var numberOfRows: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func task(at indexPath: IndexPath) -> Task? {
        let object = fetchedResultsController.object(at: indexPath)
        return Task(from: object)
    }
    
    func fetchTasks() {
        do {
            try fetchedResultsController.performFetch()
            let update = TaskStoreUpdate(changes: [])
            delegate?.didUpdate(update)
        } catch {
            delegate?.didFail(with: error)
        }
    }
    
    func save(_ tasks: [Task]) throws {
        try store.save(tasks)
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TaskProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        changes.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                changes.append(.insert(newIndexPath))
            }
        case .delete:
            if let indexPath = indexPath {
                changes.append(.delete(indexPath))
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                changes.append(.move(from: indexPath, to: newIndexPath))
            }
        case .update:
            if let indexPath = indexPath {
                changes.append(.update(indexPath))
            }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TaskStoreUpdate(changes: changes)
        delegate?.didUpdate(update)
    }
    
}
